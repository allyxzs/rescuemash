# RescueMesh v2.0.0

Plataforma distribuída de comunicação P2P para emergências — **projeto experimental sem certificação para uso real**.

## Funcionalidades Implementadas (Reais)

- Descoberta automática via UDP broadcast
- Comunicação P2P com protocolo Gossip (TTL + deduplicação)
- Persistência SQLite com Ecto
- Fila de mensagens por prioridade e ACKs
- Heartbeat + monitoramento de vizinhos
- Autenticação Bearer + rate limiting
- Dashboard LiveView em tempo real
- API REST versionada

## Arquitetura

```
┌────────────┐     UDP Broadcast      ┌────────────┐
│   Nó A     │◄──────────────────────►│   Nó B     │
│  (Elixir)  │         Gossip         │  (Elixir)  │
└─────┬──────┘                        └─────┬──────┘
      │                                   │
   SQLite                              SQLite
```

## Execução

```bash
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
# http://localhost:4000/dashboard
```

## Segurança

- Chaves e tokens via variáveis de ambiente apenas
- Validação de tamanho e formato de pacotes
- Deduplicação de mensagens (replay protection)
- Autenticação Bearer na API

## Testes

```bash
mix test
```

## Limitações Conhecidas

- Sem criptografia de transporte (UDP plaintext)
- Sem testes de integração entre múltiplos nós executados
- Sem validação em campo real
- Sem certificação ou auditoria externa

**Este projeto é experimental e não deve ser utilizado em emergências reais sem validação completa.**
