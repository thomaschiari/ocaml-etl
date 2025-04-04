open Types 

(** [calculate_item_values item] é uma função auxiliar pura que calcula a receita e o valor do imposto para um único item.
    A receita é calculada multiplicando o preço do item pela sua quantidade, e o imposto é determinado pela aplicação do
    percentual de imposto sobre a receita, dividido por 100.
    
    @param item Um registro [order_item] contendo os campos [price], [quantity] e [tax].
    @return Uma tupla (receita, valor_do_imposto) do tipo (float * float). *)
let calculate_item_values (item : order_item) : (float * float) =
  let revenue = item.price *. (float_of_int item.quantity) in
  let tax_amount = revenue *. item.tax in
  (revenue, tax_amount)


(** [sum_item_values values] é uma função auxiliar pura que soma uma lista de tuplas (receita, valor_do_imposto).
    Utiliza a função [List.fold_left] para agregar os valores, retornando a soma total das receitas e dos impostos.
    
    @param values Uma lista de tuplas (receita, valor_do_imposto) do tipo (float * float) list.
    @return Uma tupla (total_receita, total_imposto) representando os valores somados de receita e imposto. *)
let sum_item_values (values : (float * float) list) : (float * float) =
  List.fold_left
    (fun (acc_amount, acc_tax) (rev, tax) -> (acc_amount +. rev, acc_tax +. tax))
    (0.0, 0.0)
    values


module OrderMap = Map.Make(Int)


(** [group_items_by_order_id items] é uma função auxiliar pura que agrupa os itens de pedidos por seu [order_id] em um mapa.
    
    Essa função percorre a lista de [order_item] e utiliza o [order_id] como chave para agrupar os itens associados.
    
    @param items Uma lista de registros [order_item] a serem agrupados.
    @return Um mapa (do tipo [OrderMap.t]) em que cada chave [order_id] está associada a uma lista de [order_item]. *)
let group_items_by_order_id (items : order_item list) : order_item list OrderMap.t =
  List.fold_left
    (fun acc_map item ->
      let order_id = item.order_id in
      let current_items = OrderMap.find_opt order_id acc_map |> Option.value ~default:[] in
      OrderMap.add order_id (item :: current_items) acc_map
    )
    OrderMap.empty
    items


(** [transform_data ~target_status ~target_origin orders items] é a função principal de transformação (versão otimizada usando Map).
    
    Esta função realiza os seguintes passos:
    1. Pré-processamento: Agrupa os itens por [order_id] uma única vez.
    2. Filtragem dos pedidos: Seleciona apenas os pedidos cujo status e origem correspondem aos valores [target_status] e [target_origin].
    3. Processamento: Para cada pedido filtrado, busca os itens correspondentes de forma eficiente utilizando o mapa,
       calcula os valores individuais e os soma, gerando um registro de saída ([output_record]).
    
    @param target_status O status desejado que os pedidos devem possuir para serem incluídos (por exemplo, "complete").
    @param target_origin A origem desejada (por exemplo, "O" para online) que os pedidos devem possuir para serem incluídos.
    @param orders A lista completa de registros [order] carregados da entrada.
    @param items A lista completa de registros [order_item] carregados da entrada.
    @return Uma lista de registros [output_record] contendo os dados agregados dos pedidos filtrados. *)
let transform_data ~target_status ~target_origin (orders : order list) (items : order_item list) : output_record list =
  let item_map = group_items_by_order_id items in
  let filtered_orders =
    List.filter
      (fun order -> order.status = target_status && order.origin = target_origin)
      orders
  in
  List.filter_map
    (fun order ->
      match OrderMap.find_opt order.id item_map with
      | Some items_for_this_order ->
          let item_values = List.map calculate_item_values items_for_this_order in
          let total_amount, total_taxes = sum_item_values item_values in
          Some { or_order_id = order.id; total_amount; total_taxes }
      | None ->
          None
    )
    filtered_orders