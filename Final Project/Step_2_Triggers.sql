CREATE OR REPLACE TRIGGER update_warehouse_capacity 
AFTER  INSERT ON Product 
FOR EACH ROW 
DECLARE 
   new_capacity number; 
   w_capacity number;
   
BEGIN 
    SELECT CAPACITY into w_capacity from warehouse where WAREHOUSE_ID = :NEW.warehouse_id;
    new_capacity := :NEW.TOTAL_UNITS + w_capacity; 
    UPDATE WAREHOUSE 
    SET CAPACITY = new_capacity
    where WAREHOUSE_ID = :NEW.warehouse_id;    
    dbms_output.put_line('Warehouse Capacity Updated'); 
END; 
/


--- Update capcity on ware house trgger
CREATE OR REPLACE TRIGGER update_capacity_on_order
AFTER INSERT ON Orders
FOR EACH ROW 
DECLARE 
   new_capacity number; 
   w_capacity number;
   p_capacity number;
   w_id number;
BEGIN 
    
    SELECT WAREHOUSE_ID, AVAILABLE_UNITS into  w_id, p_capacity from PRODUCT where PRODUCT_ID = :NEW.Product_id;
    SELECT CAPACITY into w_capacity from warehouse where WAREHOUSE_ID = w_id;
    new_capacity := w_capacity - :NEW.QUANTITY; 
    
    UPDATE WAREHOUSE 
    SET CAPACITY = new_capacity
    where WAREHOUSE_ID = w_id;    
        dbms_output.put_line('Warehouse Capacity Updated on Order'); 
    
    new_capacity := p_capacity - :NEW.QUANTITY; 
    UPDATE PRODUCT 
    SET AVAILABLE_UNITS = new_capacity
    where PRODUCT_ID = :NEW.Product_id; 
        
    dbms_output.put_line('Product units updated on Order'); 
END; 
/


