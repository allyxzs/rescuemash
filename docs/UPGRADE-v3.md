# Atualização da v2 para RescueMash v3

## Antes de substituir o código

Pare a instância v2. Faça backup do banco SQLite e de `priv/node_id`; se houver arquivos `-wal` e `-shm`, preserve-os junto do banco. Faça o backup com o processo parado para manter consistência. Preserve suas configurações privadas fora do pacote.

O ZIP v3 tem os arquivos do projeto diretamente na raiz. Não inclui `.git`, banco, credenciais, dependências ou artefatos de build. Não substitua seus dados por um diretório vazio.

## Dados locais

Na v2, os caminhos padrão eram `priv/rescue_mesh_dev.sqlite3` em desenvolvimento e `priv/rescue_mesh.sqlite3` em produção. A v3 usa `data/rescuemash.sqlite3` e `data/node_id` por padrão.

Copie o banco correto do seu backup para `data/rescuemash.sqlite3` e o ID para `data/node_id`, com o processo parado. O diretório deve ser gravável pelo usuário que executa o serviço. Não copie a identidade para um segundo nó diferente.

Não execute `ecto.drop` nem `ecto.reset`. A migration original permanece intacta; a nova adiciona `attempts`, `last_attempt_at` e um índice. Ela não apaga mensagens. Mensagens antigas fora das novas regras de validação podem exigir revisão antes de reenvio.

## Credenciais e protocolo

A v2 comparava o Bearer diretamente com a variável chamada `API_TOKEN_HASH`. A v3 calcula SHA-256 do token informado e compara com o hash configurado. Gere credenciais novas com `elixir scripts/generate_secrets.exs`, em um diretório sem `.env` e `.access-token`, ou ajuste sua configuração com o mesmo formato.

A chave de rede agora deve ser base64 de exatamente 32 bytes aleatórios. Todos os nós da LAN devem usar a mesma chave. O protocolo UDP v3 **não é compatível com a v2**; atualize os nós juntos. As mensagens existentes no banco permanecem disponíveis localmente.

## Inicialização

```bash
set -a
. ./.env
set +a
mix deps.get
mix assets.build
mix ecto.migrate
mix phx.server
```

Acesse o painel, confira o ID do nó e o histórico, conecte um segundo dispositivo e envie uma mensagem de teste antes de retomar seus experimentos. Em produção, mantenha `MIX_ENV=prod` e o mesmo `DATA_DIR` ao migrar e executar.

## Docker

O volume da v2 montava `/app/priv`, ocultando arquivos da aplicação. A v3 usa `/data`. Copie o banco e o ID preservados para o novo volume, com o contêiner parado, e atribua permissões ao UID/GID `10001`. Não remova o volume antigo antes de validar a atualização. O nome de serviço muda de `rescuemesh` para `rescuemash`.

## Retorno à v2

Pare a v3 e restaure **o backup completo anterior**, o código v2 e a configuração correspondente. Não misture o banco já migrado com a aplicação antiga; a v3 adiciona estados e campos que a v2 não conhece.
