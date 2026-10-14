-- Your manager now wants analysis that could influence customer retention strategy. 
-- Simple averages aren't enough; you need to compare like with like.

/* Customer risk profile
Create customer segments based on usage frequency, support calls, and payment delays.
For example, classify engagement as low or high, support burden as low or high, and payment behaviour as delayed or not delayed.
Which combinations have the highest churn rates?
*/

-- CTEs, bands split based on higher or lower than median
WITH medians AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY usage_frequency) AS median_usage,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY support_calls) AS median_support,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY payment_delay) AS median_delays
    FROM customers
),
bands AS (
    SELECT
        CASE
            WHEN usage_frequency < median_usage THEN 'Low usage frequency'
            ELSE 'High usage frequency'
        END AS usage_bands,

        CASE
            WHEN support_calls < median_support THEN 'Low no. of support calls'
            ELSE 'High no. of support calls'
        END AS support_bands,

        CASE
            WHEN payment_delay < median_delays THEN 'Low no. of delays'
            ELSE 'High no. of delays'
        END AS delay_bands,
        c.churn
    FROM customers c
    CROSS JOIN medians m
)
SELECT usage_bands,
    support_bands,
    delay_bands,
    -- CONCAT(usage_bands, ' / ', support_bands, ' / ', delay_bands) AS segment,
    ROUND(AVG(churn) * 100, 1) AS churn_rate
FROM bands
GROUP BY usage_bands, support_bands, delay_bands
ORDER BY usage_bands DESC;
