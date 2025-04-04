open Types

module OrderMap : Map.S with type key = int

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


(** [calculate_item_values item] é uma função auxiliar pura que calcula a receita e o valor do imposto para um único item.
    A receita é calculada multiplicando o preço do item pela sua quantidade, e o imposto é determinado pela aplicação do
    percentual de imposto sobre a receita, dividido por 100.
    
    @param item Um registro [order_item] contendo os campos [price], [quantity] e [tax].
    @return Uma tupla (receita, valor_do_imposto) do tipo (float * float). *)
val calculate_item_values : order_item -> float * float


(** [sum_item_values values] é uma função auxiliar pura que soma uma lista de tuplas (receita, valor_do_imposto).
    Utiliza a função [List.fold_left] para agregar os valores, retornando a soma total das receitas e dos impostos.
    
    @param values Uma lista de tuplas (receita, valor_do_imposto) do tipo (float * float) list.
    @return Uma tupla (total_receita, total_imposto) representando os valores somados de receita e imposto. *)
val sum_item_values : (float * float) list -> float * float


(** [group_items_by_order_id items] é uma função auxiliar pura que agrupa os itens de pedidos por seu [order_id] em um mapa.
    
    Essa função percorre a lista de [order_item] e utiliza o [order_id] como chave para agrupar os itens associados.
    
    @param items Uma lista de registros [order_item] a serem agrupados.
    @return Um mapa (do tipo [OrderMap.t]) em que cada chave [order_id] está associada a uma lista de [order_item]. *)
val group_items_by_order_id : order_item list -> order_item list OrderMap.t 