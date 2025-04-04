open Types

(** [parse_order_row row] é uma função auxiliar (pura) que tenta converter uma linha de um arquivo CSV
    em um registro [order]. A função espera que a linha seja uma lista com exatamente cinco elementos, 
    que correspondem, respectivamente, ao identificador do pedido, identificador do cliente, data do pedido, 
    status e origem.

    Se as conversões dos identificadores (de [string] para [int]) forem bem-sucedidas, a função retorna 
    [Some order] contendo o registro preenchido; caso contrário, retorna [None]. Essa função também retorna 
    [None] se o número de colunas não for o esperado.

    @param row Uma lista de strings que representa uma linha do CSV.
    @return Um [order option] com o registro parseado ou [None] em caso de falha. *)
let parse_order_row (row: string list) : order option =
  match row with
  | [id_str; client_id_str; order_date; status; origin] ->
    (match int_of_string_opt id_str, int_of_string_opt client_id_str with
    | Some id, Some client_id ->
      Some {
        id;
        client_id;
        order_date;
        status;
        origin;
      }
    | _, _ -> None
    )
  | _ -> None


(** [read_csv_orders csv_path] realiza a leitura dos dados de pedidos a partir do arquivo CSV localizado em [csv_path].
    Essa função ignora a primeira linha do arquivo (cabeçalho) e utiliza [parse_order_row] para converter cada linha 
    do CSV em um registro [order]. Como realiza operações de I/O, esta função é considerada impura.
    
    @param csv_path O caminho para o arquivo CSV contendo os dados dos pedidos.
    @return Uma lista de registros [order] obtidos a partir do arquivo, considerando apenas as linhas válidas. *)
let read_csv_orders (csv_path: string) : order list =
  let csv_content = Csv.load csv_path in
  let csv_rows = List.tl csv_content in
  List.filter_map parse_order_row csv_rows