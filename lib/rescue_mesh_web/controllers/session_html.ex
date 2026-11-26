defmodule RescueMeshWeb.SessionHTML do
  use Phoenix.Component

  def new(assigns) do
    ~H"""
    <main class="login-shell">
      <section class="login-card">
        <div class="brand-mark">✳</div><p class="eyebrow">COMUNICAÇÃO LOCAL · V3</p>
        <h1>RescueMash<span class="accent">.</span></h1>
        <p class="muted">Uma rede próxima. Uma mensagem que chega mais longe.</p>
        <h2>Acessar central</h2>
        <p :if={!@configured} class="notice">
          O acesso ainda não foi configurado. Gere as credenciais seguindo o README e reinicie o serviço.
        </p>
        <p :if={@error} role="alert" class="notice error">{@error}</p>
        <form action="/login" method="post">
          <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
          <label for="token">Token de acesso</label>
          <input
            id="token"
            name="token"
            type="password"
            autocomplete="current-password"
            required
            maxlength="512"
            placeholder="Sua credencial local"
          />
          <button type="submit" disabled={!@configured}>Entrar na central <span>↗</span></button>
        </form>
        <p class="fine">Projeto experimental. Não substitui serviços oficiais de emergência.</p>
      </section>
    </main>
    """
  end
end
