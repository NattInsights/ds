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
            WHEN usage_frequency BETWEEN 21 AND 30 THEN 3
        END AS usage_score,
        churn,
        total_spend
        FROM customers
),
risk_scores AS (
    SELECT
        (support_score +
        payment_score +
        usage_score) AS total_risk_score
    FROM rule_based_segments
)
/*risk_segments AS (
    SELECT

)*/
SELECT total_risk_score,
    COUNT(*),
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    AVG(total_spend) AS avg_total_spend
FROM risk_scores
CROSS JOIN rule_based_segments
GROUP BY total_risk_score;

