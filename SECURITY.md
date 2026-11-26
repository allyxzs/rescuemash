# Política de Segurança

## Escopo

RescueMesh v2.0.0 é experimental e não foi validado para comunicações críticas.

## Reporte

Não inclua segredos, chaves privadas ou dados pessoais em relatos. Para ambientes reais, estabeleça um canal privado de reporte antes da implantação.

## Práticas

Segredos devem ser fornecidos exclusivamente por variáveis de ambiente: `SECRET_KEY_BASE`, `RESCUEMESH_API_TOKEN_HASH` e `RESCUEMESH_NODE_SHARED_KEY`.

## Estado atual

A autenticação da API e a validação básica de pacotes estão implementadas. A criptografia de transporte autenticada ainda precisa ser implementada e validada antes de qualquer uso operacional.
