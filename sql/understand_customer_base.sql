-- CUSTOMER BASE OVERVIEW
-- How many customers do we have,
-- How many have churned versus remained active? 
-- What percentage of the customer base has churned?

SELECT COUNT(customer_id) AS customer_count,
    COUNT(CASE WHEN churn = 0 THEN 1 END) AS not_churned,
    COUNT(CASE WHEN churn = 1 THEN 1 END) AS churned,
    ROUND(
        100.0 * COUNT(CASE WHEN churn = 1 THEN 1 END)
        / COUNT(customer_id),
        2
    ) AS percentage_churn 
FROM customers; 

-- Does churn differ between gender?
SELECT gender,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(CASE WHEN churn = 1 THEN 1 END)
    / COUNT(customer_id), 2)
    AS percent_churned
FROM customers
GROUP BY gender;

-- Subscription performance
-- Which sub type has the highest churn rate?
SELECT subscription_type AS "Subscription Type",
    COUNT(*) AS "Total Customers",
   SUM(churn) AS "Churned Customers",
    ROUND(AVG(churn) * 100, 2)
    AS "Churn rate (%)"
FROM customers
GROUP BY subscription_type;

-- CUSTOMER TENURE
-- What is the average customer tenure for churned customers versus retained customers?
-- Is there an apparent difference in how long each group has been with the company?
WITH customer_status AS (
    SELECT
        CASE 
            WHEN churn = 1 THEN 'Churned'  
            WHEN churn = 0 THEN 'Retained'
            ELSE 'Unknown'
        END AS churn_type,
        tenure
    FROM customers
)
SELECT
    churn_type AS "Churn Type",
    COUNT(*) AS "Total Customers",
    ROUND(AVG(tenure), 2) AS "Average Tenure"
FROM customer_status
GROUP BY churn_type;

-- Spending patterns
-- What is the average and total customer spend for churned and retained customers?
-- Which group accounts for more total spend in the dataset?
WITH customer_spend AS(
    SELECT
        CASE
            WHEN churn = 0 THEN 'Churned'
            WHEN churn = 1 THEN 'Retained'
            ELSE 'Unknown'
        END AS churn_type,
        total_spend
    FROM customers
)
SELECT churn_type AS "Churn Type",
    TO_CHAR(SUM(total_spend), 'FM999,999,999,990.00') AS "Total Spend",
    ROUND(AVG(total_spend), 2) AS "Average Spend"
FROM customer_spend
GROUP BY churn_type;

-- Payment delays and retention
WITH payment_delays AS (
    SELECT
        CASE
            WHEN payment_delay BETWEEN 0 AND 5 THEN 'Very low (0-5)'
            WHEN payment_delay BETWEEN 6 AND 10 THEN 'Low (6-10)'
            WHEN payment_delay BETWEEN 11 AND 20 THEN 'Moderate (11-20)'
            WHEN payment_delay >= 21 THEN 'High (21+)'
        END AS delay_bands,
        churn
    FROM customers
)
SELECT
    delay_bands AS "Payment delay bands",
    COUNT(*) AS "No. of Customers",
    TO_CHAR(ROUND(AVG(churn) * 100, 1), 'FM99.0%') AS "Churn rate"
FROM payment_delays
GROUP BY delay_bands;




