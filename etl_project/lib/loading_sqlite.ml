open Types
open Sqlite3

(** [write_output_db db_path data] salva os dados de saída em um banco de dados SQLite.
    A função abre (ou cria) o banco de dados no caminho [db_path], cria a tabela [output] se ela não existir,
    e insere cada registro de [data] na tabela.
    
    @param db_path O caminho para o arquivo do banco de dados SQLite.
    @param data A lista de registros [output_record] a ser salva.
    @return Um valor do tipo (unit, string) result, indicando [Ok ()] em caso de sucesso ou [Error mensagem] em caso de falha. *)
let write_output_db (db_path: string) (data: output_record list) : (unit, string) result =
  let db = db_open db_path in 
  match exec db "CREATE TABLE IF NOT EXISTS output (order_id INTEGER, total_amount REAL, total_taxes REAL);" with
  | Rc.OK ->
    let stmt = prepare db "INSERT INTO output (order_id, total_amount, total_taxes) VALUES (?, ?, ?);" in
    let rec insert_rows = function
      | [] ->
        finalize stmt |> ignore;
        Ok ()
      | record :: rest ->
        bind stmt 1 (Data.INT (Int64.of_int record.or_order_id)) |> ignore;
        bind stmt 2 (Data.FLOAT record.total_amount) |> ignore;
        bind stmt 3 (Data.FLOAT record.total_taxes) |> ignore;
        begin 
          match step stmt with
          | Rc.DONE -> 
            reset stmt |> ignore;
            insert_rows rest
          | rc ->
            finalize stmt |> ignore;
            Error (Printf.sprintf "Erro ao inserir registro: %s" (Rc.to_string rc))
        end
    in
    let result = insert_rows data in
    db_close db |> ignore;
    result
  | rc ->
    db_close db |> ignore;
    Error (Printf.sprintf "Erro ao criar tabela: %s" (Rc.to_string rc))