open Types 

(** Pure helper: Calculate revenue and tax amount for a single item. *)
let calculate_item_values (item : order_item) : (float * float) =
  let revenue = item.price *. (float_of_int item.quantity) in
  let tax_amount = revenue *. item.tax /. 100.0 in
  (revenue, tax_amount)

(** Pure helper: Sums a list of (revenue, tax_amount) tuples. Uses fold (reduce). *)
let sum_item_values (values : (float * float) list) : (float * float) =
  List.fold_left
    (fun (acc_amount, acc_tax) (rev, tax) -> (acc_amount +. rev, acc_tax +. tax))
    (0.0, 0.0)
    values

(** Processes a single order: finds its items, calculates totals. (Pure)
    This version iterates through the *full* item list for each order. *)
let process_single_order (order : order) (all_items : order_item list) : output_record option =
  let order_items = List.filter (fun item -> item.order_id = order.id) all_items in
  let item_values = List.map calculate_item_values order_items in
  let total_amount, total_taxes = sum_item_values item_values in
  if List.length order_items > 0 then
      Some { order_id = order.id; total_amount; total_taxes }
  else
      None     

(** Main transformation function orchestrating the steps. *)
let transform_data ~target_status ~target_origin (orders : order list) (items : order_item list) : output_record list =
  let filtered_orders =
    List.filter
      (fun order -> order.status = target_status && order.origin = target_origin)
      orders
  in
  List.filter_map (fun order -> process_single_order order items) filtered_orders