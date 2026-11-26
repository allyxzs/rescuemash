<div align="center">

# RescueMash v3
### Sua rede local. Suas mensagens. Mais perto.

**Elixir / OTP · Phoenix LiveView · SQLite · UDP · AES-256-GCM**

Comunicação distribuída entre dispositivos de uma rede local, com mensagens persistidas,
prioridade e confirmações de recebimento.

[Começar](#começar) · [Como funciona](#como-funciona) · [API](#api) · [Atualizar da v2](docs/UPGRADE-v3.md) · [Validação](STATUS.md)

</div>

> **Experimental.** Projeto para desenvolvimento e testes. Não certificado para emergências reais; não substitui serviços oficiais. Um ACK confirma persistência em pelo menos um vizinho, não leitura humana nem entrega a toda a rede.

## O que mudou na v3

| Área | Correções e melhorias |
| --- | --- |
| Compilação | Configuração de produção adicionada, dependências fixadas pelo lock e warnings corrigidos. |
| Mensagens | IDs únicos válidos, validação de conteúdo e TTL, histórico e ordenação crítica → alta → normal. |
| Entrega | Fila persistente, até três tentativas com vizinhos disponíveis, ACK no porto de origem e repetição manual. |
| Transporte | Envelope v3 com AES-256-GCM, nonce aleatório, prazo de validade e cache limitado de replays. |
| Descoberta | Ignora o próprio nó, valida porta/ID, remove vizinhos expirados e limita a tabela. |
| Painel | Layout responsivo, LiveView conectado, login, feedback honesto, filtros e histórico. |
| API | Bearer validado pelo hash SHA-256, erros 400/401/422/429, limite de requisições e JSON válido. |
| Operação | Release OTP, Docker em dois estágios, volume de dados separado e roteiro de migração. |

O nome público passa a ser **RescueMash v3**, versão `3.0.0`. Os módulos `RescueMesh` e a aplicação OTP `:rescue_mesh` permanecem para compatibilidade interna. Não é necessário renomear os diretórios de código.

## Começar

Requisitos: **Elixir 1.18 / Erlang OTP 27**, ferramentas de compilação C (`gcc`, `make`) para SQLite e acesso à internet apenas para instalar dependências. Para compilar os testes a partir das fontes, também são necessários `g++`, `cmake` e `git` (dependência `lazy_html`). Não usa Node, npm ou CDN. Os arquivos JavaScript do Phoenix são copiados das dependências locais.

Na raiz do projeto:

```bash
elixir scripts/generate_secrets.exs
set -a
. ./.env
set +a
mix setup
mix phx.server
```

Abra **http://localhost:4000**. O token de acesso está no arquivo local `.access-token`; consulte-o com `cat .access-token` e utilize-o na tela de login. A sessão dura até oito horas. O script não sobrescreve credenciais existentes, e os dois arquivos privados são ignorados pelo Git e pelo Docker.

`mix setup` instala dependências, prepara os assets locais e cria/migra o banco. Os dados ficam em `data/`. Nunca compartilhe `.env`, `.access-token` ou o diretório de dados em um repositório.

### Conectar dois dispositivos

1. Execute uma instância em cada dispositivo da mesma LAN.
2. Configure o mesmo `RESCUEMASH_NODE_SHARED_KEY` nos dois `.env`. Os tokens HTTP e `SECRET_KEY_BASE` podem ser diferentes.
3. Preserve um `node_id` distinto em cada dispositivo; não copie o diretório `data/` de um nó ativo para criar outro.
4. Permita UDP **43690** e **43691** no firewall local. Broadcast precisa estar permitido na rede.
5. Inicie os serviços e aguarde a descoberta (aproximadamente cinco segundos). Envie uma mensagem e confira o ACK no painel.

A rede local funciona sem internet **depois** da instalação. O software não cria uma rede Wi-Fi mesh física e não atravessa NAT automaticamente. Relógios dos dispositivos devem estar sincronizados (tolerância de 120 segundos).

### Docker

```bash
elixir scripts/generate_secrets.exs
# Se .env já existe, não execute novamente o comando acima.
docker compose up --build -d
```

O Compose padrão publica o painel apenas em `127.0.0.1:4000`. O volume armazena apenas `/data`, sem ocultar migrations. No modo bridge, a descoberta por broadcast entre máquinas não é garantida.

Para testes em uma LAN com **Docker no Linux**, use exclusivamente o arquivo de host networking:

```bash
docker compose -f docker-compose.lan.yml up --build -d
```

Nesse modo, HTTP também escuta nas interfaces do host. Defina `PHX_HOST` com o hostname/IP utilizado para acessar o painel. Use firewall e proxy HTTPS antes de acesso remoto; as sessões e os tokens HTTP exigem um canal protegido. Não publique o serviço diretamente na internet.

## Como funciona

1. Uma mensagem válida é salva no SQLite com estado **Na fila**.
2. A fila verifica os vizinhos a cada cinco segundos, priorizando mensagens críticas.
3. Sem vizinhos, a mensagem permanece salva e não consome tentativas.
4. Com vizinhos, o nó transmite um pacote criptografado. Há até três rodadas de envio.
5. O destinatário persiste a mensagem e devolve um ACK ao IP e à porta observados.
6. O primeiro ACK válido muda o estado para **Confirmada**. Sem ACK, a mensagem pode chegar a **Sem confirmação** e ser reenviada manualmente.

| Estado | Significado |
| --- | --- |
| Na fila (`pending`) | Salva localmente; aguarda descoberta ou ACK. |
| Confirmada (`delivered`) | Pelo menos um vizinho confirmou persistência. |
| Recebida (`received`) | Veio de outro nó e foi salva neste dispositivo. |
| Sem confirmação (`failed`) | Esgotou tentativas com vizinhos disponíveis. Não prova que ninguém recebeu. |

Mensagens repetidas são deduplicadas pelo ID persistido, inclusive após reinício. Retransmissões com nonce novo recebem outro ACK. O gossip encaminha mensagens novas até o TTL acabar; encaminhamento entre saltos é best effort. **Não há sincronização completa do histórico**, confirmação de todos os destinatários ou garantia de entrega fim a fim.

## API

Todas as rotas `/api/v1/*` exigem `Authorization: Bearer <token>`.

| Método | Rota | Resposta |
| --- | --- | --- |
| GET | `/api/v1/status` | Versão, uptime, contadores e transporte. |
| GET | `/api/v1/nodes` | Vizinhos ativos, com IP serializável. |
| GET | `/api/v1/nodes/:id` | Vizinho específico ou 404. |
| GET | `/api/v1/messages?limit=50` | Histórico recente, limite entre 1 e 100. |
| POST | `/api/v1/messages` | Persiste uma mensagem; retorna 201 com o ID. |
| POST | `/api/v1/messages/:id/retry` | Recoloca mensagem falhada na fila, ou 404/409. |
| GET | `/health` | Saúde do banco/migration, sem dados de mensagens e sem autenticação. |

```bash
export RESCUEMASH_TOKEN="$(cat .access-token)"
curl -sS http://localhost:4000/api/v1/messages   -H "Authorization: Bearer $RESCUEMASH_TOKEN"   -H 'Content-Type: application/json'   -d '{"content":"Equipe reunida no ponto A.","priority":"high"}'
unset RESCUEMASH_TOKEN
```

Conteúdo de 1 a 2.000 caracteres; prioridades `normal`, `high`, `critical`. A API responde `422` para mensagem inválida e `429` com `Retry-After: 60` ao exceder 120 requisições/minuto por IP. O login permite dez tentativas/minuto por IP. O painel limita envios/repetições a 120/minuto por instância. Os limites são locais e se reiniciam com o processo.

## Configuração

| Variável | Uso |
| --- | --- |
| `SECRET_KEY_BASE` | Segredo de pelo menos 64 bytes para sessões Phoenix. |
| `RESCUEMASH_API_TOKEN_HASH` | SHA-256 hexadecimal minúsculo do token HTTP. |
| `RESCUEMASH_NODE_SHARED_KEY` | Base64 de 32 bytes aleatórios, compartilhada entre os nós confiáveis. |
| `DATA_DIR` | Diretório do SQLite e do ID local; padrão `data`. |
| `PORT` | Porta HTTP; padrão `4000`. |
| `PHX_HOST` | Host/IP utilizado para abrir o painel; padrão `localhost`. |
| `MESH_PORT` | Porta UDP de mensagens; padrão `43690`. |
| `DISCOVERY_PORT` | Porta UDP de broadcast; padrão `43691`. |
| `MESH_BROADCAST_ADDRESS` | Endereço de broadcast IPv4; padrão `255.255.255.255`. |

Os nomes antigos `RESCUEMESH_API_TOKEN_HASH` e `RESCUEMESH_NODE_SHARED_KEY` ainda são aceitos, mas seus **formatos devem seguir as regras da v3**. Em produção, variáveis ausentes ou inválidas impedem a inicialização. Em desenvolvimento sem configuração, o painel fica sem acesso e a chave mesh efêmera isola a instância.

## Desenvolvimento e validação

```bash
mix deps.get --check-locked
mix format --check-formatted
mix compile --warnings-as-errors
mix assets.build
mix test --warnings-as-errors
MIX_ENV=prod mix compile --warnings-as-errors
MIX_ENV=prod mix release
python3 scripts/smoke_two_nodes.py
```

Consulte [STATUS.md](STATUS.md) para os resultados efetivamente executados, [CHANGELOG.md](CHANGELOG.md) para as alterações e [SECURITY.md](SECURITY.md) para o modelo de confiança. O workflow também verifica o build Docker no GitHub Actions.

## Organização

- `lib/rescue_mesh/mesh/`: descoberta, envelope criptográfico, sockets e gossip.
- `lib/rescue_mesh/messaging/`: persistência, estados e fila.
- `lib/rescue_mesh_web/`: painel LiveView, login e API.
- `priv/repo/migrations/`: migrations incrementais, preservando a migration da v2.
- `priv/static/`: CSS, ícone e inicialização do LiveView.
- `test/`: testes reais de persistência, API, autenticação, painel e UDP.
- `docs/UPGRADE-v3.md`: migração com backup e preservação da identidade do nó.
