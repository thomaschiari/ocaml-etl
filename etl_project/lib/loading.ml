(* lib/loading.ml *)

open Types

(** Pure helper: Formats an output_record into a list of strings for CSV writing. *)
let format_output_record (record : output_record) : string list =
  [
    string_of_int record.order_id;
    Printf.sprintf "%.2f" record.total_amount; (* Format float to 2 decimal places *)
    Printf.sprintf "%.2f" record.total_taxes;  (* Format float to 2 decimal places *)
  ]

(** Writes the processed data to a CSV file. (Impure due to I/O) *)
let write_output_csv (filepath : string) (data : output_record list) : (unit, string) result =
  try
    (* Define the header row *)
    let header = ["order_id"; "total_amount"; "total_taxes"] in

    (* Convert list of records to list of string lists *)
    let rows = List.map format_output_record data in

    (* Combine header and rows *)
    let csv_output_data = header :: rows in

    (* Use Csv.save to write the data to the file *)
    Csv.save filepath csv_output_data;

    (* Return Ok on success *)
    Ok ()
  with
  | Sys_error msg -> Error (Printf.sprintf "Error writing file %s: %s" filepath msg)
  | ex -> Error (Printf.sprintf "An unexpected error occurred saving %s: %s" filepath (Printexc.to_string ex))