%sql /* Task 1: Cast columns into the correct datatype. */

DO $$ 
DECLARE 
    max_card_number_length INT;
    max_store_code_length INT;
    max_product_code_length INT;
BEGIN
    SELECT 
        MAX(LENGTH(CAST(card_number AS TEXT))),
        MAX(LENGTH(store_code)),
        MAX(LENGTH(product_code))
    INTO 
        max_card_number_length,
        max_store_code_length,
        max_product_code_length
    FROM 
        orders_table;
    
    EXECUTE 'ALTER TABLE orders_table
             ALTER COLUMN card_number TYPE VARCHAR(' || max_card_number_length || ')';
    EXECUTE 'ALTER TABLE orders_table
             ALTER COLUMN store_code TYPE VARCHAR(' || max_store_code_length || ')';
    EXECUTE 'ALTER TABLE orders_table
             ALTER COLUMN product_code TYPE VARCHAR(' || max_product_code_length || ')';
	EXECUTE 'ALTER TABLE orders_table
			 Alter COLUMN user_uuid TYPE UUID USING user_uuid::UUID';
	EXECUTE 'ALTER TABLE orders_table
			ALTER COLUMN date_uuid TYPE UUID USING date_uuid::UUID';
	EXECUTE 'ALTER TABLE orders_table
			ALTER COLUMN product_quantity TYPE SMALLINT';
END $$;
SELECT * FROM orders_table;


/* Task 2: Cast columns into the correct datatype. */
DO $$ 
DECLARE 
    max_country_code_length INT;
BEGIN
    SELECT 
        MAX(LENGTH(country_code))
    INTO 
        max_country_code_length
    FROM 
        dim_users;
    
    EXECUTE 'ALTER TABLE dim_users
             ALTER COLUMN first_name TYPE VARCHAR(255)';
    EXECUTE 'ALTER TABLE dim_users
             ALTER COLUMN last_name TYPE VARCHAR(255)';
    EXECUTE 'ALTER TABLE dim_users
             ALTER COLUMN date_of_birth TYPE DATE';
    EXECUTE 'ALTER TABLE dim_users
             ALTER COLUMN country_code TYPE VARCHAR(' || max_country_code_length || ')';
    EXECUTE 'ALTER TABLE dim_users
             ALTER COLUMN user_uuid TYPE UUID USING user_uuid::UUID';
    EXECUTE 'ALTER TABLE dim_users
			ALTER COLUMN join_date TYPE DATE';
END $$;
SELECT * FROM dim_users;


/* Task 3: Cast columns into the correct datatype. */
UPDATE dim_store_details SET 
  longitude = CASE WHEN longitude = 'N/A' THEN NULL ELSE longitude END,
  address = CASE WHEN address = 'N/A' THEN NULL ELSE address END,
  latitude = CASE WHEN latitude = 'N/A' THEN NULL ELSE latitude END;
DO $$
DECLARE max_store_code_length INT;
BEGIN 
	SELECT MAX(LENGTH(store_code)) INTO max_store_code_length FROM dim_store_details;
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN longitude TYPE FLOAT USING longitude::FLOAT';
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN locality TYPE VARCHAR(255)';
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN store_code TYPE VARCHAR(' || max_store_code_length || ')';
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN staff_numbers TYPE SMALLINT USING staff_numbers::SMALLINT';
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN opening_date TYPE DATE';
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN store_type TYPE VARCHAR(255)';
	EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN store_type DROP NOT NULL';
    EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN latitude TYPE FLOAT USING latitude::FLOAT';
	EXECUTE 'ALTER TABLE dim_store_details
             ALTER COLUMN country_code TYPE VARCHAR(2)';
    EXECUTE 'ALTER TABLE dim_store_details
			ALTER COLUMN continent TYPE VARCHAR(255)';
END $$;
SELECT * FROM dim_store_details;

/* Task 4 and 5: Update and cast columns into the correct datatype. */

ALTER TABLE dim_products
RENAME COLUMN removed TO still_available;

UPDATE dim_products
SET still_available = TRIM(LOWER(still_available));

-- update still_available column
UPDATE dim_products
SET still_available =
	CASE
		WHEN still_available = 'still_avaliable' THEN 'yes'
		WHEN still_available = 'removed' THEN 'no'
		ELSE NULL
	END;
-- remove currency sign from product_price
UPDATE dim_products
SET product_price = CAST(REPLACE(CAST(product_price AS VARCHAR), '£', '') AS FLOAT);

-- create weight_class column
ALTER TABLE dim_products
ADD COLUMN weight_class VARCHAR(255);

UPDATE dim_products
SET weight_class = 
	CASE
		WHEN weight < 2 THEN 'Light'
		WHEN weight >= 2 AND weight < 40 THEN 'Mid-Sized'
		WHEN weight >= 40 AND weight < 140 THEN 'Heavy'
		ELSE 'Truck_Required'
	END;

DO $$
DECLARE
	max_ean_length INT;
	max_product_code_length INT;
	max_weight_class_length INT;
BEGIN
	SELECT 
		MAX(LENGTH(LOWER("EAN"))),
		MAX(LENGTH(product_code)),
		MAX(LENGTH(weight_class))
	INTO 
		max_ean_length, 
		max_product_code_length, 
		max_weight_class_length
	FROM dim_products;
	
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN weight TYPE FLOAT';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN "EAN" TYPE VARCHAR(' || max_ean_length || ')';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN product_code TYPE VARCHAR(' || max_product_code_length || ')';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN date_added TYPE DATE';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN uuid TYPE UUID USING uuid::UUID';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN product_price TYPE FLOAT USING product_price::FLOAT';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN still_available TYPE BOOL USING still_available::BOOL';
	EXECUTE 'ALTER TABLE dim_products
			ALTER COLUMN weight_class TYPE VARCHAR(' || max_weight_class_length || ')';
END $$;
SELECT DISTINCT still_available, COUNT(*) AS total_count FROM dim_products
GROUP BY still_available;

SELECT * FROM dim_products;

/* Task 6: Cast the columns into the correct format. */

DO $$
DECLARE 
	max_time_period_length INT;
BEGIN 
	SELECT MAX(LENGTH(time_period)) INTO max_time_period_length FROM dim_date_times;
	EXECUTE 'ALTER TABLE dim_date_times
	ALTER COLUMN "month" TYPE VARCHAR(2)';
	EXECUTE 'ALTER TABLE dim_date_times
	ALTER COLUMN "year" TYPE VARCHAR(4)';
	EXECUTE 'ALTER TABLE dim_date_times
	ALTER COLUMN "day" TYPE VARCHAR(2)';
	EXECUTE 'ALTER TABLE dim_date_times
	ALTER COLUMN time_period TYPE VARCHAR(' || max_time_period_length || ')';
	EXECUTE 'ALTER TABLE dim_date_times
	ALTER COLUMN date_uuid TYPE UUID USING date_uuid::UUID';
END $$;

SELECT * FROM dim_date_times;


/* Task 7: Cast columns into the correct datatype. */

DO $$
DECLARE
	max_card_number_length INT;
	max_expiry_date_length INT;
BEGIN
	SELECT 
		MAX(LENGTH(card_number)),
		MAX(LENGTH(expiry_date))
	INTO 
		max_card_number_length,
		max_expiry_date_length
	FROM dim_card_details;
	
	EXECUTE 'ALTER TABLE dim_card_details
			ALTER COLUMN card_number TYPE VARCHAR(' || max_card_number_length || ')';
	EXECUTE 'ALTER TABLE dim_card_details
			ALTER COLUMN expiry_date TYPE VARCHAR(' || max_expiry_date_length || ')';
	EXECUTE 'ALTER TABLE dim_card_details
			ALTER COLUMN date_payment_confirmed TYPE DATE USING date_payment_confirmed::DATE';
END $$;
SELECT * FROM dim_card_details;


/* Task 8: Add primary keys. */

ALTER TABLE dim_date_times 
ADD PRIMARY KEY (date_uuid);

ALTER TABLE dim_products
ADD PRIMARY KEY (product_code);

ALTER TABLE dim_store_details
ADD PRIMARY KEY (store_code);

ALTER TABLE dim_users
ADD PRIMARY KEY (user_uuid);

ALTER TABLE dim_card_details
ADD PRIMARY KEY (card_number);

/* Task 9: Add foreign keys. */

ALTER TABLE orders_table
ADD CONSTRAINT fk_orders_user
FOREIGN KEY (user_uuid)
REFERENCES dim_users(user_uuid);

ALTER TABLE orders_table
ADD CONSTRAINT fk_orders_card
FOREIGN KEY (card_number)
REFERENCES dim_card_details(card_number);

ALTER TABLE orders_table
ADD CONSTRAINT fk_orders_date
FOREIGN KEY (date_uuid)
REFERENCES dim_date_times(date_uuid);

ALTER TABLE orders_table
ADD CONSTRAINT fk_orders_store
FOREIGN KEY (store_code)
REFERENCES dim_store_details(store_code);

ALTER TABLE orders_table
ADD CONSTRAINT fk_orders_products
FOREIGN KEY (product_code)
REFERENCES dim_products(product_code);