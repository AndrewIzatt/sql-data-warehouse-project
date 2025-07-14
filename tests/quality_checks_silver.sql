-- =============================================================
-- Checking 'silver.crm_cust_info'
-- =============================================================

-- Check for nulls or duplicates in primary key
-- Expectation: no result
SELECT cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation: No Result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for unwanted spaces
-- Expectation: No Result
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
-- Expectation: No Result
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- =============================================================
-- Checking 'silver.crm_prd_info'
-- =============================================================

SELECT 
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- =============================================================
-- Checking 'silver.crm_sales_details'
-- =============================================================

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =============================================================
-- Checking 'silver.erp_cust_az12'
-- =============================================================

-- Identify Out-of-Range Dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- =============================================================
-- Checking 'silver.erp_loc_a101
-- =============================================================
SELECT 
    REPLACE(cid, '-', '') cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info);

-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =============================================================
-- Checking 'silver.erp_loc_a101
-- =============================================================
-- Check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data standardization & Consistency
SELECT DISTINCT
    CASE
        WHEN CHARINDEX(CHAR(13), maintenance) > 0 THEN TRIM(REPLACE(maintenance, CHAR(13), ' '))
        ELSE maintenance
    END AS maintenance
FROM silver.erp_px_cat_g1v2;

