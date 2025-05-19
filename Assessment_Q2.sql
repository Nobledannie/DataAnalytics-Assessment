
-- CTE 1 Get valid transactions from either savings or investment plans
WITH valid_transactions AS (
    SELECT 
        s.owner_id,
        s.transaction_date
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE s.confirmed_amount > 0 -- Only include confirmed transactions
      AND (p.is_regular_savings = 1 OR p.is_a_fund = 1) -- Only savings or investment plans
),
-- CTE 2 Calculate each user's tenure in months since they joined the platform
user_tenure AS (
    SELECT 
        id AS user_id,
        TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months -- How long the user has been active
    FROM users_customuser
),
-- CTE 3 Count the total number of valid transactions for each user
user_transactions_summary AS (
    SELECT 
        vt.owner_id,
        COUNT(*) AS total_transactions -- Total number of deposits across all plans
    FROM valid_transactions vt
    GROUP BY vt.owner_id
),
-- CTE 4 Calculate average monthly transactions per user
user_avg_txns_per_month AS (
    SELECT 
        u.user_id,
        COALESCE(uts.total_transactions, 0) AS total_transactions, -- Fallback to 0 if no transactions
        GREATEST(u.tenure_months, 1) AS tenure_months, -- Avoid division by zero if tenure is 0
        ROUND(COALESCE(uts.total_transactions, 0) / GREATEST(u.tenure_months, 1), 2) AS avg_txns_per_month
		-- This gives the average transactions per month
    FROM user_tenure u
    LEFT JOIN user_transactions_summary uts ON u.user_id = uts.owner_id
),
-- CTE 5 Categorize users based on their transaction frequency
categorized_users AS (
    SELECT 
        *,
        CASE
            WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txns_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_avg_txns_per_month
)
-- Count and average by frequency category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count, -- Number of users in each category
    ROUND(AVG(avg_txns_per_month), 2) AS avg_transactions_per_month -- Average transaction frequency
FROM categorized_users
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category -- Custom sort order: High → Medium → Low
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;
