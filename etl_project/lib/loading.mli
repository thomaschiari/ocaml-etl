open Types 

(** Writes the processed output data to a CSV file.

    This function takes a list of output records and saves them to the specified
    file path. It includes a header row.

    @param filepath The path where the output CSV file will be created/overwritten.
    @param data The list of [output_record] to write.
    @return [Ok ()] on success, or [Error string] if an I/O or CSV error occurs.
*)
    val write_output_csv : string -> output_record list -> (unit, string) result