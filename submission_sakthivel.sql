-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]
/* Starting the query*/
use orders;
/*Query for first question*/
SELECT*
FROM orders.online_customer
LIMIT 20;
SELECT 
    CASE
        WHEN CUSTOMER_GENDER = 'M' THEN CONCAT('Mr. ', UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME))
        WHEN CUSTOMER_GENDER = 'F' THEN CONCAT('Ms. ', UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME))
        ELSE CONCAT(UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME))
    END AS CUSTOMER_FULL_NAME,
    CUSTOMER_EMAIL,
    CUSTOMER_CREATION_DATE,
    CASE
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) >= 2005 AND EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        ELSE 'Category C'
    END AS CUSTOMER_CATEGORY
FROM 
    online_customer;


-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    /*Query for second question*/
    SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    p.PRODUCT_PRICE,
    p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE AS INVENTORY_VALUE,
    CASE
        WHEN p.PRODUCT_PRICE > 20000 THEN p.PRODUCT_PRICE * 0.80
        WHEN p.PRODUCT_PRICE > 10000 THEN p.PRODUCT_PRICE * 0.85
        ELSE p.PRODUCT_PRICE * 0.90
    END AS NEW_PRICE
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID
WHERE 
    oi.PRODUCT_ID IS NULL
ORDER BY 
    INVENTORY_VALUE DESC;
SELECT 
    COUNT(*) AS number_of_unsold_products
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID
WHERE 
    oi.PRODUCT_ID IS NULL;

    
-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    /*Query for third question8*/
    SELECT 
    pc.PRODUCT_CLASS_CODE,
    pc.PRODUCT_CLASS_DESC,
    COUNT(p.PRODUCT_ID) AS product_count,
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS inventory_value
FROM 
    product p
JOIN 
    product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
GROUP BY 
    pc.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC
HAVING 
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) > 100000
ORDER BY 
    inventory_value DESC;

    
-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    /*Query for Fourth question*/
    SELECT 
    oc.CUSTOMER_ID,
    CONCAT(UPPER(oc.CUSTOMER_FNAME), ' ', UPPER(oc.CUSTOMER_LNAME)) AS FULL_NAME,
    oc.CUSTOMER_EMAIL,
    oc.CUSTOMER_PHONE,
    a.COUNTRY
FROM 
    online_customer oc
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    oc.CUSTOMER_ID IN (
        SELECT 
            CUSTOMER_ID
        FROM 
            order_header
        GROUP BY 
            CUSTOMER_ID
        HAVING 
            COUNT(*) = SUM(CASE WHEN ORDER_STATUS = 'Cancelled' THEN 1 ELSE 0 END)
    );
-- Check the count of all orders and canceled orders for each customer:
SELECT 
    CUSTOMER_ID,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN ORDER_STATUS = 'Cancelled' THEN 1 ELSE 0 END) AS canceled_orders
FROM 
    order_header
GROUP BY 
    CUSTOMER_ID;


        
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    /*Query for Fifth question*/
    SELECT 
    s.SHIPPER_NAME,
    a.CITY AS CATERING_CITY,
    COUNT(DISTINCT oc.CUSTOMER_ID) AS CUSTOMERS_CATERED,
    COUNT(*) AS CONSIGNMENTS_DELIVERED
FROM 
    shipper s
JOIN 
    order_header oh ON s.SHIPPER_ID = oh.SHIPPER_ID
JOIN 
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    s.SHIPPER_NAME = 'DHL'
GROUP BY 
    s.SHIPPER_NAME, a.CITY;
    


-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
    /*Query for Sixth question*/
    SELECT 
    oc.CUSTOMER_ID,
    CONCAT(UPPER(oc.CUSTOMER_FNAME), ' ', UPPER(oc.CUSTOMER_LNAME)) AS FULL_NAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED,
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS TOTAL_VALUE_SHIPPED
FROM 
    online_customer oc
JOIN 
    order_header oh ON oc.CUSTOMER_ID = oh.CUSTOMER_ID
JOIN 
    order_items oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN 
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE 
    oc.CUSTOMER_LNAME LIKE 'G%'
    AND oh.PAYMENT_MODE = 'cash'
GROUP BY 
    oc.CUSTOMER_ID, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME;



    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    /*Query for seventh question*/
    WITH CartonVolume AS (
    SELECT 
        LEN * WIDTH * HEIGHT AS CARTON_VOLUME
    FROM 
        carton
    WHERE 
        CARTON_ID = 10
),

OrderVolumes AS (
    SELECT 
        oi.ORDER_ID,
        SUM(p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY) AS ORDER_VOLUME
    FROM 
        order_items oi
    JOIN 
        product p ON oi.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY 
        oi.ORDER_ID
)

SELECT 
    ov.ORDER_ID,
    ov.ORDER_VOLUME
FROM 
    OrderVolumes ov,
    CartonVolume cv
WHERE 
    ov.ORDER_VOLUME <= cv.CARTON_VOLUME
ORDER BY 
    ov.ORDER_VOLUME DESC
LIMIT 1;


-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)
	/*Query for 8th question*/
    SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    COALESCE(oi.TOTAL_SOLD, 0) AS QUANTITY_SOLD,
    CASE 
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computers') THEN
            CASE
                WHEN COALESCE(oi.TOTAL_SOLD, 0) = 0 THEN 'no sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.1 * COALESCE(oi.TOTAL_SOLD, 0) THEN 'low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.5 * COALESCE(oi.TOTAL_SOLD, 0) THEN 'medium inventory, need to add some inventory'
                ELSE 'sufficient inventory'
            END
        WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE
                WHEN COALESCE(oi.TOTAL_SOLD, 0) = 0 THEN 'no sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.2 * COALESCE(oi.TOTAL_SOLD, 0) THEN 'low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.6 * COALESCE(oi.TOTAL_SOLD, 0) THEN 'medium inventory, need to add some inventory'
                ELSE 'sufficient inventory'
            END
        ELSE
            CASE
                WHEN COALESCE(oi.TOTAL_SOLD, 0) = 0 THEN 'no sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.3 * COALESCE(oi.TOTAL_SOLD, 0) THEN 'low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.7 * COALESCE(oi.TOTAL_SOLD, 0) THEN 'medium inventory, need to add some inventory'
                ELSE 'sufficient inventory'
            END
    END AS INVENTORY_STATUS
FROM 
    product p
JOIN 
    product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
LEFT JOIN 
    (SELECT 
         PRODUCT_ID, 
         SUM(PRODUCT_QUANTITY) AS TOTAL_SOLD
     FROM 
         order_items
     GROUP BY 
         PRODUCT_ID) oi ON p.PRODUCT_ID = oi.PRODUCT_ID;


    
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    /*Query for 9th question*/
    SELECT
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SOLD
FROM
    order_items oi
JOIN
    order_header oh ON oi.ORDER_ID = oh.ORDER_ID
JOIN
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
JOIN
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE
    oi.ORDER_ID IN (
        SELECT
            oi_sub.ORDER_ID
        FROM
            order_items oi_sub
        WHERE
            oi_sub.PRODUCT_ID = 201
    )
    AND a.CITY NOT IN ('Bangalore', 'New Delhi')
    AND oi.PRODUCT_ID != 201
GROUP BY
    p.PRODUCT_ID,
    p.PRODUCT_DESC
ORDER BY
    TOTAL_QUANTITY_SOLD DESC;
    


-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
    /*Query for 10th question*/
    SELECT
    oh.ORDER_ID,
    oh.CUSTOMER_ID,
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED
FROM
    order_header oh
JOIN
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
JOIN
    order_items oi ON oh.ORDER_ID = oi.ORDER_ID
WHERE
    MOD(oh.ORDER_ID, 2) = 0
    AND a.PINCODE NOT LIKE '5%'
GROUP BY
    oh.ORDER_ID,
    oh.CUSTOMER_ID,
    oc.CUSTOMER_FNAME,
    oc.CUSTOMER_LNAME
ORDER BY
    oh.ORDER_ID;
    
