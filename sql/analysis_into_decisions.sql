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
WITH criteria AS (
    SELECT
        ROUND(AVG(churn) * 100, 2) AS churn_rate,
        AVG(churn) * 100 AS avg_churn_rate,
        COUNT(*) AS customer_count,
        AVG(total_spend) AS avg_total_spend,
        customer_id,
        total_spend
    FROM customers
),
segments AS (
    SELECT
        CASE WHEN churn_rate > avg_churn_rate THEN 'Above avg churn' END AS churn_segment,

        CASE WHEN customer_count >= 
            PERCENTILE_CONT(0.5) WITHIN GROUP 
                (ORDER BY customer_count) THEN 'Meaningful customer count'
        END AS meaningful_customer_count,

        CASE WHEN total_spend > avg_total_spend THEN 'High total spend' END AS meaningful_total_spend
    FROM criteria
)
SELECT *
FROM segments
GROUP BY customer_id;