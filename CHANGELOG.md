# Changelog

## [2.0.0] - 2026-11-26

### Alterado

- Reestruturação dos namespaces Phoenix para `RescueMeshWeb`.
- Supervisão OTP reorganizada com componentes independentes.
- Persistência SQLite revisada com schema e migration compatíveis.
- Descoberta UDP e transporte mesh implementados com sockets reais.
- Gossip com TTL, deduplicação e ACKs implementado.
- Dashboard LiveView inicial adicionado.

### Segurança

- Autenticação Bearer configurável por ambiente.
- Limitação de tamanho de pacotes e payloads.
- Chaves e segredos removidos do código.

### Limitações

A versão continua experimental e não foi certificada, submetida a auditoria externa ou validada para emergências reais.
