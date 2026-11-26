# RescueMesh

![RescueMesh Banner](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMiIgaGVpZ2h0PSIxMiI+PGNpcmNsZSBjej0iMTIgIiB5PSIxMiIgZmlsbD0iI2ZmZmZmZiIvPjx0ZXh0IHg9IjEyIiB5PSIxMiIgZm9udC0zaW9uPSIyMCIgZm9udC1ydWXtZ2JzYW50PSJrZXktcmlnaHQiIHN0cm9rZT0iIzM1LjUiIHg9IjEyIiB5PSIxMiI+L2R0eXBlbWVudC9xb3N0PjwvdGV4dD48L3N2Zz4=)

## 🚨 Comunicação Distribuída para Emergências

## O Problema

Sistemas de comunicação centralizados podem ficar indisponíveis durante falhas de infraestrutura, deixando comunidades, equipes de resgate e indivíduos sem meios de comunicação críticos quando mais precisam.

## A Solução

**RescueMesh** é uma plataforma distribuída de comunicação entre dispositivos conectados por redes locais, sem depender de um servidor central. Cada dispositivo na rede se torna um nó da mesh, criando uma rede resiliente e autossuficiente.

## ✨ Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **🔍 Descoberta de Nós** | Detecção automática de dispositivos na rede local usando broadcast UDP |
| **💬 Troca de Mensagens** | Comunicação P2P direta entre dispositivos sem servidores intermediários |
| **💾 Armazenamento Local** | Mensagens salvas localmente com persistência SQLite, recuperáveis após reinicialização |
| **🔄 Sincronização pós-Reconexão** | Quando um nó volta online, recupera automaticamente todas as mensagens armazenadas |
| **⚡ Priorização de Mensagens** | Mensagens críticas são destacadas e propagadas mais rapidamente pela rede |
| **👀 Monitoramento de Nós** | Visualização em tempo real de nós conectados e status da rede |
| **📡 Gossip Protocol** | Propagação de mensagens por meio de protocolo gossip para cobertura ampla |

## 🛠️ Stack Tecnológica

- **Elixir** - Linguagem principal
- **Erlang/OTP** - Base para concorrência e distribuição
- **Phoenix** - Framework web para API e interface
- **SQLite** - Banco de dados local embutido

## 📋 Requisitos Prévios

- Elixir 1.15+
- Erlang/OTP 25+
- SQLite 3.x

## 🚀 Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/rescue_mesh.git

# Entre no diretório
cd rescue_mesh

# Instale as dependências
mix deps.get

# Instale assets (TailwindCSS)
mix tailwind.install --if-missing

# Crie o banco de dados
mix ecto.create

# Execute as migrações
mix ecto.migrate

# Inicie a aplicação
mix phx.server
```

Acesse em: `http://localhost:4000`

## 📱 Interface

![Interface Principal](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMiIgaGVpZ2h0PSIxMiI+PGNpcmNsZSBjej0iMTIgIiB5PSIxMiIgZmlsbD0iI2ZmZmZmZiIvPjx0ZXh0IHg9IjEyIiB5PSIxMiIgZm9udC0zaW9uPSIyMCIgZm9udC1ydWXtZ2JzYW50PSJrZXktcmlnaHQiIHN0cm9rZT0iIzM1LjUiIHg9IjEyIiB5PSIxMiI+L2R0eXBlbWVudC9xb3N0PjwvdGV4dD48L3N2Zz4=)

## 📡 API Pública

| Endpoint | Método | Descrição |
|---|---|---|
| `/api/mesh/discovery` | GET | Escaneia nós disponíveis na rede |
| `/api/mesh/messages` | POST | Envia nova mensagem |
| `/api/mesh/messages` | GET | Lista mensagens prioritárias |
| `/api/mesh/messages/:id` | GET | Busca mensagem específica |
| `/api/mesh/messages/:id/resend` | POST | Resende mensagem após reconexão |
| `/api/mesh/status` | GET | Status da rede e nós conectados |

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│              Rede Mesh P2P Distribuída                  │
│  ┌─────┐     ┌─────┐     ┌─────┐     ┌─────┐           │
│  │ Nó 1│ ↔ ↔ │ Nó 2│ ↔ ↔ │ Nó 3│ ... │ Nó N│           │
│  └─────┘     └─────┘     └─────┘     └─────┘           │
│           │           │           │           │           │
│           └───────────┘───────────┘───────────┘           │
│                 Protocolos Gossip & Discovery           │
└─────────────────────────────────────────────────────────┘

                      └─────────────────┘
                        │ SQLite Local │
                        └─────────────────┘
```

## 🤝 Como Contribuir

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 📞 Contato

- GitHub: [@seu-usuario](https://github.com/seu-usuario)
- Issues: [Report bugs](https://github.com/seu-usuario/rescue_mesh/issues)

---

**RescueMesh** - Salvando vidas através da conectividade distribuída. 🌐✨