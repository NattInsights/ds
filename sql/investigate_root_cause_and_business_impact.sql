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
    CONCAT(usage_bands, ' / ', support_bands, ' / ', delay_bands) AS segment,
    ROUND(AVG(churn) * 100, 1) AS churn_rate
FROM bands
GROUP BY usage_bands, support_bands, delay_bands;

/* Separate tenure effects from subscription effects
The team believes monthly contracts churn more frequently.
Compare churn rates by contract length within each tenure band (for example, 0–12, 13–24, 25–36, 37+ months).
Does the contract pattern persist across tenure groups?
*/

WITH tenure_bands AS (
    SELECT
        CASE WHEN tenure BETWEEN 0 AND 12 THEN '0-12 months'
            WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
            WHEN tenure BETWEEN 25 AND 36 THEN '25-36 months'
            WHEN tenure >= 37 THEN '37+ months'
            ELSE 'Not found'
        END AS tenure_band,
        churn,
        contract_length
    FROM customers
)
SELECT tenure_band,
    contract_length,
    TO_CHAR(ROUND(AVG(churn) * 100, 1), 'FM99.0%') AS "Churn rate"
FROM tenure_bands
GROUP BY tenure_band, contract_length
ORDER BY contract_length, tenure_band;

/* Quantify the spending associated with churn
Calculate the total spend associated with churned customers, their average spend, and their share of total recorded customer spend.
Break the results down by subscription type and contract length.
*/

SELECT ROUND(AVG(total_spend), 2) AS average_spend,
    TO_CHAR(SUM(total_spend), 'FM999,999,999') AS total_spend,
    -- optional add sign to the above formatting depending on currency
    subscription_type,
    contract_length
FROM (
    SELECT *
    FROM customers
    WHERE churn = 1
)
GROUP BY subscription_type, contract_length
ORDER BY subscription_type, contract_length;

/* Find the strongest churn indicators
Compare churn rates across customer groups defined by support calls, usage frequency, payment delays, and time since last interaction.
Rank the resulting segments by their difference in churn rate from the overall baseline.
*/

 -- Compute baseline churn rate
WITH baseline AS (
    SELECT AVG(churn) AS baseline_churn
    FROM customers
),
-- 2. Build behavioural bands
bands AS (
    SELECT
        customer_id,
        churn,

        CASE 
            WHEN support_calls BETWEEN 0 AND 2 THEN 'Very Low calls'
            WHEN support_calls BETWEEN 3 AND 4 THEN 'Low calls'
            WHEN support_calls BETWEEN 5 AND 6 THEN 'Moderate calls'
            WHEN support_calls >= 7 THEN 'High calls'
        END AS support_calls_band,

        CASE 
            WHEN usage_frequency BETWEEN 0 AND 5 THEN 'Very Low frequency'
            WHEN usage_frequency BETWEEN 6 AND 12 THEN 'Low frequency'
            WHEN usage_frequency BETWEEN 13 AND 20 THEN 'Moderate frequency'
            WHEN usage_frequency >= 21 THEN 'High frequency'
        END AS usage_frequency_band,

        CASE 
            WHEN payment_delay BETWEEN 0 AND 5 THEN 'Very Low delays'
            WHEN payment_delay BETWEEN 6 AND 12 THEN 'Low delays'
            WHEN payment_delay BETWEEN 13 AND 20 THEN 'Moderate delays'
            WHEN payment_delay >= 21 THEN 'High delays'
        END AS payment_delay_band
),
-- 3. Compute churn rate per segment
segment_churn AS (
    SELECT
        support_calls_band,
        usage_frequency_band,
        payment_delay_band
        ROUND(AVG(churn) * 100, 2) AS churn_rate
    FROM bands
    GROUP BY
        support_calls_band,
        usage_frequency_band,
        payment_delay_band,
)
-- 4. Rank segments by churn lift
SELECT
    s.*,
    ROUND(s.churn_rate - (b.baseline_churn * 100), 2) AS churn_lift
FROM segment_churn s
CROSS JOIN baseline b
ORDER BY churn_lift DESC;
-- implementation still a bit iffy here


