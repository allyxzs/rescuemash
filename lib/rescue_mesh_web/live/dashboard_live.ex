defmodule RescueMeshWeb.DashboardLive do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(2_000, :refresh)
    end

    {:ok, assign(socket, nodes: [], messages: [], pending: [])}
  end

  def handle_info(:refresh, socket) do
    nodes = RescueMesh.Mesh.Discovery.get_neighbors()
    pending = RescueMesh.Messaging.Store.pending_messages()

    {:noreply, assign(socket, nodes: nodes, pending: pending)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-zinc-950 text-zinc-100 p-8">
      <div class="max-w-7xl mx-auto">
        <div class="flex justify-between items-center mb-8">
          <div>
            <h1 class="text-4xl font-semibold tracking-tight">RescueMesh</h1>
            <p class="text-zinc-400 mt-1">v2.0.0 — Comunicação Distribuída Experimental</p>
          </div>
          <div class="flex items-center gap-4">
            <div class="px-4 py-2 bg-emerald-950 text-emerald-400 rounded-full text-sm flex items-center gap-2">
              <div class="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"></div>
              <%= length(@nodes) %> nós conectados
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div class="lg:col-span-2">
            <div class="bg-zinc-900 border border-zinc-800 rounded-3xl p-8">
              <h2 class="text-xl font-medium mb-6">Topologia da Rede</h2>
              <%= if Enum.empty?(@nodes) do %>
                <div class="text-center py-12 text-zinc-500">
                  <p>Nenhum nó descoberto ainda.</p>
                  <p class="text-sm mt-2">Aguardando broadcasts UDP...</p>
                </div>
              <% else %>
                <div class="space-y-3">
                  <%= for node <- @nodes do %>
                    <div class="flex items-center justify-between p-4 bg-zinc-950 rounded-2xl border border-zinc-800">
                      <div class="flex items-center gap-4">
                        <div class="w-10 h-10 rounded-full bg-emerald-900 flex items-center justify-center">
                          <span class="text-emerald-400 text-xs font-mono"><%= String.slice(node.node_id, 0, 4) %></span>
                        </div>
                        <div>
                          <div class="font-mono text-sm"><%= node.node_id %></div>
                          <div class="text-xs text-zinc-500"><%= node.ip %>:<%= node.port %></div>
                        </div>
                      </div>
                      <div class="text-right text-xs text-zinc-400">
                        <div>último contato</div>
                        <div><%= node.last_seen %></div>
                      </div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>

          <div>
            <div class="bg-zinc-900 border border-zinc-800 rounded-3xl p-8">
              <h2 class="text-xl font-medium mb-6">Mensagens Pendentes</h2>
              <%= if Enum.empty?(@pending) do %>
                <p class="text-sm text-zinc-500">Nenhuma mensagem pendente.</p>
              <% else %>
                <div class="space-y-2">
                  <%= for msg <- @pending do %>
                    <div class="p-3 bg-zinc-950 rounded-xl text-xs">
                      <div class="font-mono text-emerald-400"><%= String.slice(msg.id, 0, 12) %></div>
                      <div class="text-zinc-400 mt-1 truncate"><%= msg.content %></div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="mt-8">
          <div class="bg-zinc-900 border border-zinc-800 rounded-3xl p-8">
            <h2 class="text-xl font-medium mb-6">Enviar Mensagem</h2>
            <form phx-submit="send_message" class="flex gap-3">
              <input type="text" name="content" placeholder="Digite sua mensagem..." class="flex-1 px-4 py-3 bg-zinc-950 border border-zinc-800 rounded-2xl focus:outline-none focus:border-zinc-600" />
              <select name="priority" class="px-4 py-3 bg-zinc-950 border border-zinc-800 rounded-2xl">
                <option value="normal">Normal</option>
                <option value="high">Alta</option>
                <option value="critical">Crítica</option>
              </select>
              <button type="submit" class="px-8 py-3 bg-white text-black rounded-2xl font-medium hover:bg-zinc-200">Enviar</button>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("send_message", %{"content" => content, "priority" => priority}, socket) do
    packet = %{
      "content" => content,
      "priority" => priority,
      "from" => RescueMesh.NodeId.get()
    }

    RescueMesh.Mesh.Gossip.broadcast(packet)
    {:noreply, put_flash(socket, :info, "Mensagem enviada")}
  end
end