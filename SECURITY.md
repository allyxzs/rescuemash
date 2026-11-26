# Segurança · RescueMash v3

## Modelo de confiança

A v3 é experimental. A criptografia usa AES-256-GCM com chave de grupo, nonce aleatório e autenticação do envelope. Ela protege pacotes contra observação e alteração por quem não possui a chave; qualquer membro com a chave pode emitir pacotes e assumir outro ID. Não há certificação, auditoria criptográfica independente ou garantia para comunicações críticas.

## Credenciais

- Gere segredos aleatórios com `scripts/generate_secrets.exs`.
- A API e o login recebem o token original; o servidor guarda apenas seu hash SHA-256 na configuração.
- Comparação de hashes usa tempo constante. O hash configurado não serve como Bearer.
- `.env`, `.access-token`, banco e identidade não devem entrar no repositório.
- Não reutilize segredos da v2 nem copie configurações de demonstração de terceiros.
- Campos de token/senha/segredo são filtrados nos logs Phoenix.

## HTTP

O painel exige sessão assinada e cifrada, com HttpOnly, SameSite Strict e prazo de oito horas. Formulários usam CSRF. LiveView valida autenticação no mount. Há CSP sem scripts externos e escape HTML padrão. API e login têm limites locais por IP; a aplicação não confia automaticamente em `X-Forwarded-For`.

HTTP não é cifrado pela aplicação. Para acesso remoto, coloque HTTPS na frente do serviço, configure `PHX_HOST`, `force_ssl`/cabeçalhos do proxy de acordo com sua implantação e restrinja o firewall. No Compose padrão, HTTP só é publicado em loopback; host networking expõe as interfaces do host. Não use tokens via HTTP em redes não confiáveis.

## UDP e persistência

O transporte recusa pacotes inválidos, maiores que 16 KiB, com tag inválida ou timestamp fora da janela. Cache de nonces limita replay recente. Mensagens têm validação de tamanho, TTL e unicidade persistida. ACKs usam a porta de origem observada e exigem vizinho conhecido. Ao reiniciar, o cache de nonces desaparece; o registro das mensagens continua.

Não há proteção completa contra negação de serviço na rede, criptografia de banco em repouso, identidade individual, revogação granular ou eliminação automática do histórico. Restrinja acesso ao host e ao volume. Backups contêm mensagens em texto claro.

## Reportar problemas

Não publique tokens, chaves, bancos ou mensagens pessoais em issues. Para uma implantação própria, estabeleça um canal privado de reporte com os responsáveis. Use dados sintéticos ao reproduzir falhas.
