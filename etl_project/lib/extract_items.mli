open Types

(** [read_csv_order_items filepath] realiza a leitura dos dados de itens de pedidos a partir do arquivo CSV
    localizado em [filepath]. A função ignora o cabeçalho e retorna apenas os registros que foram
    parseados com sucesso.
    
    @param filepath O caminho para o arquivo CSV contendo os dados dos itens do pedido.
    @return Uma lista de registros [order_item] correspondentes às linhas válidas do arquivo. *)
val read_csv_order_items : string -> order_item list