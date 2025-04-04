open Types

(** [read_csv_orders csv_path] realiza a leitura dos dados de pedidos a partir do arquivo CSV localizado em [csv_path].
    A função ignora o cabeçalho do arquivo e retorna apenas os registros [order] que foram parseados com sucesso.
    
    @param csv_path O caminho para o arquivo CSV contendo os dados dos pedidos.
    @return Uma lista de registros [order] representando os pedidos válidos presentes no arquivo. *)
val read_csv_orders : string -> order list