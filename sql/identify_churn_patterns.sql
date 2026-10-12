-- Which behaviours are associated with churn?

/* Support call escalation
Customers with repeated support calls may be experiencing unresolved issues.
Calculate churn rates for customers grouped by support calls (0–2, 3–5, 6+). 
Which group has the highest churn rate, and how many customers does it contain?
*/
WITH support_calls_grouping AS (
    SELECT
        CASE
            WHEN support_calls BETWEEN 0 AND 2 THEN 'Low (0-2)'
            WHEN support_calls BETWEEN 3 AND 5 THEN 'Moderate (3-5)'
            WHEN support_calls >= 6 THEN 'High (6+)'
            ELSE 'Unknown'
        END AS calls_severity,
        churn
    FROM customers
)
SELECT calls_severity,
    TO_CHAR(ROUND(AVG(churn) * 100, 1), 'FM99.0%') AS "Churn rate",
    COUNT(*) AS "Total Customers"
FROM support_calls_grouping
GROUP BY calls_severity
ORDER BY ROUND(AVG(churn), 2);