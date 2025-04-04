open Types

(** [read_csv_order_items filepath] realiza a leitura dos dados de itens de pedidos a partir do arquivo CSV
    localizado em [filepath]. A função ignora o cabeçalho e retorna apenas os registros que foram
    parseados com sucesso.
    
    @param filepath O caminho para o arquivo CSV contendo os dados dos itens do pedido.
    @return Uma lista de registros [order_item] correspondentes às linhas válidas do arquivo. *)
val read_csv_order_items : string -> order_item list


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
val parse_order_item_row : string list -> order_item option