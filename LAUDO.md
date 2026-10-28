1. `central_service.dart` — Autor: trocar `u.email` por `u.uid` em `autorId`.
2. `central_service.dart` — Pistas: trocar `doc('pistas')` por `doc(ocorrenciaId)`.
3. `central_service.dart` — Status: corrigir a atualização do campo `resolvido`.
4. `detalhe_page.dart` — Validação: corrigir a condição de validação dos campos.
5. `detalhe_page.dart` — Pistas: impedir o envio de mensagens vazias.
6. `ocorrencia.dart` — Identificação: trocar `d['autorNome']` por `d['autorId']` em `autorId`.
7. `ocorrencia.dart` — Status: remover a negação `!` do campo `resolvido`.
8. `central_page.dart` — Cadastro: trocar `&&` por `||` na validação.
9. `central_page.dart` — Filtro: trocar `o.resolvido` por `!o.resolvido`.
10. `central_page.dart` — Switch: atribuir `value` diretamente a `somenteAbertos` tirar !
11. `central_page.dart` — Navegação: passar a ocorrência selecionada para `DetalhePage`.
12. `central_page.dart` — Fechamento do formulário: fechar o diálogo usando o contexto correto (`dialogContext`).
13. `detalhe_page.dart`try no OutlinedButton