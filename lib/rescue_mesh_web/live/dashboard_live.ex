defmodule RescueMeshWeb.DashboardLive do
  use Phoenix.LiveView
  alias RescueMesh.{Mesh.Discovery, Mesh.Gossip, Messaging.Store}
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(RescueMesh.PubSub, "mesh:updates")
      :timer.send_interval(5_000, :refresh)
    end

    {:ok, socket |> assign(node_id: RescueMesh.NodeId.get(), filter: "all") |> refresh()}
  end

  @impl true
  def handle_info(:refresh, socket), do: {:noreply, refresh(socket)}
  @impl true
  def handle_event("send_message", params, socket) do
    if allowed?() do
      case Gossip.broadcast(Map.take(params, ["content", "priority"])) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, "Mensagem salva na fila. A confirmação depende de um nó vizinho.")
           |> push_event("message-saved", %{})
           |> refresh()}

        {:error, _} ->
          {:noreply,
           put_flash(socket, :error, "Use de 1 a 2.000 caracteres e uma prioridade válida.")}
      end
    else
      {:noreply, put_flash(socket, :error, "Muitas solicitações. Aguarde um minuto.")}
    end
  end

  def handle_event("filter", %{"status" => status}, socket)
      when status in ["all", "pending", "delivered", "received", "failed"],
      do: {:noreply, assign(socket, filter: status)}

  def handle_event("retry", %{"id" => id}, socket) do
    result = if allowed?(), do: Store.retry(id), else: {:error, :rate_limited}

    case result do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Mensagem recolocada na fila.") |> refresh()}

      _ ->
        {:noreply, put_flash(socket, :error, "Não foi possível repetir o envio agora.")}
    end
  end

  defp allowed?, do: RescueMesh.RateLimiter.allow?(:dashboard_send, 120)

  defp refresh(socket),
    do:
      assign(socket,
        nodes: Discovery.public_neighbors(),
        messages: Store.recent(),
        counts: Store.counts()
      )

  defp visible(messages, "all"), do: messages
  defp visible(messages, status), do: Enum.filter(messages, &(&1.status == status))
  defp label("pending"), do: "Na fila"
  defp label("delivered"), do: "Confirmada"
  defp label("received"), do: "Recebida"
  defp label("failed"), do: "Sem confirmação"
  defp priority("normal"), do: "Normal"
  defp priority("high"), do: "Alta"
  defp priority("critical"), do: "Crítica"
  @impl true
  def render(assigns) do
    ~H"""
    <div class="app-shell">
      <aside class="sidebar">
        <a class="brand" href="/dashboard"><span class="brand-mark">✳</span><span>RescueMash<small>LOCAL COMMUNICATION / V3</small></span></a>
        <div class="side-label">WORKSPACE</div>
        <a class="nav-item active" href="#overview"><span>◉</span>
        Central de comunicação <span>↗</span></a>
        <a class="nav-item" href="#messages"><span>▤</span> Mensagens</a>
        <a class="nav-item" href="#neighbors"><span>⌘</span> Nós da rede</a>
        <div class="side-bottom">
          <span class="status-dot"></span>
          Nó local ativo<p>Protocolo v3 · AES-256-GCM</p><code>{String.slice(@node_id, 0, 8)}</code>
        </div>
      </aside>
      <main id="overview" class="workspace">
        <header class="topbar">
          <span>Workspace <span class="muted">/</span> <strong>Visão geral</strong></span><span class="version">V3.0.0</span><form
            action="/logout"
            method="post"
          >
            <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} /><input
              type="hidden"
              name="_method"
              value="delete"
            /><button class="text-button">Sair ↗</button>
          </form>
        </header>
        <div class="page-heading">
          <div>
            <p class="eyebrow">CONECTAR. COMPARTILHAR. COORDENAR.</p><h1>
              Comunicação que<br />mantém você perto<span class="accent">.</span>
            </h1><p class="muted">Sua central de mensagens entre nós da rede local.</p>
          </div><div class="network-pill">
            <span class="status-dot"></span> {if @nodes == [],
              do: "Aguardando vizinhos",
              else: "Rede descoberta"}
          </div>
        </div>
        <div class="notice warning">
          Experimental · Use para desenvolvimento e testes. Não substitui serviços oficiais de emergência.
        </div>
        <p :if={Phoenix.Flash.get(@flash, :info)} role="status" class="notice success">
          {Phoenix.Flash.get(@flash, :info)}
        </p>
        <p :if={Phoenix.Flash.get(@flash, :error)} role="alert" class="notice error">
          {Phoenix.Flash.get(@flash, :error)}
        </p>
        <div class="connection-error" role="status">
          Conexão com a central interrompida. Reconectando…
        </div>
        <section class="metrics" aria-label="Resumo da rede">
          <article>
            <span class="metric-label">Nós vizinhos <span>⌘</span></span><strong>{length(@nodes)
            |> Integer.to_string()
            |> String.pad_leading(2, "0")}</strong><small>Descobertos nesta rede</small>
          </article>
          <article>
            <span class="metric-label">Na fila <span>↗</span></span><strong>{@counts["pending"]
            |> Integer.to_string()
            |> String.pad_leading(2, "0")}</strong><small>Aguardando confirmação</small>
          </article>
          <article>
            <span class="metric-label">Confirmadas <span>✓</span></span><strong class="accent">{@counts[
              "delivered"
            ]
            |> Integer.to_string()
            |> String.pad_leading(2, "0")}</strong><small>Ao menos um vizinho recebeu</small>
          </article>
          <article>
            <span class="metric-label">Recebidas <span>↓</span></span><strong>{@counts["received"]
            |> Integer.to_string()
            |> String.pad_leading(2, "0")}</strong><small>Salvas neste dispositivo</small>
          </article>
        </section>
        <div class="content-grid">
          <section id="messages" class="panel messages-panel">
            <div class="panel-heading">
              <h2>Atividade de mensagens</h2><span class="live-label"><span class="status-dot"></span>
              AO VIVO</span>
            </div>
            <div class="filters" aria-label="Filtrar mensagens">
              <button
                :for={
                  {value, text} <- [
                    {"all", "Todas"},
                    {"pending", "Na fila"},
                    {"received", "Recebidas"},
                    {"failed", "Sem confirmação"}
                  ]
                }
                phx-click="filter"
                phx-value-status={value}
                class={if @filter == value, do: "selected", else: ""}
                aria-pressed={to_string(@filter == value)}
              >{text}</button>
            </div>
            <div :if={visible(@messages, @filter) == []} class="empty-state">
              <span class="empty-icon">↗</span><h3>Nenhuma mensagem por aqui</h3><p>
                Envie sua primeira mensagem.<br />Ela fica salva mesmo sem vizinhos disponíveis.
              </p>
            </div>
            <div class="message-list">
              <article
                :for={msg <- visible(@messages, @filter)}
                class="message"
                id={"message-#{msg.id}"}
              >
                <div class="message-meta">
                  <span class={"priority #{msg.priority}"}>{priority(msg.priority)}</span><span>{Calendar.strftime(
                    msg.created_at,
                    "%d/%m · %H:%M UTC"
                  )}</span><span class={"badge #{msg.status}"}>{label(msg.status)}</span>
                </div>
                <p>{msg.content}</p><div class="message-foot">
                  <code>{String.slice(msg.from_node, 0, 8)} · {String.slice(msg.id, 0, 8)}</code><span>{msg.attempts} tentativa(s)</span><button
                    :if={msg.status == "failed"}
                    class="text-button"
                    phx-click="retry"
                    phx-value-id={msg.id}
                  >Tentar novamente ↗</button>
                </div>
              </article>
            </div>
            <footer class="panel-footer">
              Últimas 50 mensagens · histórico persistido localmente
            </footer>
          </section>
          <div class="right-column">
            <section class="panel composer">
              <div class="panel-heading">
                <h2>Nova mensagem</h2><span>↗</span>
              </div><form id="message-composer" phx-submit="send_message" phx-hook="MessageComposer">
                <label for="content">O que precisa comunicar?</label><textarea
                  id="content"
                  name="content"
                  rows="4"
                  maxlength="2000"
                  required
                  placeholder="Escreva uma atualização para sua rede…"
                ></textarea><div class="field-hint">Até 2.000 caracteres</div><label for="priority">Prioridade</label><select
                  name="priority"
                  id="priority"
                ><option value="normal">Normal — atualização de rotina</option><option value="high">
                  Alta — atenção necessária
                </option><option value="critical">Crítica — ação urgente</option></select><button
                  type="submit"
                  phx-disable-with="Salvando…"
                >Adicionar à fila <span>↗</span></button>
              </form><p class="fine">
                O envio começa quando um vizinho é descoberto. Confirmação significa recebimento em um nó, não leitura por uma pessoa.
              </p>
            </section>
            <section id="neighbors" class="panel neighbors">
              <div class="panel-heading">
                <h2>Nós da rede</h2><span class="count">{length(@nodes)}</span>
              </div><div :if={@nodes == []} class="neighbors-empty">
                <span>⌘</span><p>Buscando conexões próximas</p><small>Use a mesma chave de rede nos dispositivos da LAN.</small>
              </div><div :for={node <- @nodes} class="neighbor">
                <span class="status-dot"></span><div>
                  <code>{String.slice(node.node_id, 0, 8)}</code><small>{node.ip}:{node.port}</small>
                </div><span class="badge received">Ativo</span>
              </div>
            </section>
          </div>
        </div>
        <footer class="page-footer">
          <span>RescueMash v3 <span class="muted">/ Comunicação local distribuída</span></span><span>Elixir · Phoenix · SQLite</span>
        </footer>
      </main>
    </div>
    """
  end
end
