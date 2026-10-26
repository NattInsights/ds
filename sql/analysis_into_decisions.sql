/* Design a retention prioritisation score
Build a rule-based score using support calls, payment delays, usage frequency. 
Assign each customer a risk score and classify them into low-, medium-, and high-risk groups. 
Report each group's size, churn rate, and average total spend.
*/
WITH rule_based_segments AS (
    SELECT
        CASE WHEN support_calls BETWEEN 0 AND 2 THEN 0
            WHEN support_calls BETWEEN 3 AND 6 THEN 1
            WHEN support_calls BETWEEN 7 AND 10 THEN 2
        END AS support_score,

        CASE WHEN payment_delay BETWEEN 0 AND 5 THEN 0
            WHEN payment_delay BETWEEN 6 AND 12 THEN 1
            WHEN payment_delay BETWEEN 13 AND 20 THEN 2
            WHEN payment_delay BETWEEN 21 AND 30 THEN 4
        END AS payment_score,

        CASE WHEN usage_frequency BETWEEN 0 AND 5 THEN 0
            WHEN usage_frequency BETWEEN 6 AND 12 THEN 1
            WHEN usage_frequency BETWEEN 13 AND 20 THEN 2
            WHEN usage_frequency BETWEEN 21 AND 30 THEN 4
        END AS usage_score,

        churn,
        total_spend,
        customer_id
        FROM customers
),
risk_scores AS (
    SELECT
        customer_id,
        (support_score + payment_score + usage_score) AS total_risk_score
    FROM rule_based_segments
),
risk_segments AS (
    SELECT
        customer_id,
        total_risk_score,
        CASE WHEN total_risk_score BETWEEN 0 AND 3 THEN 'Low Risk'
            WHEN total_risk_score BETWEEN 4 AND 6 THEN 'Medium Risk'
            WHEN total_risk_score BETWEEN 7 AND 10 THEN 'High Risk'
        END AS risk_classification
    FROM risk_scores
)
SELECT rs.total_risk_score,
    rs.risk_classification,
    COUNT(*) AS customer_count,
    ROUND(AVG(rbs.churn) * 100, 2) AS churn_rate,
    ROUND(AVG(rbs.total_spend), 1) AS avg_total_spend
FROM risk_segments rs
JOIN rule_based_segments rbs USING (customer_id)
GROUP BY rs.total_risk_score, rs.risk_classification
ORDER BY rs.total_risk_score;

/* Estimate the opporrtunity from reducing churn
Suppose the business wants to reduce its overall churn rate by 10% relative to the current rate.
Calculate how many fewer churned customers this represents, assuming the customer base stays constant.
Then estimate the recorded spend associated with that number of customers using the average spend of churned customers.
*/

WITH base AS (
    SELECT 
        COUNT(*) AS total_customers,
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
        -- very clean average total spend for churned below
        ROUND(AVG(CASE WHEN churn = 1 THEN total_spend END), 2) AS avg_spend_churned
    FROM customers
),
calc AS (
    SELECT
        total_customers,
        churned_customers,
        avg_spend_churned,
        -- current churn rate
        ROUND(churned_customers::decimal / total_customers, 4) AS churn_rate,
        -- 10% relative reduction
        ROUND((churned_customers::decimal / total_customers) * 0.9, 4) AS reduced_churn_rate
    FROM base
),
final AS (
    SELECT
        *,
        -- churned customers after reduction
        ROUND(total_customers * reduced_churn_rate) AS reduced_churn_customers,
        -- customers saved
        churned_customers - ROUND(total_customers * reduced_churn_rate) AS customers_saved,
        -- spend saved
        ROUND((churned_customers - (total_customers * reduced_churn_rate)) * avg_spend_churned, 2)
            AS est_spend_saved
    FROM calc
)
SELECT *
FROM final;

/* Finding the highest priority retention segments
Identify customer segments that have all three characteristics: an above-average churn rate, a meaningful number of customers, and above-average total spend.
Rank the segments using a clearly defined prioritisation metric and recommend which three the retention team should investigate first.
*/
WITH benchmarks AS (
    SELECT
        ROUND(AVG(churn) * 100, 2) AS baseline_churn,
        ROUND(AVG(total_spend), 2) AS baseline_spend
    FROM customers
), 
segments AS (
    SELECT
        customer_id,
        churn,
        total_spend,

        CASE WHEN support_calls BETWEEN 0 AND 2 THEN 'Very Low'
            WHEN support_calls BETWEEN 3 AND 4 THEN 'Low'
            WHEN support_calls BETWEEN 5 AND 6 THEN 'Moderate'
            ELSE 'High'
        END AS support_calls_band,

        CASE WHEN usage_frequency BETWEEN 0 AND 5 THEN 'Very Low'
            WHEN usage_frequency BETWEEN 6 AND 12 THEN 'Low'
            WHEN usage_frequency BETWEEN 13 AND 20 THEN 'Moderate'
            ELSE 'High'
        END AS usage_band,

        CASE WHEN payment_delay BETWEEN 0 AND 5 THEN 'Very Low'
             WHEN payment_delay BETWEEN 6 AND 12 THEN 'Low'
             WHEN payment_delay BETWEEN 13 AND 20 THEN 'Moderate'
             ELSE 'High'
        END AS delay_band
    FROM customers
),
segment_metrics AS (
    SELECT
        support_calls_band,
        usage_band,
        delay_band,

        COUNT(*) AS customer_count,
        AVG(churn) * 100 AS churn_rate,
        AVG(total_spend) AS avg_spend
    FROM segments
    GROUP BY
        support_calls_band,
        usage_band,
        delay_band
),
segment_averages AS (
    SELECT AVG(customer_count) AS avg_segment_count
    FROM segment_metrics
),
scored AS (
    SELECT
        sm.support_calls_band,
        sm.usage_band,
        sm.delay_band,
        sm.customer_count,
        sm.churn_rate,
        sm.avg_spend,

        CASE WHEN sm.churn_rate > b.baseline_churn THEN 1 ELSE 0 END AS sig_churn,
        CASE WHEN sm.customer_count > sa.avg_segment_count THEN 1 ELSE 0 END AS sig_count,
        CASE WHEN sm.avg_spend > b.baseline_spend THEN 1 ELSE 0 END AS sig_spend,
        -- total severity score
        (CASE WHEN sm.churn_rate > b.baseline_churn THEN 1 ELSE 0 END +
         CASE WHEN sm.customer_count > sa.avg_segment_count THEN 1 ELSE 0 END +
         CASE WHEN sm.avg_spend > b.baseline_spend THEN 1 ELSE 0 END) AS severity_total

    FROM segment_metrics sm
    CROSS JOIN benchmarks b
    CROSS JOIN segment_averages sa
)
SELECT *
FROM scored
ORDER BY churn_rate DESC
LIMIT 20;

