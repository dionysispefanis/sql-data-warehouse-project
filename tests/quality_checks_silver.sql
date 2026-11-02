-------------------------------------------------
-- crm_cust_ingo
-------------------------------------------------
--Check for nulls or duplicates in primary key 

SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


--Check for unwanted spaces
-- expected no results
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)


--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

select * from silver.crm_cust_info

--------------------------------------
--crm_prd_info
--------------------------------------
SELECT * FROM bronze.crm_prd_info
--Check for nulls or duplicates in primary key 
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


--Check for unwanted spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check for NULLs or Negatine Numbers
--Expect no results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;

-- expected no results

--Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


--------------------------------------
--crm_sales_details
--------------------------------------
select * from bronze.crm_sales_details
--Check for Invalid Dates
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8

--Check for Invalid Date Orders
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


--Check Data Consistency: Between Sales, Quantity, Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero or negative

--Rules:
--If Sales is negative, zero or null -> derive it using Quantity and Price
--If Price zero or null				 -> calculate it using Sales and Quantity
--If Price is negative				 -> convert it to a positive value

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity,sls_price

-- Check silver

SELECT DISTINCT
sls_sales ,
sls_quantity,
sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity,sls_price


--------------------------------------
--erp_cust_az12
--------------------------------------
SELECT * FROM .bronze.erp_cust_az12


--Identify Out-of-Range Dates

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE   bdate > GETDATE()

--Data Standardization & Consistency

SELECT DISTINCT 
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM silver.erp_cust_az12

--------------------------------------
--erp_loc_a101
--------------------------------------
SELECT * FROM bronze.erp_loc_a101


-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101

--------------------------------------
--erp_loc_a101
--------------------------------------

SELECT * FROM bronze.erp_px_cat_g1v2

--Check for unwanted Spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistnecy
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
