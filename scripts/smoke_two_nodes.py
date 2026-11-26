#!/usr/bin/env python3
"""Exercise two production releases on loopback; only Python's stdlib is required.

Build first: MIX_ENV=prod mix release
Run: python3 scripts/smoke_two_nodes.py
All credentials and databases are temporary. No application data is modified.
"""
import base64
import hashlib
import json
import os
from pathlib import Path
import secrets
import signal
import socket
import subprocess
import tempfile
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / "_build/prod/rel/rescue_mesh/bin/rescue_mesh"


def ports(kind, count):
    sockets = [socket.socket(socket.AF_INET, kind) for _ in range(count)]
    try:
        for sock in sockets:
            sock.bind(("127.0.0.1", 0))
        return [sock.getsockname()[1] for sock in sockets]
    finally:
        for sock in sockets:
            sock.close()


def wait_for(check, description, timeout=40):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            result = check()
            if result:
                return result
        except (OSError, ValueError):
            pass
        time.sleep(0.6)
    raise RuntimeError("Timed out: " + description)


def stop(process):
    if process and process.poll() is None:
        os.killpg(process.pid, signal.SIGTERM)
        try:
            process.wait(timeout=15)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait(timeout=5)


def main():
    if not RELEASE.is_file():
        raise SystemExit("Build the release first: MIX_ENV=prod mix release")
    http = ports(socket.SOCK_STREAM, 2)
    mesh_a, mesh_b, discovery = ports(socket.SOCK_DGRAM, 3)
    token = secrets.token_urlsafe(32)
    env = os.environ | {
        "SECRET_KEY_BASE": secrets.token_urlsafe(64),
        "RESCUEMASH_API_TOKEN_HASH": hashlib.sha256(token.encode()).hexdigest(),
        "RESCUEMASH_NODE_SHARED_KEY": base64.b64encode(secrets.token_bytes(32)).decode(),
        "PHX_HOST": "127.0.0.1",
        "DISCOVERY_PORT": str(discovery),
        "MESH_BROADCAST_ADDRESS": "127.255.255.255",
        "RELEASE_DISTRIBUTION": "none",
        "ERL_FLAGS": "+S 2:2",
    }
    processes, logs = [None, None], []

    def api(node, path, body=None):
        request = urllib.request.Request(
            f"http://127.0.0.1:{http[node]}{path}",
            data=json.dumps(body).encode() if body is not None else None,
            headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"},
        )
        with urllib.request.urlopen(request, timeout=3) as response:
            return json.load(response)

    with tempfile.TemporaryDirectory(prefix="rescuemash-smoke-") as directory:
        configs = [env | {"PORT": str(http[i]), "MESH_PORT": str(port), "DATA_DIR": str(Path(directory) / str(i))}
                   for i, port in enumerate((mesh_a, mesh_b))]
        try:
            for i in range(2):
                log = open(Path(directory) / f"node-{i}.log", "w+")
                logs.append(log)
                subprocess.run([str(RELEASE), "eval", "RescueMesh.Release.migrate()"],
                               env=configs[i], cwd=ROOT, check=True, stdout=log, stderr=subprocess.STDOUT)
                processes[i] = subprocess.Popen([str(RELEASE), "start"], env=configs[i], cwd=ROOT,
                                                stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
                wait_for(lambda: api(i, "/health"), f"node {i} ready")
            for i in range(2):
                wait_for(lambda: api(i, "/api/v1/nodes")["count"] == 1, "mutual discovery")
            before = api(1, "/api/v1/status")["node_id"]
            for priority in ("high", "critical"):
                api(0, "/api/v1/messages", {"content": "Synthetic integration test", "priority": priority})
            wait_for(lambda: api(0, "/api/v1/status")["messages"]["delivered"] == 2, "ACKs")
            assert api(1, "/api/v1/status")["messages"]["received"] == 2
            print("PASS: discovery, encrypted transport, persistence and ACKs", flush=True)
            stop(processes[1])
            wait_for(lambda: api(0, "/api/v1/nodes")["count"] == 0, "neighbor expiration")
            saved = api(0, "/api/v1/messages", {"content": "Queued while neighbor is offline"})["message"]
            assert saved["status"] == "pending" and saved["attempts"] == 0
            processes[1] = subprocess.Popen([str(RELEASE), "start"], env=configs[1], cwd=ROOT,
                                            stdout=logs[1], stderr=subprocess.STDOUT, start_new_session=True)
            wait_for(lambda: api(1, "/health"), "restarted node ready")
            assert api(1, "/api/v1/status")["node_id"] == before
            wait_for(lambda: api(0, "/api/v1/status")["messages"]["delivered"] == 3, "offline queue delivery")
            assert api(1, "/api/v1/status")["messages"]["received"] == 3
            print("PASS: stable identity, history after restart, offline queue and reconnection", flush=True)
        except Exception:
            for log in logs:
                log.flush()
                log.seek(0)
                # Phoenix filters token fields; API credentials are never printed here.
                print(log.read()[-4000:])
            raise
        finally:
            for process in processes:
                stop(process)
            for log in logs:
                log.close()


if __name__ == "__main__":
    main()
