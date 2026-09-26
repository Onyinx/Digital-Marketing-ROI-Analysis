/* =========================================================================
   DIGITAL MARKETING ROMI ANALYSIS — SQL
   Table: digital_marketing (309 rows, one row per campaign, per day)

   DATA QUALITY NOTE (read before running anything):
   Row id=0 in this table is NOT a real campaign — it is a "Total" summary
   row that existed in the ORIGINAL source spreadsheet (id="Total" there),
   left over from someone totaling the columns for human reference in
   Excel. Its mark_spent/revenue exactly equal the sum of all 308 real
   rows. This is a pre-existing data issue in the source file itself — it
   was already there before this analysis began, and cannot be "fixed" at
   the row level (there is nothing wrong with it to repair; it simply
   should never have been exported as if it were a transaction). Every
   query below excludes it explicitly rather than silently; see Q7 to
   inspect it directly.
   ========================================================================= */


CREATE TABLE digital_marketing (
    id                INT PRIMARY KEY,
    c_date            DATE,
    weekdays          VARCHAR(10),
    category          VARCHAR(20),        
    campaign_id       INT,
    impressions       BIGINT,
    mark_spent        DECIMAL(12,2),
    clicks            INT,
    leads             INT,
    orders            INT,
    revenue           DECIMAL(12,2),
    romi_1            DOUBLE PRECISION,   
    click_percentage  DOUBLE PRECISION,
    conversion_1      DOUBLE PRECISION,
    conversion_2i     DOUBLE PRECISION,
    aov1              DOUBLE PRECISION,
    cpc               DOUBLE PRECISION,
    cpl1              DOUBLE PRECISION,
    cac               DOUBLE PRECISION,
    gross_profit      DOUBLE PRECISION,
    days_type         VARCHAR(10),        
    campaign_name     VARCHAR(20),        
    tier              VARCHAR(20)         
);


/* =========================================================================
   Q1 — BUSINESS QUESTION:Overall, is our marketing spend paying off?
   ========================================================================= */
SELECT
    ROUND(SUM(revenue), 2)                              
	AS total_revenue,
    ROUND(SUM(mark_spent), 2)                           
	AS total_spend,
    ROUND(SUM(revenue) / NULLIF(SUM(mark_spent), 0), 2) 
	AS romi
FROM digital_marketing
WHERE id <> 0;   


/* =========================================================================
   Q2 — BUSINESS QUESTION: Which named campaign performs best?
   ========================================================================= */
SELECT
    campaign_name,
    ROUND(SUM(mark_spent), 2)                         
	AS spend,
    ROUND(SUM(revenue), 2)                               
	AS revenue,
    ROUND(SUM(revenue) / NULLIF(SUM(mark_spent), 0), 2)  
	AS romi
FROM digital_marketing
WHERE id <> 0
GROUP BY campaign_name
ORDER BY romi DESC;


/* =========================================================================
   Q3 — BUSINESS QUESTION: Which date did we spend the most, get the most
   revenue, and what were order values?
   ========================================================================= */
SELECT
    c_date,
    ROUND(SUM(mark_spent), 2)                 
	AS daily_spend,
    ROUND(SUM(revenue), 2)                     
	AS daily_revenue,
    ROUND(AVG(revenue / NULLIF(orders, 0)), 2) 
	AS avg_order_value,
    ROUND(AVG(conversion_1)::numeric, 4)               
	AS avg_conversion_1,
    ROUND(AVG(conversion_2i)::numeric, 4)               
	AS avg_conversion_2
FROM digital_marketing
WHERE id <> 0
GROUP BY c_date
ORDER BY daily_spend DESC
LIMIT 5;


/* =========================================================================
   Q4 — BUSINESS QUESTION: When are buyers more active — weekdays or
   weekends?
   ========================================================================= */
SELECT
    days_type,
    ROUND(AVG(revenue), 2) 
	AS avg_revenue,
    COUNT(*)                
	AS n_rows
FROM digital_marketing
WHERE id <> 0
GROUP BY days_type;


/* =========================================================================
   Q5 — BUSINESS QUESTION: "Which campaign type works best — social,
   banner, influencer, or search? 
   ========================================================================= */
SELECT
    category,
    ROUND(SUM(mark_spent), 2)                            
	AS spend,
    ROUND(SUM(revenue), 2)                               
	AS revenue,
    ROUND(SUM(revenue) / NULLIF(SUM(mark_spent), 0), 2)  
	AS romi
FROM digital_marketing
WHERE id <> 0
GROUP BY category
ORDER BY romi DESC;


/* =========================================================================
   Q6 — BUSINESS QUESTION: Which geo locations are better for targeting —
   tier 1 or tier 2 cities?
   ========================================================================= */
SELECT
    tier,
    ROUND(SUM(mark_spent), 2)                            
	AS spend,
    ROUND(SUM(revenue), 2)                               
	AS revenue,
    ROUND(SUM(revenue) / NULLIF(SUM(mark_spent), 0), 2)  
	AS romi
FROM digital_marketing
WHERE tier IN ('tier1', 'tier2')
  AND id <> 0
GROUP BY tier;


/* =========================================================================
   Q7 — DATA QUALITY: inspect the Total-row anomaly directly, and confirm
   it matches the sum of all real rows (proof it's a Total row, not a
   corrupted campaign)
   ========================================================================= */
SELECT * FROM digital_marketing WHERE id = 0;

SELECT
    ROUND(SUM(mark_spent), 2)
	AS sum_of_real_rows_spend,
    ROUND(SUM(revenue), 2)   
	AS sum_of_real_rows_revenue
FROM digital_marketing
WHERE id <> 0;


/* =========================================================================
   Q8 —  audience-tier / channel-type ROMI
   ========================================================================= */
SELECT
    tier,
    ROUND(SUM(mark_spent), 2)                           
	AS spend,
    ROUND(SUM(revenue), 2)                              
	AS revenue,
    ROUND(SUM(revenue) / NULLIF(SUM(mark_spent), 0), 2)  
	AS romi,
    ROUND(SUM(mark_spent) / NULLIF(SUM(orders), 0), 2)   
	AS cac
FROM digital_marketing
WHERE id <> 0
GROUP BY tier
ORDER BY romi DESC;
