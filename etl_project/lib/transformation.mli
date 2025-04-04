open Types

(** Transforms raw order and item data into the final aggregated output format.

    This function filters orders based on the provided status and origin,
    then calculates the total amount and total taxes for each matching order
    by summing the contributions of its corresponding items.

    @param target_status The desired order status to include (e.g., "complete").
    @param target_origin The desired order origin to include (e.g., "O" for online).
    @param orders The full list of order records loaded from the input.
    @param items The full list of order item records loaded from the input.
    @return A list of [output_record] containing the aggregated data for filtered orders.
*)
val transform_data :
  target_status:string ->
  target_origin:string ->
  order list ->
  order_item list ->
  output_record list