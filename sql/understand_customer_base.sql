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