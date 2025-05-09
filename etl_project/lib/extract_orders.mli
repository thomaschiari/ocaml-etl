open Types

(** [read_csv_orders csv_path] realiza a leitura dos dados de pedidos a partir do arquivo CSV localizado em [csv_path].
    A função ignora o cabeçalho do arquivo e retorna apenas os registros [order] que foram parseados com sucesso.
    
    @param csv_path O caminho para o arquivo CSV contendo os dados dos pedidos.
    @return Uma lista de registros [order] representando os pedidos válidos presentes no arquivo. *)
val read_csv_orders : string -> order list


(** [parse_order_row row] é uma função auxiliar (pura) que tenta converter uma linha de um arquivo CSV
    em um registro [order]. A função espera que a linha seja uma lista com exatamente cinco elementos, 
    que correspondem, respectivamente, ao identificador do pedido, identificador do cliente, data do pedido, 
    status e origem.

    Se as conversões dos identificadores (de [string] para [int]) forem bem-sucedidas, a função retorna 
    [Some order] contendo o registro preenchido; caso contrário, retorna [None]. Essa função também retorna 
    [None] se o número de colunas não for o esperado.

    @param row Uma lista de strings que representa uma linha do CSV.
    @return Um [order option] com o registro parseado ou [None] em caso de falha. *)
val parse_order_row : string list -> order option


(** [read_csv_orders_from_url url] realiza a leitura dos dados de pedidos a partir de um arquivo CSV 
    disponível na internet, acessado via HTTP GET.
    
    A função realiza uma requisição para a URL fornecida, converte o corpo da resposta para string, 
    utiliza [Csv.of_string] para transformar esse conteúdo em uma lista de linhas (cada linha é uma lista de strings),
    ignora o cabeçalho e, em seguida, aplica [parse_order_row] para converter cada linha em um registro [order].
    
    @param url A URL onde o arquivo CSV está disponível.
    @return Uma promessa ([order list Lwt.t]) que, quando resolvida, retorna uma lista de registros [order]. *)
val read_csv_orders_from_url : string -> order list Lwt.t