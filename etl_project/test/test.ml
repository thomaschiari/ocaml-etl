open OUnit2
open Etl.Types
open Etl.Extract_items
open Etl.Extract_orders
open Etl.Loading
open Etl.Transformation

(* Testa a função parse_order_item_row do módulo Extract_items *)
let test_parse_order_item_row_valid _ =
  let row = ["1"; "101"; "2"; "10.50"; "5.0"] in
  let expected = Some { order_id = 1; product_id = 101; quantity = 2; price = 10.50; tax = 5.0 } in
  let result = parse_order_item_row row in
  assert_equal expected result
    ~printer:(function
      | None -> "None"
      | Some r -> Printf.sprintf "Some {order_id=%d; product_id=%d; quantity=%d; price=%.2f; tax=%.2f}"
                      r.order_id r.product_id r.quantity r.price r.tax)

let test_parse_order_item_row_invalid _ =
  let row = ["1"; "101"; "x"; "10.50"; "5.0"] in
  let result = parse_order_item_row row in
  assert_equal None result
  

(* Testa a função parse_order_row do módulo Extract_orders *)
let test_parse_order_row_valid _ =
  let row = ["1"; "101"; "2023-01-01"; "complete"; "O"] in
  let expected = Some { id = 1; client_id = 101; order_date = "2023-01-01"; status = "complete"; origin = "O" } in
  let result = parse_order_row row in
  assert_equal expected result
    ~printer:(function
      | None -> "None"
      | Some o -> Printf.sprintf "Some {id=%d; client_id=%d; order_date=%s; status=%s; origin=%s}"
                      o.id o.client_id o.order_date o.status o.origin)

let test_parse_order_row_invalid _ =
  let row = ["1"; "101"; "2023-01-01"; "complete"] in
  let result = parse_order_row row in
  assert_equal None result


(* Testa a função format_output_record do módulo Loading *)
let test_format_output_record _ =
  let record = { order_id = 1; total_amount = 21.0; total_taxes = 1.05 } in
  let expected = ["1"; "21.00"; "1.05"] in
  let result = format_output_record record in
  assert_equal expected result ~printer:(fun l -> String.concat ", " l)


(* Testa a função calculate_item_values do módulo Transformation *)
let test_calculate_item_values _ =
  let item = { order_id = 1; product_id = 101; quantity = 2; price = 10.0; tax = 0.1 } in
  let revenue, tax_amount = calculate_item_values item in
  assert_equal 20.0 revenue;
  assert_equal 2.0 tax_amount


(* Testa a função sum_item_values do módulo Transformation *)
let test_sum_item_values _ =
  let values = [(20.0, 1.0); (30.0, 1.5)] in
  let total_rev, total_tax = sum_item_values values in
  assert_equal 50.0 total_rev;
  assert_equal 2.5 total_tax


(* Testa a função group_items_by_order_id do módulo Transformation *)
let test_group_items_by_order_id _ =
  let items = [
    { order_id = 1; product_id = 101; quantity = 2; price = 10.0; tax = 5.0 };
    { order_id = 1; product_id = 102; quantity = 1; price = 20.0; tax = 5.0 };
    { order_id = 2; product_id = 103; quantity = 3; price = 15.0; tax = 10.0 };
  ] in
  let grouped = group_items_by_order_id items in
  let list1 = OrderMap.find 1 grouped in
  let list2 = OrderMap.find 2 grouped in
  assert_equal 2 (List.length list1);
  assert_equal 1 (List.length list2)


(* Testa a função transform_data do módulo Transformation *)
let test_transform_data _ =
  let orders = [
    { id = 1; client_id = 101; order_date = "2023-01-01"; status = "complete"; origin = "O" };
    { id = 2; client_id = 102; order_date = "2023-01-02"; status = "pending"; origin = "O" };
    { id = 3; client_id = 103; order_date = "2023-01-03"; status = "complete"; origin = "O" };
  ] in
  let items = [
    { order_id = 1; product_id = 201; quantity = 2; price = 10.0; tax = 5.0 };
    { order_id = 1; product_id = 202; quantity = 1; price = 20.0; tax = 5.0 };
    { order_id = 3; product_id = 203; quantity = 3; price = 15.0; tax = 10.0 };
  ] in
  let output_records = transform_data ~target_status:"complete" ~target_origin:"O" orders items in
  (* Espera dois registros: para os pedidos de id 1 e 3 *)
  assert_equal 2 (List.length output_records)


let suite =
  "Testes de funções puras" >:::
  [
    "parse_order_item_row - válido" >:: test_parse_order_item_row_valid;
    "parse_order_item_row - inválido" >:: test_parse_order_item_row_invalid;
    "parse_order_row - válido" >:: test_parse_order_row_valid;
    "parse_order_row - inválido" >:: test_parse_order_row_invalid;
    "format_output_record" >:: test_format_output_record;
    "calculate_item_values" >:: test_calculate_item_values;
    "sum_item_values" >:: test_sum_item_values;
    "group_items_by_order_id" >:: test_group_items_by_order_id;
    "transform_data" >:: test_transform_data;
  ]

let () =
  run_test_tt_main suite