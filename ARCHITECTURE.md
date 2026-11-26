# Arquitetura RescueMesh v2

## Processos OTP

`Repo` persiste mensagens. `NodeId` mantém o identificador local. `Mesh.UDP` possui os sockets. `Discovery` mantém a tabela de vizinhos. `Gossip` aplica TTL e deduplicação. `NeighborMonitor` envia heartbeats. `Messaging.Store` serializa operações de persistência. `Endpoint` expõe Phoenix e LiveView.

## Fluxo de mensagem

```mermaid
sequenceDiagram
  participant UI as Dashboard/API
  participant G as Gossip
  participant DB as SQLite
  participant U as UDP
  participant N as Nó vizinho

  UI->>G: broadcast(content, priority)
  G->>DB: insert(id, payload)
  G->>U: UDP packet(TTL)
  U->>N: message
  N->>DB: deduplicate + persist
  N->>U: ACK
  U->>G: ACK
  G->>DB: mark delivered
```

## Topologia

```mermaid
graph LR
  A[Nó A] ---|UDP| B[Nó B]
  B ---|UDP| C[Nó C]
  A ---|UDP| C
  A --> DA[(SQLite)]
  B --> DB[(SQLite)]
  C --> DC[(SQLite)]
```

## Decisões

A descoberta usa broadcast UDP local; mensagens usam gossip limitado por TTL; a deduplicação usa IDs persistidos no SQLite; o dashboard lê o estado real dos processos, sem dados fictícios.
