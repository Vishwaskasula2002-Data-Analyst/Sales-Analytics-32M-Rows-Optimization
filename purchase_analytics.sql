CREATE TABLE orders (
order_id varchar(50),
user_id varchar(50),
eval_set varchar(50),
order_number varchar(50),
order_dow varchar(50),
order_hour_of_day varchar(50),
days_since_prior_order varchar(50)
);
CREATE TABLE order_products__prior (
order_id varchar(50),
product_id varchar(50),
add_to_cart_order varchar(50),
reordered varchar(50)
);
CREATE TABLE products (
product_id varchar(50),
product_name varchar(220),
aisle_id varchar(50),
department_id varchar(50)
);
CREATE TABLE order_products__train(
order_id varchar(50),
product_id varchar(50),
add_to_cart_order varchar(50),
reordered varchar(50)
);
CREATE TABLE dpartments (
department_id varchar(50),
department varchar(100)
);
CREATE TABLE aisle (
aisle_id varchar(50),
aisle varchar(150)
);

---------------------------------------------------------creates all tables are various data type only so that we could check any discrepencies , make them right and then change the data type before any calculations

ALTER TABLE dpartments 
    ALTER COLUMN department_id TYPE INTEGER USING department_id::INTEGER;

ALTER TABLE aisle 
    ALTER COLUMN aisle_id TYPE INTEGER USING aisle_id::INTEGER;

ALTER TABLE products 
    ALTER COLUMN product_id TYPE INTEGER USING product_id::INTEGER,
    ALTER COLUMN aisle_id TYPE INTEGER USING aisle_id::INTEGER,
    ALTER COLUMN department_id TYPE INTEGER USING department_id::INTEGER;

ALTER TABLE orders 
    ALTER COLUMN order_id TYPE INTEGER USING order_id::INTEGER,
    ALTER COLUMN user_id TYPE INTEGER USING user_id::INTEGER,
    ALTER COLUMN order_number TYPE INTEGER USING order_number::INTEGER,
    ALTER COLUMN order_dow TYPE INTEGER USING order_dow::INTEGER,
    ALTER COLUMN order_hour_of_day TYPE INTEGER USING order_hour_of_day::INTEGER,
    ALTER COLUMN days_since_prior_order TYPE DECIMAL USING days_since_prior_order::DECIMAL;

ALTER TABLE order_products__prior 
    ALTER COLUMN order_id TYPE INTEGER USING order_id::INTEGER,
    ALTER COLUMN product_id TYPE INTEGER USING product_id::INTEGER,
    ALTER COLUMN add_to_cart_order TYPE INTEGER USING add_to_cart_order::INTEGER,
    ALTER COLUMN reordered TYPE INTEGER USING reordered::INTEGER;

ALTER TABLE order_products__train 
    ALTER COLUMN order_id TYPE INTEGER USING order_id::INTEGER,
    ALTER COLUMN product_id TYPE INTEGER USING product_id::INTEGER,
    ALTER COLUMN add_to_cart_order TYPE INTEGER USING add_to_cart_order::INTEGER,
    ALTER COLUMN reordered TYPE INTEGER USING reordered::INTEGER;

---------------------------------------------------------------------------------------------------after checking there are absolutely no discrepencies we convert all number columns to numeric so that we could do calculations

------------------------------------------------------------------------ Index the massive 32-million row prior table
CREATE INDEX idx_opp_order_id ON order_products__prior(order_id);
CREATE INDEX idx_opp_product_id ON order_products__prior(product_id);

------------------------------------------------------------------------ Index the 1.3-million row train table
CREATE INDEX idx_opt_order_id ON order_products__train(order_id);
CREATE INDEX idx_opt_product_id ON order_products__train(product_id);

------------------------------------------------------------------------ Index the orders table to speed up user behavior analytics
CREATE INDEX idx_orders_user_id ON orders(user_id);

ANALYSE order_products__prior;
ANALYSE orders;
-------------------------------------------------------------------------analyses the indexes and helps in speeding up a query for huge data like 32m rows

CREATE OR REPLACE VIEW vw_purchases AS ( WITH RankedProducts AS (
   SELECT d.department,
       p.product_name,
	   count(op.product_id) AS total_orders,
	   dense_rank() over (partition BY d.department ORDER BY count(op.product_id)DESC) AS rank_in_dept
FROM products as p
INNER join dpartments as d ON p.department_id=d.department_id
INNER join order_products__prior as op on op.product_id = p.product_id
GROUP by d.department,p.product_name
)
SELECT *
from RankedProducts
WHERE rank_in_dept <=3);




CREATE OR REPLACE VIEW vw_peak_order_times AS ( SELECT order_dow,order_hour_of_day,count(*)
FROM orders
GROUP by order_dow,order_hour_of_day 
ORDER by count(*) DESC);




CREATE OR REPLACE VIEW vw_reordered_percentage AS ( 
SELECT
d.department,
round(avg(opp.reordered),2) AS reordered_percentage
from order_products__prior AS opp
inner join products AS p ON opp.product_id = p.product_id
INNER join dpartments AS d ON d.department_id = p.department_id
GROUP by d.department
ORDER by reordered_percentage DESC );


-----------------------------------------------------------------------------creates a  view , with which we can calculate connect to a visualisation tool, if any data is messed the view is only messed and the original data is safe 



CREATE OR REPLACE VIEW vw_purchases_optimized AS (
    WITH DepartmentProductCounts AS (
        -- Step 1: First heavy aggregations ni isolate chesthunnam
        SELECT 
            p.department_id,
            op.product_id,
            COUNT(op.product_id) AS total_orders
        FROM order_products__prior op
        JOIN products p ON op.product_id = p.product_id
        GROUP BY p.department_id, op.product_id
    ),
    RankedProducts AS (
        -- Step 2: Aggregate ayyina chinna dataset meeda mathrame ranking apply chesthunnam
        SELECT 
            d.department,
            p.product_name,
            dpc.total_orders,
            DENSE_RANK() OVER (
                PARTITION BY dpc.department_id 
                ORDER BY dpc.total_orders DESC
            ) AS rank_in_dept
        FROM DepartmentProductCounts dpc
        JOIN products p ON dpc.product_id = p.product_id
        JOIN dpartments d ON dpc.department_id = d.department_id -- Ikkada nee original table name (dpartments) vaadam
    )
    -- Step 3: Final layer lo just filter chesthunnam
    SELECT department, product_name, total_orders, rank_in_dept
    FROM RankedProducts
    WHERE rank_in_dept <= 3
);

EXPLAIN ANALYZE SELECT * FROM vw_purchases_optimized;
