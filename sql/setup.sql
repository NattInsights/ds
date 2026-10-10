CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    age INTEGER,
    gender TEXT,
    tenure INTEGER,
    usage_frequency INTEGER,
    support_calls INTEGER,
    payment_delay INTEGER,
    subscription_type TEXT,
    contract_length TEXT,
    total_spend INTEGER,
    last_interaction INTEGER,
    churn INTEGER CHECK (churn IN(0,1))CREATE TABLE customers (
);
