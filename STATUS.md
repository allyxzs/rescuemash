# Estado da entrega v2.0.0

Os arquivos desta árvore foram gerados como uma atualização estrutural inicial, mas não foram compilados ou executados neste ambiente. Portanto, esta entrega não deve ser considerada uma release validada.

## Verificação

- `mix deps.get`: não executado
- `mix compile`: não executado
- `mix test`: não executado
- Teste de múltiplos nós: não executado
- Teste de SQLite/reconexão: não executado
- Teste de segurança: não executado
- `mix.lock`: não gerado; o arquivo não deve ser tratado como lock válido
- ZIP: não gerado

## Limitações importantes

A implementação contém a estrutura OTP, sockets UDP, descoberta, Gossip, persistência Ecto/SQLite, API e LiveView, mas ainda exige uma rodada de correção compilável e validação real. Em particular, criptografia autenticada de transporte, rate limiting efetivo, reconexão/sincronização completa e testes de integração entre processos ainda não estão prontos para uso operacional.

RescueMesh é experimental e não certificado para emergências reais.
