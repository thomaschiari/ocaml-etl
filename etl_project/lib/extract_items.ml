open Types

(** Helper function (pure) to parse a single CSV row into an order_item record.
    Returns None if parsing fails. *)
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
       | _, _, _, _, _ -> None (* Failed conversion *)
      )
  | _ -> None (* Incorrect number of columns *)

(** Loads order item data from a CSV file. (Impure due to I/O)
    Skips the header of the CSV file. *)
let read_csv_order_items (csv_path : string) : order_item list =
  let csv_content = Csv.load csv_path in
  let csv_rows = List.tl csv_content in
  List.filter_map parse_order_item_row csv_rows
