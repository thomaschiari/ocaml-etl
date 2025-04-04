open Types

(** Helper function (pure) to parse a single CSV row into an order record.
    Returns None if parsing fails (wrong number of columns, type conversion error). *)
let parse_order_row (row: string list) : order option =
  match row with
  | [id_str; client_id_str; order_date; status; origin] ->
    (match int_of_string_opt id_str, int_of_string_opt client_id_str with
    | Some id, Some client_id ->
      Some {
        id;
        client_id;
        order_date;
        status;
        origin;
      }
    | _, _ -> None
    )
  | _ -> None

(** Loads order data from a CSV file. (Impure due to I/O)
    Skips the header of the CSV file. *)
let read_csv_orders (csv_path: string) : order list =
  let csv_content = Csv.load csv_path in
  let csv_rows = List.tl csv_content in
  List.filter_map parse_order_row csv_rows