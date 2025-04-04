open Etl

let () = 
    let orders_file = "data/raw/order.csv" in
    let items_file = "data/raw/order_item.csv" in
    let output_file = "data/processed/output.csv" in
    
    (* Read the CSV files *)
    let orders = Extract_orders.read_csv_orders orders_file in
    let items = Extract_items.read_csv_order_items items_file in
    
    (* Transform the data *)
    let transformed_data =
        Transformation.transform_data ~target_status:"Pending" ~target_origin:"O" orders items
    in
    
    (* Write the output to a CSV file *)
    match Loading.write_output_csv output_file transformed_data with
    | Ok () -> Printf.printf "Data successfully written to %s\n" output_file
    | Error msg -> Printf.eprintf "Error: %s\n" msg