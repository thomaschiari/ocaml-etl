open Types 

(** [calculate_item_values item] is a pure helper function that computes the revenue and tax amount
    for a given order item.
    
    The revenue is calculated as the product of the item price and its quantity. The tax amount is
    computed as the revenue multiplied by the tax percentage divided by 100.
    
    @param item An [order_item] record containing price, quantity, and tax percentage.
    @return A tuple [(revenue, tax_amount)] where:
            - [revenue] is the total revenue for the item.
            - [tax_amount] is the calculated tax for the revenue.
*)
let calculate_item_values (item : order_item) : (float * float) =
  let revenue = item.price *. (float_of_int item.quantity) in
  let tax_amount = revenue *. item.tax in
  (revenue, tax_amount)


(** [sum_item_values values] is a pure helper function that aggregates a list of (revenue, tax_amount)
    tuples by summing the individual revenues and tax amounts.
    
    This function uses [List.fold_left] to reduce the list to a single tuple representing the totals.
    
    @param values A list of tuples, each containing the revenue and tax amount for an item.
    @return A tuple [(total_revenue, total_tax)] representing the summed values across all items.
*)
let sum_item_values (values : (float * float) list) : (float * float) =
  List.fold_left
    (fun (acc_amount, acc_tax) (rev, tax) -> (acc_amount +. rev, acc_tax +. tax))
    (0.0, 0.0)
    values


(** [process_single_order order all_items] is a pure function that processes a single order by:
    - Filtering all order items that belong to the order.
    - Calculating the revenue and tax amount for each item.
    - Summing these values to obtain the total revenue and total tax for the order.
    
    If the order has at least one associated item, the function returns [Some output_record] with the 
    order id, total amount, and total taxes; otherwise, it returns [None].
    
    @param order An [order] record representing the order to be processed.
    @param all_items A list of [order_item] records representing all available order items.
    @return [Some output_record] if the order has associated items, or [None] if no items were found.
*)
let process_single_order (order : order) (all_items : order_item list) : output_record option =
  let order_items = List.filter (fun item -> item.order_id = order.id) all_items in
  let item_values = List.map calculate_item_values order_items in
  let total_amount, total_taxes = sum_item_values item_values in
  if List.length order_items > 0 then
      Some { order_id = order.id; total_amount; total_taxes }
  else
      None     



(** [transform_data ~target_status ~target_origin orders items] is the main transformation function that:
    - Filters the list of orders based on the specified [target_status] and [target_origin].
    - Processes each filtered order to compute the total revenue and tax using [process_single_order].
    
    The result is a list of [output_record] values corresponding to the orders that meet the criteria and 
    have at least one associated item.
    
    @param ~target_status The status that an order must have to be included in the transformation.
    @param ~target_origin The origin that an order must have to be included in the transformation.
    @param orders A list of [order] records to be filtered and processed.
    @param items A list of [order_item] records representing all items across orders.
    @return A list of [output_record] values for orders that have been successfully processed.
*)
let transform_data ~target_status ~target_origin (orders : order list) (items : order_item list) : output_record list =
  let filtered_orders =
    List.filter
      (fun order -> order.status = target_status && order.origin = target_origin)
      orders
  in
  List.filter_map (fun order -> process_single_order order items) filtered_orders