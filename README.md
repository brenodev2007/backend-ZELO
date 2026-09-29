# ZELO — Backend

API REST responsável pela autenticação, gerenciamento de usuários e operações administrativas da plataforma ZELO. Desenvolvida com Node.js, Express, TypeScript e MySQL.

## Índice

* [Visão geral](#visão-geral)
* [Funcionalidades](#funcionalidades)
* [Tecnologias](#tecnologias)
* [Estrutura do projeto](#estrutura-do-projeto)
* [Pré-requisitos](#pré-requisitos)
* [Configuração](#configuração)
* [Executando localmente](#executando-localmente)
* [Endpoints](#endpoints)
* [Banco de dados](#banco-de-dados)
* [Build](#build)
* [Segurança](#segurança)

## Visão geral

O backend do ZELO disponibiliza endpoints para cadastro e autenticação de usuários, consulta e atualização de perfil, redefinição de senha e administração de contas.

A API utiliza tokens JWT para proteger rotas e MySQL para persistência dos dados.

## Funcionalidades

* Cadastro e login de usuários.
* Autenticação baseada em JWT.
* Consulta e atualização de dados do perfil autenticado.
* Redefinição de senha.
* Controle de contas ativas e inativas.
* Rotas administrativas protegidas por autenticação e autorização.
* Listagem de usuários e ajuste de tokens diários por administradores.
* Senhas armazenadas com hash por meio do bcryptjs.

## Tecnologias

| Tecnologia     | Utilização                           |
| -------------- | ------------------------------------ |
| Node.js        | Ambiente de execução                 |
| TypeScript     | Tipagem estática                     |
| Express        | Servidor HTTP e rotas REST           |
| MySQL          | Banco de dados relacional            |
| mysql2         | Conexão e consultas ao banco         |
| JSON Web Token | Autenticação                         |
| bcryptjs       | Hash de senhas                       |
| dotenv         | Variáveis de ambiente                |
| CORS           | Configuração de acesso entre origens |

## Estrutura do projeto

```text
backend-ZELO/
├── src/
│   ├── config/
│   │   └── db.ts
│   ├── controllers/
│   │   ├── adminController.ts
│   │   └── authController.ts
│   ├── middleware/
│   │   ├── adminMiddleware.ts
│   │   └── authMiddleware.ts
│   ├── routes/
│   │   ├── adminRoutes.ts
│   │   └── authRoutes.ts
│   ├── scripts/
│   │   └── initDb.ts
│   └── server.ts
├── schema.sql
├── .env.production.example
├── package.json
└── tsconfig.json
```

## Pré-requisitos

* Node.js (versão LTS recomendada)
* npm
* MySQL 8 ou compatível
* Git

## Configuração

**1. Clone o repositório:**

```bash
git clone https://github.com/brenodev2007/backend-ZELO.git
cd backend-ZELO
```

**2. Instale as dependências:**

```bash
npm install
```

**3. Crie o banco de dados:**

```bash
mysql -u SEU_USUARIO -p < schema.sql
```

O script cria o banco `zelo` e a tabela `users`.

**4. Configure as variáveis de ambiente:**

Crie um arquivo `.env` na raiz do projeto:

```env
PORT=5000
DB_HOST=localhost
DB_USER=seu_usuario
DB_PASS=sua_senha
DB_NAME=zelo
DB_PORT=3306
JWT_SECRET=gere_uma_chave_aleatoria_forte
```

Utilize credenciais reais apenas no ambiente local ou no gerenciador de segredos do ambiente de implantação. Não versione o arquivo `.env`.

## Executando localmente

Inicie o servidor em modo de desenvolvimento:

```bash
npm run dev
```

A API ficará disponível, por padrão, em:

```text
http://localhost:5000
```

O comando `npm start` também inicia o servidor utilizando `ts-node`.

## Endpoints

Todas as rotas abaixo são relativas à base `http://localhost:5000`.

### Autenticação e perfil — `/api/auth`

| Método | Rota              | Acesso  | Descrição                               |
| ------ | ----------------- | ------- | --------------------------------------- |
| POST   | `/register`       | Público | Cadastra um usuário                     |
| POST   | `/login`          | Público | Autentica um usuário                    |
| POST   | `/reset-password` | Público | Solicita redefinição de senha           |
| GET    | `/user`           | JWT     | Retorna os dados do usuário autenticado |
| PATCH  | `/user`           | JWT     | Atualiza o nome do usuário              |

### Administração — `/api/admin`

Todas as rotas administrativas exigem autenticação JWT e autorização de administrador.

| Método | Rota                | Descrição                               |
| ------ | ------------------- | --------------------------------------- |
| GET    | `/users`            | Lista usuários                          |
| PATCH  | `/users/:id/active` | Altera o status de uma conta            |
| PATCH  | `/users/:id/tokens` | Atualiza a quantidade de tokens diários |

> Os formatos de corpo das requisições e das respostas podem ser consultados nos controllers e nas rotas do projeto.

## Banco de dados

A tabela `users` contém os seguintes campos principais:

| Campo                       | Descrição                                              |
| --------------------------- | ------------------------------------------------------ |
| `id`                        | Identificador do usuário                               |
| `name`                      | Nome                                                   |
| `email`                     | E-mail único                                           |
| `password`                  | Hash da senha                                          |
| `is_active`                 | Indica se a conta está ativa                           |
| `is_admin`                  | Indica se o usuário possui privilégios administrativos |
| `daily_tokens`              | Limite de tokens diários                               |
| `created_at` / `updated_at` | Datas de criação e atualização                         |

O valor padrão de `daily_tokens` definido no esquema é 20.

## Build

Para compilar o TypeScript:

```bash
npm run build
```

O projeto utiliza o compilador configurado em `tsconfig.json`. Para executar em produção, configure as variáveis de ambiente e utilize um processo de execução adequado ao ambiente de hospedagem.

## Segurança

* Mantenha `.env` fora do controle de versão.
* Utilize um `JWT_SECRET` longo, aleatório e exclusivo por ambiente.
* Use HTTPS em produção.
* Restrinja o CORS aos domínios autorizados antes de publicar a API.
* Não registre senhas, tokens ou credenciais nos logs.
* Revise as permissões administrativas e os limites de requisição antes de expor os endpoints publicamente.

---

Desenvolvido por **Breno Soriani**.
