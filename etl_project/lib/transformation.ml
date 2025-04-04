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

module OrderMap = Map.Make(Int)

(** Pure helper: Groups order items by their order_id into a Map. *)
let group_items_by_order_id (items : order_item list) : order_item list OrderMap.t =
  List.fold_left
    (fun acc_map item ->
      let order_id = item.order_id in
      (* Find existing items for this order_id, default to empty list if not found *)
      let current_items = OrderMap.find_opt order_id acc_map |> Option.value ~default:[] in
      (* Add the new item to the list and update the map *)
      OrderMap.add order_id (item :: current_items) acc_map
    )
    OrderMap.empty
    items

(** Main transformation function - Optimized Version using Map. *)
let transform_data ~target_status ~target_origin (orders : order list) (items : order_item list) : output_record list =
  (* 1. Pre-process: Group items by order_id once *)
  let item_map = group_items_by_order_id items in

  (* 2. Filter Orders: Keep only orders matching the target status and origin *)
  let filtered_orders =
    List.filter
      (fun order -> order.status = target_status && order.origin = target_origin)
      orders
  in

  (* 3. Map & Process: Iterate through filtered orders and process using the map *)
  List.filter_map
    (fun order ->
      (* Find items for this order efficiently using the map *)
      match OrderMap.find_opt order.id item_map with
      | Some items_for_this_order ->
          (* Calculate values for these specific items *)
          let item_values = List.map calculate_item_values items_for_this_order in
          (* Sum the values *)
          let total_amount, total_taxes = sum_item_values item_values in
          (* Create the output record *)
          Some { order_id = order.id; total_amount; total_taxes }
      | None ->
          (* No items found for this order_id in the map. Skip this order. *)
          (* This might happen if an order exists but has zero items associated. *)
          None
    )
    filtered_orders