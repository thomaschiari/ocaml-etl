(** Representa a saída esperada da pipeline de transformação. *)
type output_record = {
  or_order_id: int;
  total_amount: float;
  total_taxes: float;
}

(** Representa um item único dentro de um pedido a partir do CSV de entrada. *)
type order_item = {
  order_id: int;
  product_id: int;
  quantity: int;
  price: float;
  tax: float; 
} 

(** Representa um registro de pedido único a partir do CSV de entrada. *)
type order = {
  id: int;
  client_id: int;
  order_date: string; 
  status: string;
  origin: string; 
} 