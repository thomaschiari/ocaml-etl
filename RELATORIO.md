# Projeto de ETL em Programação Funcional

Autor: Thomas Chiari Ciocchetti de Souza

## Introdução

### Objetivos

O projeto tem como objetivo processar os dados a partir de arquivos CSV, realizar transformações, e carregar os resultados em uma outra estrutura, como um novo arquivo CSV ou uma base de dados `sqlite3`. Para isso, a linguagem OCaml será utilizada. As duas tabelas de entrada representam dados transacionais de pedidos, e de itens de cada pedido. O objetivo final é fornecer os dados processados para alimentar dashboards de gestão para decisões de negócio. 

### Tecnologias Utilizadas

O projeto foi desenvolvido utilizando o seguinte ambiente:
- Linguagem de programação: `OCaml 4.14.2`
- Gerenciador de pacotes: `OPAM 2.3.0`
- Sistema Dune: `dune 3.17.2`
- Pacotes adicionais: `csv 2.4`, `OUnit 2.2.7`, `sqlite3 5.3.1`, `lwt 5.9.1`, `cohttp-lwt-unix 6.1.0`

### Inicialização e Estrutura do Projeto

A estrutura inicial do projeto foi feita de acordo com a documentação do `dune`, utilizando o comando `dune init proj etl_project`. O comando gera a estrutura de diretórios e arquivos a seguir:

```
etl_project/
├── dune-project
├── test
│   ├── dune
│   └── test.ml
├── lib
│   └── dune
├── bin
│   ├── dune
│   └── main.ml
└── etl_project.opam
```

Onde o diretório `test` conterá os testes unitários utilizados para testar o projeto, o diretório `lib` conterá as definições criadas para cada etapa da pipeline, e o diretório `bin` conterá o executável principal (arquivo `main`). Todas as funções do projeto, assim como as respectivas interfaces, estão documentadas utilizando `docstrings`. 

### Requisitos opcionais implementados
- Extração de Dados via HTTP
- Carregamento de Dados em `Sqlite3`
- Otimização das transformações utilizando `inner join`
- Implementação de testes unitários
- Implementação de documentação (`docstrings`)
- Utilização de `dune` para organização e compilação

### Separação entre funções puras e impuras
Para isolar os efeitos colaterais, as funções foram divididas entre puras (transformação, parsing, cálculos) e impuras (extração de dados, gravação em arquivos, etc). Isso garante maior previsibilidade. 

### Uso de funções de ordem superior
As funções de ordem superior (`map`, `filter` e `fold_left`) foram amplamente utilizadas no projeto, como ao filtrar pedidos, agregar valores, etc. 

## Fase 1: Modelagem de Dados 

No primeiro momento, foram escolhidos os tipos de dados que melhor se relacionam com os dados presentes em cada uma das tabelas, de forma a criar `Records` para a leitura e tratamento dos dados. As definições de tipos podem ser encontradas em [`etl_project/lib/types.ml`](etl_project/lib/types.ml).

### Tabela `Order`

Na tabela `Order` estão disponíveis os seguintes dados:
- `id`: identificador único do pedido. Foi utilizado o tipo `int` em OCaml.
- `client_id`: identificador do cliente. Foi utilizado o tipo `int` em OCaml. 
- `order_date`: data e hora do pedido, em formato ISO 8601. Para facilitar a leitura de dados, foi utilizado o tipo `string` em OCaml, que pode ser tratado posteriormente. 
- `status`: identificação do estado do pedido (completo ou pendente). Foi utilizado o tipo `string` em OCaml.
- `origin`: identificação da origem do pedido (online ou loja física). Foi utilizado o tipo `string` em OCaml.

### Tabela `OrderItem`

Na tabela `OrderItem` estão disponíveis os seguintes dados:
- `order_id`: identificador do pedido, e chave estrangeira com a tabela `Order`. Foi utilizado o tipo `int` em OCaml. 
- `product_id`: identificador do produto comprado. Foi utilizado o tipo `int` em OCaml.
- `quantity`: quantidade comprada no pedido. Foi utilizado o tipo `int` em OCaml.
- `price`: preço unitário do produto. Foi utilizado o tipo `float` em OCaml.
- `tax`: taxa (percentual) de impostos no pedido. Foi utilizado o tipo `float` em OCaml. 

## Fase 2: Extração

Após a definição dos tipos de acordo com a leitura dos dados, foi possível elaborar os módulos de extração de dados (inicialmente, apenas dos arquivos CSV localmente salvos). Para isso, foram criadas funções de leitura dos arquivos CSV e funções auxiliares de parsing, para transformar cada linha lida do arquivo CSV em um `Record` previamente definido.

### Módulos `Extract_orders` e `Extract_items`

Os dois módulos foram separados de forma a melhorar a legibilidade do código e a organização, utilizando arquivos de interface `.mli` para documentação e para expor apenas as funções necessárias de uso externo. Os módulos contém a lógica para extrair dados das tabelas `Order` e `OrderItem`, respectivamente. As implementações podem ser encontradas em [`etl_project/lib/extract_orders.ml`](etl_project/lib/extract_orders.ml) e [`etl_project/lib/extract_items.ml`](etl_project/lib/extract_items.ml). 

### Funções de Parsing

As funções de parsing foram responsáveis por converter uma lista de `strings` (formato do qual a biblioteca `csv` carrega os dados) em um `Record` do tipo correspondente, criado na Fase 1. Essas funções retornam um valor `order` ou `order_item` se for bem sucedido, ou `None` caso contrário (se a linha possuir um número incorreto de colunas, ou se a conversão de tipos falhar, por exemplo). As funções utilizam *pattern matching* para verificar se a linha do CSV possui o número esperado de colunas, e tenta converter as `strings` para cada um dos tipos definidos. 

### Funções de Carregamento

As funções de carregamento são impuras e realizam operações *I/O*. Elas são responsáveis por ler os arquivos CSV utilizando a biblioteca `csv` e aplicam as funções de parsing para converter cada linha em um record. Também implementam tratamento de erros. 

## Fase 3: Transformação Inicial

A transformação é onde se aplica a lógica de negócio do ETL, transformando os dados extraídos na Fase 2, filtrando, e agregando. As implementações podem ser encontradas em [`etl_project/lib/transformation_v1.ml`](etl_project/lib/transformation_v1.ml) (não utilizada na pipeline final). Todas as funções nessa fase são puras, garantindo que a transformação de dados seja determinística e facilitando a manutenção. 

### Funções de Cálculo

Dentro do módulo, foram definidas funções auxiliares para realizar cálculos específicos, como calcular a receita e valor do imposto para cada item de um pedido, e agregar a receita e imposto para somar os valores correspontentes para o total do pedido utilizando a *high-order function* `fold_left`. 

### Função de Processamento Principal

Na primeira versão, os pedidos são processados separadamente em uma função que utiliza `filter` e `map` para, respectivamente, separar os pedidos, e aplicar as funções de cálculo em cada pedido. Essa função será a etapa de cálculo da função principal de transformação, que recebe os pedidos, os tens de cada pedido, os critérios de filtro (como *status* e *origem*) e vai aplicar os filtros no pedido, processar cada pedido, e retornar a lista final de `output_record`. 

O `output_record` é um tipo criado nessa fase que contém as informações necessárias na saída da pipeline: 
- `order_id`: identificador do pedido (tipo `int`).
- `total_amount`: valor total do pedido (tipo `float`). 
- `total_taxes`: valor total de impostos no pedido (tipo `float`).

## Fase 4: Carga

A fase de carga é a etapa final da pipeline de ETL, persistindo os dados gerados na Fase 3 e salvando-os em um arquivo CSV, inicialmente. A carga está implementada no arquivo [`etl_project/lib/loading.ml`](etl_project/lib/loading.ml). 

### Funções 

A função `format_output_record` é responsável por formatar o `output_record` definido anteriormente em uma lista de `strings` para ser escrita em uma linha do CSV. 

A função `write_output_csv` é a principal do módulo, e responsável por escrever a lista gerada na função anterior em um arquivo CSV no caminho especificado. A função recebe uma lista de `output_record` e um caminho para o arquivo de saída, aplica a formatação para cada item utilizando a função de alta ordem `map`, e escreve a saída no arquivo CSV. Também implementa tratamento de erros. 

## Fase 5: otimização da transformação ("Inner Join")

Para otimizar a transformação dos dados, foi implementada a técnica de "Inner Join" utilizando a estrutura de dados `Map` em OCaml. A implementação inicial realizava uma iteração completa na lista de itens para cada pedido processado, e a otimização visa reduzir a complexidade, já que o `Map` permite buscas mais eficientes. Isso permite trabalhar com um maior volume de dados sem aumentar a complexidade de tempo da execução. A implementação pode ser encontrada em [`etl_project/lib/transformation.ml`](etl_project/lib/transformation.ml)

### Utilização de `Map` (Módulo `OrderMap`)

O módulo `Map` foi utilizado para criar um mapa onde as chaves são do tipo inteiro, representando o identificador de cada pedido. As funções para buscar as chaves são otimizadas. 

### Funções

A função `group_items_by_order_id` utiliza a *high-order function* `fold_left` para iterar sobre a lista de pedidos. Para cada um, extrai o identificador, busca no mapa criado e, se já existe, o item atual é adicionado à lista existente. Se não, cria uma nova lista para aquele pedido e adiciona o item atual. 

A função `transform_data` foi refeita para utilizar o mapa criado. A principal mudança é que, em vez de filtrar a lista completa de itens para cada pedido, a versão otimizada busca diretamente no mapa a lista correspondente a cada identificador de pedido. 

## Fase 6: implementação de Testes Unitários

Nesta fase, foram implementados testes unitários para as *funções puras* do projeto, utilizando o framework `OUnit`. O objetivo dos testes é garantir que as funções puras se comportem conforme o esperado, de maneira determinística, proporcionando confiabilidade e facilitando a manutenção. 

### Estrutura dos testes

Os testes estão organizados no diretório `test`, e podem ser visualizados em [`etl_project/test/test.ml`](etl_project/test/test.ml). Estão integrados ao sistema de compilação do `dune` e foram criados casos para verificar:

- **Funções de Parsing:**  
  - Validação da conversão correta de linhas CSV para registros do tipo `order_item` e `order`, tanto para casos válidos quanto para casos em que a conversão deve falhar (por exemplo, devido a dados mal formatados ou número incorreto de colunas).
  
- **Funções de Formatação:**  
  - Verificação da formatação de registros de saída (`output_record`) para a escrita em CSV, garantindo que os números sejam exibidos com o número correto de casas decimais.

- **Funções de Cálculo:**  
  - Testes para as funções `calculate_item_values` e `sum_item_values`, assegurando que os valores de receita e impostos são calculados corretamente.

- **Funções de Agrupamento e Transformação:**  
  - Verificação do agrupamento dos itens por `order_id` e da transformação dos dados brutos em registros agregados (aplicando filtros de status e origem).

## Fase 7: implementação de funções de leitura via HTTP

Foi implementada a extração de dados diretamente da internet. Nessa fase, em vez de depender de arquivos CSV locais, o sistema realiza requisições HTTP para obter dados de itens e pedidos de uma URL. 

A implementação utiliza a biblioteca `cohttp-lwt-unix`, que possibilita requisições assíncronas via protocolo HTTP. Foram criadas funções específicas para essa finalidade:

- **Extração de Pedidos:**  
  A função `read_csv_orders_from_url` realiza uma requisição GET para a URL informada, converte o corpo da resposta em string e, em seguida, utiliza as funções da biblioteca `csv` para transformar o conteúdo em uma lista de linhas. Cada linha é processada pela função `parse_order_row` para gerar um registro do tipo `order`.

- **Extração de Itens:**  
  De forma análoga, a função `read_csv_order_items_from_url` extrai os dados de itens do pedido.

## Fase 8: implementação de carga de dados em Banco de Dados `Sqlite3`

A etapa final da pipeline consiste na carga dos dados transformados em um banco de dados `Sqlite3`. Isso garante a persistência dos resultados em formato estruturado. 

Para essa fase, foi desenvolvido o módulo `Loading_sqlite`, disponível em [`etl_project/lib/loading_sqlite.ml`](etl_project/lib/loading_sqlite.ml) que realiza as seguintes operações:

- **Abertura e Criação do Banco:**  
  A função `write_output_db` abre (ou cria) o banco de dados SQLite no caminho especificado e garante a existência da tabela `output`, que armazena os registros processados.

- **Inserção dos Registros:**  
  Cada registro do tipo `output_record` é inserido na tabela utilizando instruções parametrizadas. O processo cuida do tratamento de erros e da finalização da conexão.

## Finalização: Estrutura do Executável Principal

O executável principal, presente em [`etl_project/bin/main.ml`](etl_project/bin/main.ml), implementa a pipeline completa de ETL, primeiro extraindo os dados, depois tratando e transformando, e por fim carregando os resultados. O arquivo é feito para permitir que a execução seja personalizada com argumentos de linha de comando, não sendo necessário compilar novamente o projeto para alterar alguma configuração, como origem dos dados, local em que a base ou arquivo CSV serão criados, etc. 

A utilização do projeto, após ser compilado, é dada utilizando a seguinte linha de comando:

```sh
dune exec etl_project -- --orders-url <LINK DO CSV DE PEDIDOS> --items-url <LINK DO CSV DE ITENS> --sqlite-path <CAMINHO PARA BASE DE DADOS> --csv-output <CAMINHO PARA CSV COM RESULTADOS>
```

O comando é apenas um exemplo, considerando que o usuário irá ler os arquivos via Internet. É possível utilizar os argumentos `--orders-local` e `--items-local` para ler arquivos locais. 

## Apêndice: sobre o uso de inteligência artificial 

Para a execução do projeto, foram utilizadas ferramentas de inteligência artificial. O uso é descrito a seguir:
- GitHub Copilot: utilizado para completar linhas de código
- ChatGPT e Gemini: utilizados para:
    - Fornecer um passo-a-passo para a execução do projeto
    - Fornecer as funções de extração e carregamento de dados
    - Auxiliar a depurar erros de compilação obtidos
    - Auxiliar na elaboração de testes unitários
    - Auxiliar no refinamento do relatório

Em resumo, essas ferramentas foram importantes para fornecer um guia geral de como realizar as implementações, e como depurar o código com maior qualidade quando necessário. 