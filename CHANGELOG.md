# Changelog

## [3.0.0] — 2026-11-26

### Corrigido

- `config/prod.exs` ausente, Docker copiando lock inexistente e configuração de assets incompleta.
- Geração de ID que passava um inteiro inválido para `:crypto.hash/2`.
- Atualização de recibos com chamada inexistente de `Enum.uniq/2`.
- Priorização alfabética incorreta, falta de validação de TTL e confirmação antes de persistir.
- Serialização JSON de structs Ecto e endereços IP em tupla.
- ACK enviado para porta fixa, ausência de novo ACK em retransmissões e deduplicação apenas em memória.
- Descoberta do próprio nó, vizinhos sem expiração e campos de configuração capturados em compilação.
- LiveView sem sessão, CSRF, scripts locais e root layout funcional.
- Volume Docker que ocultava arquivos em `priv/`.

### Adicionado

- Marca pública RescueMash v3, painel responsivo com histórico, filtros, prioridades e repetição manual.
- Autenticação de painel e API por token verificado via SHA-256; rate limiting efetivo.
- Envelope AES-256-GCM, janela temporal e cache limitado de nonces.
- Fila com tentativas persistidas, sem consumir tentativas quando não existem vizinhos.
- Migration incremental, release OTP, configuração de produção e geração local de credenciais.
- Testes reais de armazenamento, descoberta, protocolo, UDP, API e LiveView.
- LiveView 1.2.15, Ecto 3.14.3 e Decimal 3.2.0, substituindo versões com avisos de segurança na resolução inicial.
- Lock de dependências, CI com formatação/compilação/testes/release/Docker e guia de atualização.

### Compatibilidade

- Módulos `RescueMesh` e aplicação `:rescue_mesh` mantidos; nome público e versão atualizados.
- Banco migrável sem apagar dados; novo diretório padrão `data/`.
- Protocolo UDP v3 incompatível com v2. Atualize todos os nós e configure a chave de grupo.
- Semântica corrigida do token: o cliente informa o token original, não o hash.
- Removidos módulos vazios de sincronização e heartbeat redundante. Não se promete sincronização de histórico.

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
