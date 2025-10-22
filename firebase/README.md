# Firebase (Firestore) – Deploy e Regras

Este app usa:
- Autenticação: Firebase Auth (email/senha)
- Banco de dados: Cloud Firestore (coleção `students` para alunos)

## Como fazer deploy das regras do Firestore
1. Instale o Firebase CLI (se necessário):
   - npm i -g firebase-tools
2. Faça login:
   - firebase login
3. Selecione o projeto correto (deve ser `fit-swim-app` segundo `lib/firebase_options.dart`):
   - firebase use fit-swim-app
4. Faça o deploy das regras:
   - firebase deploy --only firestore:rules

As regras estão em `firebase/firestore.rules`.

## Concorrência e multiusuários
- Firestore lida com concorrência nativamente. O app usa `snapshots()` para listar alunos em tempo real.
- Para evitar conflitos de escrita, preferir updates granulares por documento.
- Se necessário, podemos adicionar transações/batch writes para operações múltiplas.

## Modelo de dados
Coleção: `students`
- name: string
- email: string
- phone: string (DDD+número, apenas dígitos)
- level: string (enum: white|yellow|orange|green|blue|red|black)
- age: number
- active: bool
- updatedAt: server timestamp

## Próximos passos sugeridos
- Funções em nuvem (já incluídas na pasta `functions/`):
  - `setUserRoles`: cria/atualiza usuário no Auth, define custom claims (roles) e sincroniza `users/{uid}` no Firestore.
  - `deleteUser`: remove usuário do Auth e apaga `users/{uid}` (e também um doc legado `users/{email}`, se existir).

### Como instalar e fazer deploy das Cloud Functions
1. Instalar dependências:
   - cd functions
   - npm install
2. Build local (opcional):
   - npm run build
3. Selecionar o projeto correto (deve ser `fit-swim-app`):
   - firebase use fit-swim-app
4. Deploy apenas das funções:
   - firebase deploy --only functions

As funções são chamadas no app via o pacote `cloud_functions`.

### Sincronização de usuários
- A coleção `users` agora usa o `uid` como ID do documento.
- A função `setUserRoles` retorna `{ uid, email, roles }` para o app salvar/atualizar `users/{uid}`.
- A função `deleteUser` apaga do Auth e remove `users/{uid}` (e um doc legado `users/{email}` se existir).