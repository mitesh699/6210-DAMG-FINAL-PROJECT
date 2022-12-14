--Creating customer role
create user CUSTOMER identified by Test123456789;

GRANT CONNECT, RESOURCE TO CUSTOMER;
GRANT CREATE SESSION TO CUSTOMER;

GRANT SELECT ON PRODUCT TO CUSTOMER;
GRANT SELECT ON ORDERS TO CUSTOMER;
GRANT SELECT ON INVOICE TO CUSTOMER;

GRANT INSERT,UPDATE ON PRODUCT to CUSTOMER;
GRANT INSERT,UPDATE ON ORDERS to CUSTOMER;
GRANT INSERT,UPDATE ON RETURNS to customer;
GRANT INSERT,UPDATE ON INVOICE to customer;


--Creating supplier role
create user SUPPLIER identified by Supp123456789;

GRANT CONNECT, RESOURCE TO SUPPLIER;
GRANT CREATE SESSION TO SUPPLIER;

GRANT SELECT,INSERT,UPDATE ON SUPPLIER TO SUPPLIER;
GRANT SELECT,INSERT,UPDATE ON PRODUCT TO SUPPLIER;



