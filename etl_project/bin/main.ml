open Etl

let orders_url = ref ""
let items_url = ref ""
let target_status = ref "Complete"
let target_origin = ref "O"
let sqlite_path = ref "data/processed/output.db"

let speclist = [
    ("--orders-url", Arg.Set_string orders_url, "URL do arquivo CSV de pedidos");
    ("--items-url", Arg.Set_string items_url, "URL do arquivo CSV de itens de pedidos");
    ("--target-status", Arg.Set_string target_status, "Status alvo dos pedidos (default: Complete)");
    ("--target-origin", Arg.Set_string target_origin, "Origem alvo dos pedidos (default: O)");
    ("--sqlite-path", Arg.Set_string sqlite_path, "Caminho para o banco de dados SQLite (default: data/processed/output.db)");
]

let usage_msg = "Uso: dune exec etl_project --orders-url <url> --items-url <url> [opções]"

let main () =
    Arg.parse speclist print_endline usage_msg;
    
    if !orders_url = "" || !items_url = "" then
        (Printf.eprintf "Erro: --orders-url e --items-url são obrigatórios.\n";
         exit 1);
    
    let orders_lwt = Extract_orders.read_csv_orders_from_url !orders_url in
    let items_lwt = Extract_items.read_csv_order_items_from_url !items_url in
    let orders = Lwt_main.run orders_lwt in
    let items = Lwt_main.run items_lwt in

    let output_records = 
        Transformation.transform_data
            ~target_status:!target_status
            ~target_origin:!target_origin
            orders items
    in

    match Loading_sqlite.write_output_db !sqlite_path output_records with
    | Ok () -> Printf.printf "Dados salvos com sucesso no banco de dados %s\n" !sqlite_path
    | Error msg -> Printf.eprintf "Erro ao salvar dados: %s\n" msg;
    exit 0

let () = main ()