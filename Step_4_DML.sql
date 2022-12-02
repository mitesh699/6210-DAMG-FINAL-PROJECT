SET SERVEROUT ON;

create or replace PACKAGE DATA_INSERTION
AS

PROCEDURE INSERT_CUSTOMER (  
							FNAME                   in VARCHAR, 
							LNAME                   in VARCHAR, 
							EMAIL                   in VARCHAR, 
							PHONE_NUMBER            in VARCHAR, 
							cADDRESS                in VARCHAR, 
							CITY                    in VARCHAR,
							CUSTOMER_STATE          in VARCHAR, 
							ZIPCODE                 in NUMBER,
							USERNAME 	            in VARCHAR,
							U_PASSWORD  	        in VARCHAR);

PROCEDURE INSERT_INVOICE (  ORDER_ID 	     in NUMBER,
							PMETHOD_ID	     in NUMBER,
							ORDER_STATUS     in VARCHAR,
							PAYMENT_STATUS   in VARCHAR);
                            
PROCEDURE INSERT_ORDERS (  
							CUSTOMER_ID         in NUMBER,
							PRODUCT_ID          in NUMBER,
							QUANTITY            in NUMBER,
							ORDER_COST  		in NUMBER
						   ); 

PROCEDURE INSERT_PAYMENT_METHOD (  METHOD_NAME in VARCHAR ); 

PROCEDURE INSERT_PRODUCT (  CATEGORY_ID   	        in NUMBER, 
							SUPPLIER_ID   	        in NUMBER, 
                            WAREHOUSE_ID            in NUMBER,
							PRODUCT_NAME         	in VARCHAR, 
							PRODUCT_DESCRIPTION 	in VARCHAR, 
							AVAILABLE_UNITS         in NUMBER, 
							TOTAL_UNITS 	        in NUMBER,
							UNIT_PRICE 		        in NUMBER);


PROCEDURE INSERT_PRODUCT_CATEGORY(CATEGORY_NAME in VARCHAR, pDESCRIPTION in VARCHAR);

PROCEDURE INSERT_RETURNS (  
							ORDER_ID	in NUMBER,
							REASON  	in VARCHAR,
							QUANTITY    in NUMBER
						   ); 



PROCEDURE INSERT_SUPPLIER ( SUPPLIER_NAME   in VARCHAR, 
							CONTACTFNAME    in VARCHAR, 
							CONTACTLNAME    in VARCHAR, 
							TITLE           in VARCHAR, 
							aADDRESS        in VARCHAR, 
							CITY            in VARCHAR, 
							SUPPLIER_STATE	in VARCHAR,
							EMAIL 	        in VARCHAR,
							ACTIVE          in NUMBER); 


PROCEDURE INSERT_WAREHOUSE( WAREHOUSE_LOCATION in VARCHAR,
                            CITY in VARCHAR,
                            WSTATE in VARCHAR,
                            ZIPCODE in VARCHAR,
							W_CAPACITY in NUMBER);


end DATA_INSERTION;
/
CREATE OR REPLACE PACKAGE BODY DATA_INSERTION
AS
------------------------------------------------CUSTOMER DETAILS INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_CUSTOMER(  FNAME in VARCHAR, LNAME in VARCHAR, EMAIL in VARCHAR, 
                            PHONE_NUMBER in VARCHAR, 
                            cADDRESS in VARCHAR, CITY in VARCHAR, 
                            CUSTOMER_STATE in VARCHAR, ZIPCODE in NUMBER,
							USERNAME in VARCHAR,U_PASSWORD in VARCHAR)
AS
phno_exp EXCEPTION;
zip_exp EXCEPTION;
phno_char_exp EXCEPTION;
INVALID_STATE EXCEPTION;
INVALID_CITY EXCEPTION;
BEGIN
    IF IS_NUMBER(PHONE_NUMBER)=0 THEN
        RAISE phno_char_exp;
    END IF;
    IF LENGTH(TRIM(PHONE_NUMBER))<>10 THEN
        RAISE phno_exp;
    END IF;
    IF LENGTH(TRIM(ZIPCODE))<>5 THEN
        RAISE zip_exp;
    END IF;
    IF CUSTOMER_STATE NOT IN ('MA') THEN
        RAISE INVALID_STATE;
    END IF;
    IF CUSTOMER_STATE ='MA' AND UPPER(CITY) NOT IN ('BOSTON','BROOKLINE') THEN
    RAISE INVALID_CITY;
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
    INSERT INTO CUSTOMER VALUES(customer_seq.nextval, FNAME,LNAME,EMAIL,PHONE_NUMBER,cADDRESS,CITY,CUSTOMER_STATE,ZIPCODE,USERNAME,U_PASSWORD);
    DBMS_OUTPUT.PUT_LINE('ROWS INSERTED INTO CUSTOMER TABLE');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
    COMMIT;
    EXCEPTION
    WHEN dup_val_on_index THEN
        DBMS_OUTPUT.PUT_LINE('This is duplicate value. Please enter a different value.');
    WHEN phno_char_exp THEN
        DBMS_OUTPUT.PUT_LINE('Invalid value. Phone number can only contain numbers');
    WHEN phno_exp THEN
        DBMS_OUTPUT.PUT_LINE('Invalid value. Phone number can only be 10 digits');
    WHEN zip_exp THEN
        DBMS_OUTPUT.PUT_LINE('Invalid value. Zipcode can only be 5 digits');
    WHEN INVALID_STATE THEN
        DBMS_OUTPUT.PUT_LINE('Services are available only in 1 states: MA');
    WHEN INVALID_CITY THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid city for this state');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('There was an error while inserting data into Customer table');
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error details:');
    DBMS_OUTPUT.PUT_LINE(dbms_utility.format_error_stack);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
END INSERT_CUSTOMER;
------------------------------------------------INVOICE INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_INVOICE(   ORDER_ID in NUMBER,
                            PMETHOD_ID in NUMBER, ORDER_STATUS in VARCHAR,
							PAYMENT_STATUS in VARCHAR)
AS
cost_exp EXCEPTION;
o_status_exp EXCEPTION;
p_status_exp EXCEPTION;
BEGIN

    IF UPPER(ORDER_STATUS) NOT IN ('Y','N') then
        RAISE o_status_exp;
    END IF;
    
    IF UPPER(PAYMENT_STATUS) NOT IN ('Y','N') then
        RAISE p_status_exp;
    END IF;    
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        INSERT INTO INVOICE VALUES 
        (invoice_seq.nextval, ORDER_ID ,PMETHOD_ID,ORDER_STATUS,PAYMENT_STATUS,CURRENT_DATE); 
        DBMS_OUTPUT.PUT_LINE('Rows inserted in INVOICE Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when cost_exp then
dbms_output.put_line('Cost cannot be zero');
when o_status_exp then
dbms_output.put_line('Order Status can only be Y or N');
when p_status_exp then
dbms_output.put_line('Payment status can only be Y or N');
when others then
dbms_output.put_line('Error while inserting data into INVOICE Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_INVOICE;
------------------------------------------------ORDERS INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_ORDERS( CUSTOMER_ID in NUMBER,PRODUCT_ID in NUMBER, 
                         QUANTITY in NUMBER,ORDER_COST in NUMBER)
AS
quantity_exp EXCEPTION;
cost_exp EXCEPTION;
quantity_invalid_exp EXCEPTION;
price_exp EXCEPTION;

units NUMBER;
price NUMBER;

BEGIN
    IF ORDER_COST = 0 then
        RAISE cost_exp;
    END IF;
    IF QUANTITY = 0 then
        RAISE quantity_exp;
    END IF;
    
    SELECT UNIT_PRICE, AVAILABLE_UNITS into price, units from PRODUCT where PRODUCT_ID = PRODUCT_ID;
    
    IF QUANTITY > units then
        RAISE quantity_invalid_exp;
    END IF;
    
    IF price*QUANTITY <> ORDER_COST then
        RAISE price_exp;
    END IF;
    
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
    INSERT INTO orders VALUES (orders_seq.nextval,CUSTOMER_ID,PRODUCT_ID,QUANTITY,ORDER_COST,CURRENT_DATE); 
    DBMS_OUTPUT.PUT_LINE('Rows inserted in ORDERS Table');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when cost_exp then
dbms_output.put_line('Order cost cannot be zero');
when quantity_exp then
dbms_output.put_line('Quantiy cannot be zero');
when quantity_invalid_exp then
dbms_output.put_line('Quantity is not available');
when price_exp then
dbms_output.put_line('Order cost is invalid');

when others then
dbms_output.put_line('Error while inserting data into ORDERS Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_ORDERS;
------------------------------------------------PAYMENT METHOD INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_PAYMENT_METHOD(METHOD_NAME in VARCHAR )
AS
name_exp EXCEPTION;
BEGIN
    IF UPPER(METHOD_NAME) NOT IN ('CASH', 'NETBANKING', 'CARD') THEN
        RAISE name_exp;
    END IF;
    
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        INSERT INTO PAYMENT_METHOD  VALUES (pay_method_seq.nextval, METHOD_NAME); 
        DBMS_OUTPUT.PUT_LINE('Rows inserted in PAYMENT_METHOD Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when name_exp then
dbms_output.put_line('Methods can only be Cash, Card and Netbanking');
when others then
dbms_output.put_line('Error while inserting data into ORDERS Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_PAYMENT_METHOD;
------------------------------------------------PRODUCT INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_PRODUCT(CATEGORY_ID in NUMBER, SUPPLIER_ID in NUMBER, 
                        WAREHOUSE_ID in NUMBER,
                        PRODUCT_NAME in VARCHAR, PRODUCT_DESCRIPTION in VARCHAR, 
                        AVAILABLE_UNITS in NUMBER, 
                        TOTAL_UNITS in NUMBER,
						UNIT_PRICE in NUMBER)
AS
av_units_exp EXCEPTION;
t_units_exp EXCEPTION;
price_exp EXCEPTION;
w_capacity NUMBER;
BEGIN
        IF AVAILABLE_UNITS = 0 then
            RAISE av_units_exp;
        END IF;
        IF TOTAL_UNITS = 0 then
            RAISE t_units_exp;
        END IF;
        IF UNIT_PRICE = 0 then
            RAISE price_exp;
        END IF;
        IF AVAILABLE_UNITS > TOTAL_UNITS  then
            RAISE av_units_exp;
        END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        INSERT INTO PRODUCT VALUES (product_seq.nextval,CATEGORY_ID,SUPPLIER_ID, WAREHOUSE_ID,PRODUCT_NAME, PRODUCT_DESCRIPTION, AVAILABLE_UNITS, TOTAL_UNITS,UNIT_PRICE); 
        DBMS_OUTPUT.PUT_LINE('Rows inserted in PRODUCT Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Warehouse capcity updated');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when av_units_exp then
dbms_output.put_line('Available units is less than 0 or greater than total');
when t_units_exp then
dbms_output.put_line('Total units is zero');
when price_exp then
dbms_output.put_line('Price cannot be zero');
when others then
dbms_output.put_line('Error while inserting data into PRODUCT Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_PRODUCT;
------------------------------------------------PRODUCT CATEGORY INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_PRODUCT_CATEGORY(CATEGORY_NAME in VARCHAR, pDESCRIPTION in VARCHAR)
AS
cat_exp EXCEPTION;
desc_exp EXCEPTION;
BEGIN
    IF LENGTH(TRIM(pDESCRIPTION)) >= 50 then
        RAISE desc_exp;
    END IF;
    IF UPPER(CATEGORY_NAME) NOT IN ('ELECTRONICS','SPORTSWEAR', 'SKINCARE', 'STATIONERY' ) THEN
        RAISE cat_exp;
    END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        INSERT INTO PRODUCT_CATEGORY VALUES (product_cat_seq.nextVal, CATEGORY_NAME, pDESCRIPTION); 
        DBMS_OUTPUT.PUT_LINE('Rows inserted in PROCDUCT_CATEGORY Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when cat_exp then
dbms_output.put_line('Product category is invalid');
when desc_exp then 
dbms_output.put_line('description is more than 50 characters');
when others then
dbms_output.put_line('Error while inserting data into PRODUCT_CATEGORY Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_PRODUCT_CATEGORY;
------------------------------------------------RETURNS INSERT----------------------------------------------------------------------------
PROCEDURE INSERT_RETURNS(ORDER_ID in NUMBER,
                        REASON in VARCHAR, QUANTITY in NUMBER)
AS
reason_exp EXCEPTION;
quantity_exp EXCEPTION;
BEGIN
    
    IF LENGTH(REASON) = 0 then 
        RAISE reason_exp;
    END IF;
    IF QUANTITY = 0 then 
        RAISE quantity_exp;
    END IF;


        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        INSERT INTO RETURNS VALUES (returns_seq.nextval, ORDER_ID, REASON, QUANTITY, CURRENT_DATE); 
        DBMS_OUTPUT.PUT_LINE('Rows inserted in RETURNS Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when reason_exp then
dbms_output.put_line('Reason cannot be empty');
when quantity_exp then
dbms_output.put_line('Quantiy cannot be zero');

when others then
dbms_output.put_line('Error while inserting data into RETURNS Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_RETURNS;
------------------------------------------------SUPPLIER DETAILS INSERT-------------------------------------------------------------------------
PROCEDURE INSERT_SUPPLIER(  SUPPLIER_NAME in VARCHAR, CONTACTFNAME in VARCHAR, 
                            CONTACTLNAME in VARCHAR, TITLE in VARCHAR, 
                            aADDRESS in VARCHAR, CITY in VARCHAR, 
							SUPPLIER_STATE in VARCHAR, EMAIL in VARCHAR, 
                            ACTIVE in NUMBER)
AS
INVALID_STATE EXCEPTION;
INVALID_CITY EXCEPTION;
BEGIN
    IF SUPPLIER_STATE NOT IN ('MA') THEN
        RAISE INVALID_STATE;
    END IF;
    IF SUPPLIER_STATE ='MA' AND UPPER(CITY) NOT IN ('BOSTON','BROOKLINE') THEN
        RAISE INVALID_CITY;
    END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
        INSERT INTO supplier VALUES (supplier_seq.nextval, SUPPLIER_NAME, CONTACTFNAME, CONTACTLNAME, TITLE, aADDRESS, CITY, SUPPLIER_STATE, EMAIL,ACTIVE) ; 
        DBMS_OUTPUT.PUT_LINE('Rows inserted in SUPPLIER Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
when dup_val_on_index then
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when INVALID_STATE then 
dbms_output.put_line('State can only be MA');
when INVALID_CITY then
dbms_output.put_line('City can only be boston or brookline');
when others then
dbms_output.put_line('Error while inserting data into SUPPLIER Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_SUPPLIER;
-------------------------------------------------------WAREHOUSE DETAILS----------------------------------------------------------------------
PROCEDURE INSERT_WAREHOUSE(WAREHOUSE_LOCATION in VARCHAR,
                            CITY in VARCHAR,
                            WSTATE in VARCHAR,
                            ZIPCODE in VARCHAR,
                            W_CAPACITY in NUMBER)
AS
INVALID_LOCATION EXCEPTION;
BEGIN
 IF CITY NOT IN ('NEWTON','QUINCY','CONCORD') THEN
        RAISE INVALID_LOCATION;
 END IF;
 DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
 INSERT INTO WAREHOUSE VALUES (warehouse_seq.nextval, WAREHOUSE_LOCATION, CITY, WSTATE, ZIPCODE ,W_CAPACITY); 
 DBMS_OUTPUT.PUT_LINE('Rows inserted in WAREHOUSE Table');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------');
COMMIT;
EXCEPTION
WHEN INVALID_LOCATION THEN
DBMS_OUTPUT.PUT_LINE('THERE ARE ONLY THREE WAREHOUSE LOCATIONS: NEWTON,QUINCY,CONCORD PLEASE TRY AGAIN');
WHEN dup_val_on_index THEN
dbms_output.put_line('Duplicate Value Found!! Insert Different Value');
when others then
dbms_output.put_line('Error while inserting data into WAREHOUSE Table');
rollback;
dbms_output.put_line('Error: ');
dbms_output.put_line(dbms_utility.format_error_stack);
dbms_output.put_line('----------------------------------------------------------');
end INSERT_WAREHOUSE;




END;
/



