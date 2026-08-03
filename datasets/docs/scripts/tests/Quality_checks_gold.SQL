--check for uniqueness OF gold layer

===============================================================
  check for 'gold.dim_customers'
===============================================================
  --check for uniqueness of customer key in 'gold.dim_customers'
SELECT
    customer_keys
    COUNT(*) AS Duplicate_count
    FROM gold.dim_customer
    WHERE COUNT(*)>1
    
================================================================
  
--To check for 'gold.product_key'
===============================================================
  --check for uniqueness of product key in gold.dim_product
  --Expectation no result
SELECT 
    product_key
  COUNT(*)
  FROM gold.dim_products
GROUP BY product_key
  HAVING COUNT(*)>1
============================================================
 Check for 'gold.fact_sales'
===========================================================
--To check the FORIEN KEY INTEGRITY (DIMENTION) in gold layer

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key=f.customer_key 
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
WHERE p.product_key IS NULL
