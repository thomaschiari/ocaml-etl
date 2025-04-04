open Types

(** [format_output_record record] é uma função auxiliar pura que converte um [output_record]
    em uma lista de strings formatadas para escrita em CSV.
    
    Essa função converte o campo [order_id] para string e formata os campos [total_amount] e
    [total_taxes] com duas casas decimais, utilizando [Printf.sprintf].
    
    @param record O registro de saída que deverá ser formatado.
    @return Uma lista de strings representando o registro formatado para CSV.
*)
let format_output_record (record : output_record) : string list =
  [
    string_of_int record.order_id;
    Printf.sprintf "%.2f" record.total_amount; 
    Printf.sprintf "%.2f" record.total_taxes;  
  ]


(** [write_output_csv filepath data] grava os dados processados em um arquivo CSV no caminho [filepath].
    
    A função inclui uma linha de cabeçalho e utiliza [format_output_record] para converter cada
    [output_record] em uma lista de strings. Por realizar operações de I/O, esta função é considerada impura.
    
    @param filepath O caminho onde o arquivo CSV será criado ou sobrescrito.
    @param data A lista de registros [output_record] a ser gravada no arquivo.
    @return [Ok ()] em caso de sucesso ou [Error string] se ocorrer algum erro durante a gravação.
*)
let write_output_csv (filepath : string) (data : output_record list) : (unit, string) result =
  try
    let header = ["order_id"; "total_amount"; "total_taxes"] in
    let rows = List.map format_output_record data in
    let csv_output_data = header :: rows in
    Csv.save filepath csv_output_data;
    Ok ()
  with
  | Sys_error msg -> Error (Printf.sprintf "Error writing file %s: %s" filepath msg)
  | ex -> Error (Printf.sprintf "An unexpected error occurred saving %s: %s" filepath (Printexc.to_string ex))