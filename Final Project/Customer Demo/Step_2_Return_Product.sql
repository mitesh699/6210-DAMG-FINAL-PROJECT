--- Login as Customer

--- Return a product

Execute DATA_INSERTION.INSERT_RETURNS(   1, 'Did not like item', 1);


-- Invalid Reason
Execute DATA_INSERTION.INSERT_RETURNS(   1, '', 1);
-- Invalid Quantity
Execute DATA_INSERTION.INSERT_RETURNS(   1, 'Y',0);

--- View Tables


SELECT * FROM RETURNS;

