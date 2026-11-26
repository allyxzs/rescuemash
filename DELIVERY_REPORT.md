# Entrega · RescueMash v3

**Versão:** 3.0.0 · **Base:** ZIP RescueMesh-v2.0.0 fornecido pelo usuário.

## Resultado

Atualização de código, configuração, interface, testes e documentação. A marca pública é RescueMash v3. O pacote contém os arquivos diretamente na raiz, incluindo `.github`, `mix.lock`, migrations incrementais e guia de atualização. Não contém credenciais, bancos, dependências instaladas ou builds locais.

## Diagnóstico da v2

A revisão encontrou configuração de produção ausente, Dockerfile exigindo um lock não fornecido, chamadas inválidas em geração de ID e recibos, warnings incompatíveis com o CI, rate limiter vazio, fila/sincronização sem implementação e painel sem a integração necessária de assets/sessão/CSRF.

O print mostra um check de CI falhando, mas não contém o log detalhado. O log remoto do GitHub não foi consultado; o diagnóstico se baseou no código anexado e na validação local da v3.

## Melhorias entregues

- Compilação corrigida, dependências atualizadas e lock real.
- Painel responsivo com login, histórico, filtros, prioridades, feedback de fila e repetição manual.
- Fila persistida, tentativas limitadas, recuperação após vizinho voltar e estados de entrega explícitos.
- UDP criptografado/autenticado, validação de pacotes, deduplicação persistida, ACK na porta correta e expiração de vizinhos.
- API autenticada com validação, respostas JSON e limites de requisições.
- Release OTP, Docker revisado e workflow com teste de duas releases.
- 25 testes aprovados e teste completo de descoberta/envio/ACK/reinício/reconexão aprovado.

## Antes de atualizar uma instalação existente

Leia `docs/UPGRADE-v3.md`. Preserve o banco e o ID do nó, migre o diretório de dados e configure novas credenciais no formato da v3. O protocolo UDP v3 não conversa com nós v2.

Os resultados e as verificações ainda pendentes estão descritos em `STATUS.md`. Docker e teste em navegador real não foram concluídos neste ambiente. Nenhuma alteração foi publicada no GitHub.
