(* lib/types.ml *)

(** Represents the expected output of transformation pipeline. *)
type output_record = {
  order_id: int;
  total_amount: float;
  total_taxes: float;
}

(** Represents a single order record from the input CSV. *)
type order = {
  id: int;
  client_id: int;
  order_date: string; (* ISO 8601 format as string *)
  status: string;
  origin: string; (* "P" or "O" *)
} 

(** Represents a single item within an order from the input CSV. *)
type order_item = {
  order_id: int;
  product_id: int;
  quantity: int;
  price: float;
  tax: float; (* Tax percentage, e.g., 5.0 for 5% *)
} 