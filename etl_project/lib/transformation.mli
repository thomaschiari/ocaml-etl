open Types

(** [transform_data ~target_status ~target_origin orders items] transforma os dados brutos de pedidos e itens 
    no formato final agregado.

    Esta função filtra os pedidos com base no status e na origem fornecidos e, em seguida, calcula o total de
    receita e de impostos para cada pedido, somando as contribuições de seus respectivos itens.
    
    @param target_status O status desejado dos pedidos a serem incluídos (por exemplo, "complete").
    @param target_origin A origem desejada dos pedidos a serem incluídos (por exemplo, "O" para online).
    @param orders A lista completa de registros [order] carregados da entrada.
    @param items A lista completa de registros [order_item] carregados da entrada.
    @return Uma lista de registros [output_record] contendo os dados agregados dos pedidos filtrados.
*)
val transform_data :
  target_status:string ->
  target_origin:string ->
  order list ->
  order_item list ->
  output_record list