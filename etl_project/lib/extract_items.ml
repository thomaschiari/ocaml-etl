open Types

open Lwt
open Cohttp_lwt_unix

(** [parse_order_item_row row] é uma função auxiliar (pura) que tenta converter uma
    linha de um arquivo CSV em um registro [order_item]. A função espera que a linha seja uma
    lista com exatamente cinco elementos, representando:
    - o identificador do pedido,
    - o identificador do produto,
    - a quantidade,
    - o preço, e
    - o imposto.

    Se todas as conversões forem bem-sucedidas, retorna [Some order_item]. Caso contrário,
    retorna [None], indicando falha na conversão.
    
    @param row Uma lista de strings que representa uma linha do CSV.
    @return Um [order_item option] com o registro parseado ou [None] se houver erro na conversão. *)
let parse_order_item_row (row : string list) : order_item option =
  match row with
  | [order_id_str; product_id_str; quantity_str; price_str; tax_str] ->
      (match
         int_of_string_opt order_id_str,
         int_of_string_opt product_id_str,
         int_of_string_opt quantity_str,
         float_of_string_opt price_str,
         float_of_string_opt tax_str
       with
       | Some order_id, Some product_id, Some quantity, Some price, Some tax ->
           Some { order_id; product_id; quantity; price; tax }
       | _, _, _, _, _ -> None
      )
  | _ -> None

  
(** [read_csv_order_items csv_path] realiza a leitura de um arquivo CSV contendo os itens do pedido.
    Essa função ignora a primeira linha (cabeçalho) e utiliza [parse_order_item_row] para converter
    cada linha do CSV em um registro [order_item]. Por realizar operações de entrada/saída, esta função
    é considerada impura.
    
    @param csv_path O caminho para o arquivo CSV.
    @return Uma lista de registros [order_item] obtidos a partir do arquivo. *)
let read_csv_order_items (csv_path : string) : order_item list =
  let csv_content = Csv.load csv_path in
  let csv_rows = List.tl csv_content in
  List.filter_map parse_order_item_row csv_rows


(** [read_csv_order_items_from_url url] realiza a leitura dos dados de itens de pedidos a partir de um arquivo CSV
    disponível na internet, acessado via HTTP GET.
    
    A função faz uma requisição para a URL especificada, converte o corpo da resposta para string, utiliza [Csv.of_string]
    para obter as linhas do CSV, ignora o cabeçalho e aplica [parse_order_item_row] para converter cada linha em um registro [order_item].
    
    @param url A URL onde o arquivo CSV está disponível.
    @return Uma promessa ([order_item list Lwt.t]) que, quando resolvida, retorna uma lista de registros [order_item]. *)
let read_csv_order_items_from_url (url: string) : order_item list Lwt.t = 
  Client.get (Uri.of_string url) >>= fun (resp, body) ->
    match Cohttp.Response.status resp with
    | `OK ->
      Cohttp_lwt.Body.to_string body >|= fun body_str ->
        let csv_content = Csv.input_all (Csv.of_string body_str) in 
        let csv_rows = List.tl csv_content in
        List.filter_map parse_order_item_row csv_rows
    | status -> 
      Lwt.fail_with ("Failed to fetch CSV: " ^ (Cohttp.Code.string_of_status status))
