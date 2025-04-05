# ocaml-etl

Projeto de Pipeline de ETL utilizando programação funcional e OCaml.

Autor: Thomas Chiari Ciocchetti de Souza

## Utilização e Requisitos 

### Requisitos de Sistema 

O projeto foi criado e compilado utilizando o seguinte ambiente:
- Linguagem de programação: `OCaml 4.14.2`
- Gerenciador de pacotes: `OPAM 2.3.0`
- Sistema Dune: `dune 3.17.2`
- Pacotes adicionais: `csv 2.4`, `OUnit 2.2.7`, `sqlite3 5.3.1`, `lwt 5.9.1`, `cohttp-lwt-unix 6.1.0`

### Utilizando o Projeto

É possível utilizar o projeto no ambiente `OCaml` local, ou utilizando Dev Containers. Um tutorial de como utilizar Dev Containers em VSCode está disponível [nesse link](https://code.visualstudio.com/docs/devcontainers/tutorial).

Para utilizar o projeto, siga o passo a passo a seguir. 
1. Certifique-se de que possui os requisitos obrigatórios de sistema configurados (`OCaml` e `OPAM`). Para isso, pode utilizar o comando `opam --version`. 
    - Caso esteja utilizando Dev Containers e o comando não for encontrado, utilize o comando `eval $(opam env)` e teste novamente.
2. Navegue até o diretório [etl_project](etl_project/).
3. Instale os pacotes adicionais utilizando o comando `opam install dune csv ounit ounit2 sqlite3 lwt cohttp-lwt-unix tls conduit-lwt-unix lwt_ssl -y`.
    - Caso esteja utilizando Dev Containers, não é necessário utilizar o comando. 
4. Utilize o comando `dune build` para compilar o projeto. 
    - Caso esteja utilizando Dev Containers e o comando não for encontrado, utilize o comando `eval $(opam env)` e teste novamente.
5. Para executar os testes, execute o comando `dune runtest`.
6. Utilize o comando `dune exec etl_project -- <ARGUMENTS>` para executar o projeto. Os argumentos são descritos a seguir. 

### Argumentos de Execução 
O programa aceita os seguintes argumentos:

- **--orders-url**:  
  URL do arquivo CSV de pedidos. Utilize este argumento para ler os dados de pedidos via Internet.  
  *Exemplo:* `--orders-url "https://exemplo.com/path/order.csv"`

- **--orders-local**:  
  Caminho local para o arquivo CSV de pedidos. Utilize este argumento para ler os dados de um arquivo local.  
  *Exemplo:* `--orders-local "data/raw/order.csv"`

- **--items-url**:  
  URL do arquivo CSV de itens de pedidos. Utilize este argumento para ler os dados de itens via Internet.  
  *Exemplo:* `--items-url "https://exemplo.com/path/order_item.csv"`

- **--items-local**:  
  Caminho local para o arquivo CSV de itens de pedidos. Utilize este argumento para ler os dados de um arquivo local.  
  *Exemplo:* `--items-local "data/raw/order_item.csv"`

- **--target-status**:  
  Status alvo dos pedidos a serem processados. Valor padrão: `Complete`.

- **--target-origin**:  
  Origem alvo dos pedidos a serem processados. Valor padrão: `O`.

- **--sqlite-path**:  
  Caminho para o arquivo do banco de dados SQLite onde os dados transformados serão salvos.  
  Se não for informado, a carga em SQLite não será realizada.  
  *Exemplo:* `--sqlite-path "data/processed/output.db"`

- **--csv-output**:  
  Caminho para salvar os dados transformados em um arquivo CSV.  
  Se não for informado, a saída em CSV não será gerada.  
  *Exemplo:* `--csv-output "data/processed/output.csv"`

### Exemplo de Comando Completo

Para executar o projeto utilizando os arquivos CSV desse repositório e salvando os resultados em um arquivo CSV e em uma base de dados Sqlite3, utilize o comando a seguir:

```sh
dune exec etl_project -- \
  --orders-url "https://raw.githubusercontent.com/thomaschiari/ocaml-etl/refs/heads/main/etl_project/data/raw/order.csv" \
  --items-url "https://raw.githubusercontent.com/thomaschiari/ocaml-etl/refs/heads/main/etl_project/data/raw/order_item.csv" \
  --target-status "Complete" \
  --target-origin "O" \
  --sqlite-path "data/processed/output.db" \
  --csv-output "data/processed/output.csv"
```

Caso prefira utilizar arquivos locais para extração dos dados, substitua os argumentos:

```sh 
dune exec etl_project -- \
  --orders-local "data/raw/order.csv" \
  --items-local "data/raw/order_item.csv" \
  --target-status "Complete" \
  --target-origin "O" \
  --sqlite-path "data/processed/output.db" \
  --csv-output "data/processed/output.csv"
```