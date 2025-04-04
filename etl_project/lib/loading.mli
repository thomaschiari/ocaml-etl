open Types 

(** [write_output_csv filepath data] grava os dados processados em um arquivo CSV.

    Essa função recebe uma lista de registros de saída ([output_record]), adiciona uma linha de cabeçalho e
    salva os dados formatados no arquivo especificado por [filepath]. Por realizar operações de I/O, a função
    é considerada impura.
    
    @param filepath O caminho onde o arquivo CSV será criado ou sobrescrito.
    @param data A lista de [output_record] a ser gravada.
    @return [Ok ()] se a gravação for bem-sucedida, ou [Error string] se ocorrer um erro durante a escrita.
*)
    val write_output_csv : string -> output_record list -> (unit, string) result