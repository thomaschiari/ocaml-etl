open Etl

let orders_url = ref ""
let orders_local = ref ""
let items_url = ref ""
let items_local = ref ""
let target_status = ref "Complete"
let target_origin = ref "O"

let sqlite_path = ref ""
let csv_output_path = ref ""

let speclist = [
  ("--orders-url", Arg.Set_string orders_url, "URL do arquivo CSV de pedidos");
  ("--orders-local", Arg.Set_string orders_local, "Caminho local para o arquivo CSV de pedidos");
  ("--items-url", Arg.Set_string items_url, "URL do arquivo CSV de itens de pedidos");
  ("--items-local", Arg.Set_string items_local, "Caminho local para o arquivo CSV de itens de pedidos");
  ("--target-status", Arg.Set_string target_status, "Status alvo dos pedidos (default: Complete)");
  ("--target-origin", Arg.Set_string target_origin, "Origem alvo dos pedidos (default: O)");
  ("--sqlite-path", Arg.Set_string sqlite_path, "Caminho para o banco de dados SQLite (opcional)");
  ("--csv-output", Arg.Set_string csv_output_path, "Caminho para salvar os dados em um arquivo CSV (opcional)");
]

let usage_msg =
    "Uso: dune exec etl_project -- [--orders-url <url> | --orders-local <caminho>] [--items-url <url> | --items-local <caminho>] [--target-status <status>] [--target-origin <origem>] [--sqlite-path <caminho>] [--csv-output <caminho>]"
  

let main () =
  Arg.parse speclist print_endline usage_msg;

  if (!orders_url = "" && !orders_local = "") || (!items_url = "" && !items_local = "") then (
    Printf.eprintf "Erro: Informe pelo menos uma fonte para orders (--orders-url ou --orders-local) e para items (--items-url ou --items-local).\n";
    exit 1
  );

  let orders =
    if !orders_local <> "" then
      Extract_orders.read_csv_orders !orders_local
    else
      Lwt_main.run (Extract_orders.read_csv_orders_from_url !orders_url)
  in

  let items =
    if !items_local <> "" then
      Extract_items.read_csv_order_items !items_local
    else
      Lwt_main.run (Extract_items.read_csv_order_items_from_url !items_url)
  in

  let output_records =
    Transformation.transform_data
      ~target_status:!target_status
      ~target_origin:!target_origin
      orders items
  in

  if !sqlite_path <> "" then (
    match Loading_sqlite.write_output_db !sqlite_path output_records with
    | Ok () -> Printf.printf "Dados salvos com sucesso no banco de dados %s\n" !sqlite_path
    | Error msg -> Printf.eprintf "Erro ao salvar no SQLite: %s\n" msg
  );

  if !csv_output_path <> "" then (
    match Loading.write_output_csv !csv_output_path output_records with
    | Ok () -> Printf.printf "Dados salvos com sucesso no arquivo CSV %s\n" !csv_output_path
    | Error msg -> Printf.eprintf "Erro ao salvar no CSV: %s\n" msg
  );

  exit 0

let () = main ()