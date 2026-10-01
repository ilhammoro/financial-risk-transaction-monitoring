-- Financial Risk and Transaction Monitoring Project
-- =====================================================

-- Looking at customer risk and transaction activity
-- to find transactions that may need further review.


-- 1. CUSTOMER OVERVIEW

-- Looking at the customer data
SELECT *
FROM customers;


-- Checking the total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Finding: 500 customers


-- Checking how many customers are High risk
SELECT COUNT(*) AS high_risk_customers
FROM customers
WHERE risk_rating = 'High';

-- Finding: 35 High-risk customers


-- Checking the number of customers in each risk group
SELECT 
    risk_rating,
    COUNT(*) AS number_of_customers
FROM customers
GROUP BY risk_rating
ORDER BY number_of_customers DESC;

-- Finding:
-- Low: 336
-- Medium: 129
-- High: 35


-- Checking which countries the High-risk customers are from
SELECT 
    country,
    COUNT(*) AS high_risk_customers
FROM customers
WHERE risk_rating = 'High'
GROUP BY country
ORDER BY high_risk_customers DESC;

-- Finding:
-- The UK had the most High-risk customers with 28.



-- 2. CUSTOMER ACCOUNTS

-- Joining customers with their accounts
SELECT 
    c.customer_id,
    c.customer_name,
    c.country,
    c.risk_rating,
    a.account_id,
    a.account_type,
    a.account_status
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id;

-- This combines the customer and account information.



-- 3. LARGE TRANSACTIONS

-- I used £7,000 as the threshold for a large transaction
-- in this project.
-- This is just a project rule and not a regulatory threshold.

SELECT
    c.customer_id,
    c.customer_name,
    c.risk_rating,
    c.country AS customer_country,
    a.account_id,
    t.transaction_id,
    t.transaction_date,
    t.amount_gbp,
    t.transaction_country,
    t.channel
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.amount_gbp >= 7000
ORDER BY t.amount_gbp DESC;



-- 4. TRANSACTION OVERVIEW

-- Checking the overall transaction activity
SELECT 
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_gbp)::numeric, 2) AS total_transaction_value,
    ROUND(AVG(amount_gbp)::numeric, 2) AS average_transaction_value,
    ROUND(MAX(amount_gbp)::numeric, 2) AS largest_transaction
FROM transactions;

-- Finding:
-- Total transactions: 12,036
-- Total value: about £3.32 million


-- Checking how many transactions were £7,000 or more
SELECT 
    COUNT(*) AS large_transactions
FROM transactions
WHERE amount_gbp >= 7000;

-- Finding: 90 large transactions


-- Checking the risk ratings of customers making large transactions
SELECT
    c.risk_rating,
    COUNT(*) AS large_transactions,
    ROUND(SUM(t.amount_gbp)::numeric, 2) AS total_large_transaction_value
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.amount_gbp >= 7000
GROUP BY c.risk_rating
ORDER BY large_transactions DESC;

-- Finding:
-- Low: 68
-- Medium: 21
-- High: 1
--
-- Most of the large transactions came from Low-risk customers.


-- Checking for customers with more than one large transaction
SELECT
    c.customer_id,
    c.customer_name,
    c.risk_rating,
    COUNT(*) AS number_of_large_transactions,
    ROUND(SUM(t.amount_gbp)::numeric, 2) AS total_large_transaction_value
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.amount_gbp >= 7000
GROUP BY
    c.customer_id,
    c.customer_name,
    c.risk_rating
HAVING COUNT(*) > 1
ORDER BY number_of_large_transactions DESC,
         total_large_transaction_value DESC;

-- Finding:
-- 8 customers made more than one large transaction.


-- 5. CROSS-BORDER TRANSACTIONS

-- Checking for transactions made in a different country
-- from the customer's country
SELECT
    c.customer_id,
    c.country AS customer_country,
    t.transaction_id,
    t.amount_gbp,
    t.transaction_country
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE c.country <> t.transaction_country;


-- Checking large cross-border transactions
SELECT
    c.customer_id,
    c.risk_rating,
    c.country AS customer_country,
    t.transaction_id,
    t.amount_gbp,
    t.transaction_country
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE c.country <> t.transaction_country
AND t.amount_gbp >= 7000
ORDER BY t.amount_gbp DESC;

-- Finding: 49 large cross-border transactions
