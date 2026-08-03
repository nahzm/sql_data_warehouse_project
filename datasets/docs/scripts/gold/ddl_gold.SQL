
-------FIRST DIMENTION VIEW (GOLD LAYER)

CREATE VIEW gold.dim_customers AS

SELECT 
     ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
      ci.cst_id AS customer_id,
      ci.cst_key AS customer_number,
      ci.cst_firstname AS first_name,
      ci.cst_lastname AS last_name,
      la.cntry AS country,
      ci.cst_marital_status AS marital_status,
      CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
           ELSE COALESCE(ca.gen, 'n/a')
           END AS gender,
           ca.bdate AS birthdate,
      ci.cst_create_date AS create_date
      
     FROM silver.crm_cust_info ci
LEFT JOIN dbo.silver_erp_cust_az12 ca
ON ci.cst_key=ca.cid
LEFT JOIN dbo.silver_erp_loc_a101 la
ON ci.cst_key=la.cid 


-- SECOND DIMENTION VIEW (GOLD LAYER)

CREATE VIEW gold.dim_products AS

SELECT  
ROW_NUMBER() OVER (ORDER BY pn.prd_start_date, pn.prd_key) AS product_key,
      pn.prd_id AS product_id,
      pn.prd_key AS product_number,
      pn.prd_nm AS product_name,
      pn.cat_id AS category_id,
      pn.prd_cost AS product_cost,
      pn.prd_line AS product_line,
      pn.prd_start_date AS start_date,
      pc.mainteinance AS maintenance,
      pc.subcat AS subcategory,
      pc.cat AS category

  FROM silver.crm_prd_details pn
  LEFT JOIN silver_erp_px_cat_g1v2 pc
  ON pn.cat_id=pc.id
  WHERE prd_end_dt IS NULL --Filter out all historical data
 
--THIRD DIMENTION VIEW GOLD LAYER (FACT TABLE)

CREATE VIEW gold.fact_sales AS
SELECT    
      sd.sls_ord_num AS order_number,
      pr.product_key,
      cu.customer_key,
      sd.sls_order_dt AS oredr_date,
      sd.sls_ship_dt AS shipping_date,
      sd.sls_due_dt AS due_date,
      sd.sls_sales AS sales_amount,
      sd.sls_quantity AS quantity,
      sd.sls_price,
      dwh_create_date
  FROM silver.crm_sales_details sd
  LEFT JOIN gold.dim_products pr
  ON sd.sls_prd_key=pr.product_number
  LEFT JOIN gold.dim_customers cu
  ON sd.sls_cust_id=cu.customer_id


--To check the FORIEN KEY INTEGRITY (DIMENTION)

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key=f.customer_key 
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
WHERE p.product_key IS NULL
