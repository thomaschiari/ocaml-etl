open Types

(** [write_output_db db_path data] salva os dados de saída em um banco de dados SQLite.
    
    A função abre (ou cria) o banco no caminho [db_path], cria a tabela [output] se ela não existir,
    e insere cada registro da lista [data] na tabela.
    
    @param db_path O caminho para o arquivo do banco de dados SQLite.
    @param data A lista de registros [output_record] a ser salva.
    @return [Ok ()] se a operação for bem-sucedida, ou [Error mensagem] caso ocorra algum erro. *)
val write_output_db : string -> output_record list -> (unit, string) result
