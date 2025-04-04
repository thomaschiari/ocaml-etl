(* lib/extraction_orders.mli *)

open Types

(** Loads order data from a CSV file path.

    @param csv_path The path to the orders CSV file.
    @return A list of successfully parsed [order] records.
*)
val read_csv_orders : string -> order list