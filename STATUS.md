# Validação · RescueMash v3.0.0

Validação realizada em 26/11/2026 com Elixir 1.18.3, Erlang/OTP 27.3.4.1 e Linux x86_64.

| Verificação | Resultado |
| --- | --- |
| Resolução de dependências | Concluída; `mix.lock` real incluído. |
| Formatação Elixir/HEEx | `mix format --check-formatted` aprovado. |
| Compilação em desenvolvimento | `mix compile --warnings-as-errors` aprovado. |
| Assets locais | `mix assets.build` executado; cópia dos scripts Phoenix/LiveView validada. |
| Testes ExUnit | **25 testes, 0 falhas**, com warnings tratados como erro. |
| Compilação de produção | `MIX_ENV=prod mix compile --warnings-as-errors` aprovado. |
| Release OTP | `MIX_ENV=prod mix release` concluído. |
| Duas releases independentes | `python3 scripts/smoke_two_nodes.py` aprovado. |
| Descoberta/UDP/ACK | Verificados entre duas releases, com broadcast em loopback. |
| Reinício e reconexão | ID e histórico preservados; mensagem criada sem vizinho foi entregue após reconexão. |
| Sintaxe JavaScript/Python | Verificada. |
| Build Docker | Não executado: não havia Docker disponível neste ambiente. Incluído no workflow. |
| Navegador desktop/celular | Não concluído: a política de sockets do ambiente impediu a inicialização do Chromium. |
| GitHub Actions remoto | Não executado nesta entrega. O workflow foi atualizado, mas não foi publicado no repositório. |

## Cobertura dos testes

- Criação de mensagens, IDs distintos, conteúdo/prioridade inválidos e validação de TTL/timestamp.
- Deduplicação após reinício do Gossip e rejeição de conflitos de conteúdo no mesmo ID.
- Ordenação por prioridade, fila sem vizinhos, contadores de tentativa, falha e repetição manual.
- ACK validado por vizinho/IP/porta, recibos sem duplicação e serialização JSON.
- Descoberta ignorando o próprio nó, portas inválidas e expiração de vizinhos.
- AES-GCM, nonces aleatórios, adulteração, chave incorreta, tamanho e timestamp expirado.
- Sockets UDP reais em portas efêmeras, replay, retransmissão com novo ACK e limite de saltos.
- Autenticação por hash, limite de requisições, API, proteção do painel e CSRF.
- LiveView: renderização, submissão do formulário, persistência e escape de HTML.

O teste de duas releases utiliza dados sintéticos e diretórios temporários. Não representa validação em uma LAN física, sob perda elevada de pacotes, entre muitos nós ou em situação de emergência.

## Limitações da release

Não há sincronização completa de histórico, entrega garantida a todos os destinatários, identidade individual por certificado, auditoria independente ou certificação de segurança. O ACK comprova persistência em pelo menos um vizinho. A verificação de LiveView no servidor foi concluída; o comportamento visual/JavaScript em um navegador real permanece pendente.
