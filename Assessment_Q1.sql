-- CTE 1 to retrieve users with regular savings plans
WITH user_savings AS (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.plan_id) AS savings_count, -- Count of unique savings plans
        SUM(s.confirmed_amount) AS total_savings_deposits -- Total amount saved
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_regular_savings = 1 -- Only include regular savings plans
      AND s.confirmed_amount > 0 -- Only include positive deposits
    GROUP BY s.owner_id -- Aggregate by user
),
-- CTE 2 to retrieve customers with investment plans
user_investments AS (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.plan_id) AS investment_count, -- Count of unique investment plans
        SUM(s.confirmed_amount) AS total_investment_deposits -- Total amount invested
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_a_fund = 1
      AND s.confirmed_amount > 0
    GROUP BY s.owner_id
),
-- CTE3 To combine savings and investment plan data with customer details
combined AS (
    SELECT 
        u.id AS owner_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        COALESCE(us.savings_count, 0) AS savings_count, -- Default to 0 if no savings
        COALESCE(ui.investment_count, 0) AS investment_count, -- Default to 0 if no investments
        -- Sum of savings and investment deposits; default to 0 if any is missing
        COALESCE(us.total_savings_deposits, 0) + COALESCE(ui.total_investment_deposits, 0) AS total_deposits
    FROM users_customuser u
    LEFT JOIN user_savings us ON u.id = us.owner_id
    LEFT JOIN user_investments ui ON u.id = ui.owner_id
)

-- Final output to show all customers with both savings and investment plans
SELECT 
    owner_id,
    name,
    savings_count,
    investment_count,
    ROUND(total_deposits / 100.0, 2) AS total_deposits -- convert kobo to naira
FROM combined
WHERE savings_count > 0 -- Ensure customer has at least a savings plan
  AND investment_count > 0 -- Ensure customer has at least an investment plan
ORDER BY total_deposits DESC;
