-- Your manager now wants analysis that could influence customer retention strategy. 
-- Simple averages aren't enough; you need to compare like with like.

/* Customer risk profile
Create customer segments based on usage frequency, support calls, and payment delays.
For example, classify engagement as low or high, support burden as low or high, and payment behaviour as delayed or not delayed.
Which combinations have the highest churn rates?
*/

-- CTEs, bands split based on higher or lower than median
WITH bands AS (
    SELECT
)