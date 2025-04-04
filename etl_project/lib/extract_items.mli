(* lib/extraction_items.mli *)

open Types

(** Loads order item data from a CSV file path.

    @param filepath The path to the order items CSV file.
    @return A list of successfully parsed [order_item] records.
*)
val read_csv_order_items : string -> order_item list