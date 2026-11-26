# RescueMesh - Documentação Completa

## Visão Geral

RescueMesh é uma plataforma de comunicação distribuída projetada para situações de emergência, onde sistemas de comunicação centralizados podem ficar indisponíveis. A plataforma permite que dispositivos conectados em redes locais se comuniquem diretamente (P2P) sem depender de um servidor central.

## Arquitetura do Sistema

### Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                   REDE MESH P2P DISTRIBUÍDA                        │
│                                                                     │
│  ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐       │
│  │ Dispositivo 1 │──┼── Dispositivo 2 │──┼── Dispositivo 3 │──┐      │
│  │ (Nó 1)     │     │ (Nó 2)     │     │ (Nó 3)     │  │      │
│  └─────┬─────┘     └─────┬─────┘     └─────┬─────┘  │  │      │
│        │                 │                 │     │  │  │      │
│  Gossip Protocol         │           Gossip Protocol     │
│        │                 │                 │     │  │      │
│  ┌───────────────────────┼─────────────────────┘  │      │
│  │                      │                        │      │
│  │                      │                        │      │
│  │       SQLite Local   │                        │      │
│  └───────────────────────┘                        │      │
│                                                                     │
│  Cada nó:                                                           │
│  • Descobre vizinhos via broadcast UDP                              │
│  • Propaga mensagens via protocolo gossip                           │
│  • Armazena mensagens localmente                                    │
│  • Sincroniza após reconexão                                        │
│  • Prioriza mensagens críticas                                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Componentes Principais

1. **Mesh Node (Nó da Rede)** - Responsável pela descoberta, gossip e comunicação P2P
2. **Discovery Service** - Varredura de nós na rede local usando broadcast UDP
3. **Gossip Protocol** - Propagação de mensagens por nó em nó com TTL
4. **Local Storage (SQLite)** - Persistência de mensagens em cada dispositivo
5. **Messaging API** - Interface para envio e recebimento de mensagens
6. **Status Monitoring** - Visualização de nós conectados e status da rede

## Funcionalidades Detalhadas

### ✅ Descoberta de Nós
- Cada nó broadcast sua presença periodicamente
- Novos nós são descobertos automaticamente
- TTL (Time To Live) para remoção de nós inativos
- Lista vizinhos visíveis no painel

### ✅ Troca de Mensagens
- Comunicação direta P2P entre nós
- Mensagens podem ser broadcast ou direcionadas
- Confirmação de entrega
- Histórico de mensagens enviadas/recebidas

### ✅ Armazenamento Local
- Persistência SQLite em cada nó
- Mensagens sobrevivem a reinicializações
- Fila de mensagens pendentes
- Prioridade (normal vs alta/crítica)

### ✅ Sincronização após Reconexão
- Quando um nó volta online, ele recupera todas as mensagens
- Estado é sincronizado com outros vizinhos
- Mensagens perdidas durante offline são recuperadas

### ✅ Priorização de Mensagens
- Mensagens marcadas como "high" priority
- Propagação mais rápida via gossip
- Destaque no painel de mensagens
- Fila preferencial para transmissão

### ✅ Monitoramento de Nós
- Lista em tempo real de nós conectados
- Timestamp de última atividade
- Status online/offline
- Contagem de vizinhos

## Stack Tecnológica

| Camada | Tecnologia | Propósito |
|--------|-----------|-----------|
| **Linguagem** | Elixir 1.15+ | Produtividade e concorrência |
| **Runtime** | Erlang/OTP 25+ | Máquina virtual robusta |
| **Web Framework** | Phoenix 1.7+ | API e interface web |
| **Banco de Dados** | SQLite 3.x | Persistência local embutida |
| **Comunicação** | GenServer, gRPC/UDP | Processos distribuídos |
| **Estilização** | TailwindCSS | Interface responsiva |

## Requisitos de Sistema

### Hardware Mínimo
- CPU: 1 núcleo (2 núcleos recomendados)
- RAM: 256 MB (512 MB recomendados)
- Armazenamento: 50 MB livres para SQLite

### Software Necessário
- **Elixir**: `1.15.7` ou superior
- **Erlang/OTP**: `25.3` ou superior
- **SQLite**: `3.45.0` ou superior (geralmente vem com Elixir)
- **Git**: Para versionamento
- **Node.js**: `18+` (apenas para assets/build)

### Dependências do Mix
```elixir
# mix.exs
def deps do
  [
    {:phoenix, "~> 1.7.10"},
    {:phoenix_html, "~> 4.0"},
    {:phoenix_live_view, "~> 0.20.1"},
    {:sqlite_ecto, "~> 2.0"},
    {:jason, "~> 2.0"},
    {:telemetry_metrics, "~> 0.6"},
    {:gettext, "~> 0.20"},
    {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
    {:esbuild, "~> 0.20", runtime: Mix.env() == :dev},
  ]
end
```

## Guia de Instalação

### 1. Clonar o Repositório
```bash
git clone https://github.com/seu-usuario/rescue_mesh.git
cd rescue_mesh
```

### 2. Instalar Dependências
```bash
mix deps.get
```

### 3. Instalar Assets (TailwindCSS + esbuild)
```bash
mix tailwind.install --if-missing
# ou
npm install
mix esbuild.setup
```

### 4. Configurar Banco de Dados
```bash
# Criar o banco SQLite
mix ecto.create

# Executar migrações
mix ecto.migrate
```

### 5. Iniciar a Aplicação
```bash
mix phx.server
```

A aplicação estará disponível em: `http://localhost:4000`

### 6. Build para Produção
```bash
mix phx.digest
MIX_ENV=prod mix release
# Ou simplesmente:
mix release
```

## API REST

### Endpoints Disponíveis

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/mesh/discovery` | Lista nós descobertos |
| `GET` | `/api/mesh/discovery/scan` | Força nova varredura |
| `GET` | `/api/mesh/status` | Status da rede |
| `POST` | `/api/mesh/messages` | Envia nova mensagem |
| `GET` | `/api/mesh/messages` | Lista mensagens |
| `GET` | `/api/mesh/messages/:id` | Busca mensagem |
| `POST` | `/api/mesh/messages/:id/resend` | Resende mensagem |

### Exemplos de Requisições

#### Enviar Mensagem
```bash
curl -X POST http://localhost:4000/api/mesh/messages \
  -H "Content-Type: application/json" \
  -d '{"content":"Mensagem de teste","priority":"high"}'
```

#### Varredura de Nós
```bash
curl http://localhost:4000/api/mesh/discovery
```

#### Status da Rede
```bash
curl http://localhost:4000/api/mesh/status
```

## Interface do Usuário

### Página Principal (Dashboard)

![Dashboard Principal](docs/screenshots/dashboard-main.png)

#### Principais Elementos

1. **Contador de Nós** - Quantidade de dispositivos conectados na mesh
2. **Lista de Mensagens** - Mensagens prioritárias e recentes
3. **Botão Varredura** - Descobre novos nós disponíveis
4. **Input de Mensagem** - Enviar mensórias para a rede
5. **Indicador de Status** - Conectividade da rede

### Tela de Descoberta

![Tela de Descoberta](docs/screenshots/discovery-screen.png)

Mostra todos os nós vizíveis na rede com:
- Endereço IP
- Portas abertas
- Tempo desde última comunicação
- Botão "Conectar"

## Estrutura de Pastas

```
rescue_mesh/
├── config/              # Configurações ambiente (dev, prod, test)
│   ├── config.exs       # Configurações principais
│   ├── dev.exs          # Configuração de desenvolvimento
│   ├── prod.exs         # Configuração de produção
│   └── test.exs         # Configuração de teste
├── lib/                 # Código fonte Elixir
│   ├── rescue_mesh.ex   # Módulo principal do application
│   ├── routing.ex       # Roteadores Phoenix
│   ├── web/             # Interface web
│   │   ├── controllers/ # Controladores HTTP
│   │   ├── views/       # Views de template
│   │   ├── channels/    # Canais WebSocket
│   │   └── templates/   # templates HEEX
│   ├── messaging/       # Armazenamento e filas de mensagens
│   ├── mesh/            # Protocolo mesh (node, discovery, gossip)
│   └── state/           # Estado global da aplicação
├── priv/                # Arquivos privados
│   └── repo/            # Migrações Ecto
├── assets/              # Assets frontend (CSS, JS)
├── mix.exs              # Configuração do projeto
└── README.md            # Documentação principal
```

## Casos de Uso

### 🚨 Emergências e Desastres Naturais
- Comunicação quando redes celulares falham
-Coordenação de equipes de resgate
- Alerta de comunidades em risco

### 🏕️ Atividades ao Ar livre
- Comunicação em áreas remotas sem cobertura
- Coordenação de grupos de caminhada/campeamento
- Segurança em expedições

### 💻 Ambientes de Trabalho
- Comunicação interna quando intranet falha
- Coordenação durante cortes de energia
- Backup de comunicação corporativa

### 🎓 Educação e Treinamento
- Simulações de emergência
- Treinamento em comunicação P2P
- Estudos de redes distribuídas

## Desenvolvimento

### Executando Tests
```bash
mix test
```

### Formatação de Código
```bash
mix format
mix credo --warnings-as-errors
```

### Lint e Quality
```bash
mix dialyzer
```

### Adding New Features

1. **Nova funcionalidade de mensagem**: Adicione schema no `lib/rescue_mesh/messaging/store.ex`
2. **Novo endpoint API**: Adicione rota no `lib/rescue_mesh/web/router.ex`
3. **Componente UI**: Crie template HEEX em `lib/rescue_mesh/web/templates/`
4. **Testes**: Adicione testes em `test/rescue_mesh/`

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para detalhes.

## Contato

- **GitHub**: [@seu-usuario](https://github.com/seu-usuario)
- **Issues**: [Report bugs](https://github.com/seu-usuario/rescue_mesh/issues)
- **Discussions**: [Feature requests](https://github.com/seu-usuario/rescue_mesh/discussions)

---

**RescueMesh** - Conectando pessoas quando mais importa. 🌐✨