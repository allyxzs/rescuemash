const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
if (window.LiveView && window.Phoenix && csrfToken) {
  const liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket, {
    params: {_csrf_token: csrfToken},
    hooks: {
      MessageComposer: {
        mounted() { this.handleEvent("message-saved", () => this.el.reset()); }
      }
    }
  });
  liveSocket.connect();
}
