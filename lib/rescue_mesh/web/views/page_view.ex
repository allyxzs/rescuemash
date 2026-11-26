defmodule RescueMesh.Web.Views.PageView do
  use RescueMesh.Web, :view

  def home(assigns) do
    ~H"""
    <div class="home-container">
      <h1>RescueMesh</h1>
      <p class="subtitle">Comunicação Distribuída para Emergências</p>
      <div class="features">
        <div class="feature">
          <h3>🔍 Descoberta de Nós</h3>
          <p>Detecte automaticamente outros dispositivos na rede local sem configuração central.</p>
        </div>
        <div class="feature">
          <h3>💬 Troca de Mensagens</h3>
          <p>Comunique-se diretamente com outros nós da mesh, P2P, sem depender de servidores.</p>
        </div>
        <div class="feature">
          <h3>💾 Armazenamento Local</h3>
          <p>Mensagens são salvas localmente e sincronizadas automaticamente após reconexão.</p>
        </div>
        <div class="feature">
          <h3>⚡ Priorização</h3>
          <p>Mensagens críticas são destacadas e propagadas mais rapidamente pela rede.</p>
        </div>
        <div class="feature">
          <h3>👀 Monitoramento</h3>
          <p>Visualize nós disponíveis e status da rede em tempo real.</p>
        </div>
        <div class="feature">
          <h3>🔄 Sincronização</h3>
          <p>Quando um nó volta online, ele recupera todas as mensagens armazenadas localmente.</p>
        </div>
      </div>
      <div class="cta">
        <button id="start-scan" class="btn-primary">Iniciar Varredura</button>
        <button id="send-message" class="btn-secondary">Enviar Mensagem</button>
      </div>
    </div>
    """
  end
end