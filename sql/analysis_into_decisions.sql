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

SELECT ROUND(AVG(churn) * 100, 2) AS churn_rate,
    -- dropping by 10%
    (ROUND(AVG(churn) * 100, 2) - 10) AS reduced_churn_rate,
    (COUNT(*) * 0.47) AS churned_customer_count,
    (COUNT(*) * 0.37) AS reduced_churn_customers,
    (COUNT(*) * 0.47 - COUNT(*) * 0.37) AS customers_saved
FROM customers;

SELECT (COUNT(*) - (COUNT(*) * 0.37)) AS total_customers_after,
    total_spend
FROM (SELECT *
    FROM customers
    WHERE churn = 0);

