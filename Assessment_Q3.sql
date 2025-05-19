SELECT p.id AS plan_id, -- ID of the savings or investment plan
       p.owner_id, -- ID of the user who owns the plan
       
       -- Date of the most recent confirmed deposit transaction for the plan
       MAX(s.transaction_date) AS last_transaction_date,
       -- Number of days since the last transaction (i.e., inactivity period)
       DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
FROM plans_plan p
-- Join with the savings_savingsaccount table to access transactions
JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE (p.is_regular_savings = TRUE OR p.is_a_fund = TRUE) -- Only savings or investment plans
  AND p.is_deleted = FALSE -- Exclude deleted plans
  AND p.is_archived = FALSE -- Exclude archived plans
  AND s.confirmed_amount > 0  -- Only inflow transactions
  -- Group by plan to aggregate transaction history
GROUP BY p.id, p.name, p.owner_id
-- Return only plans with no transactions in the past 365 days
HAVING MAX(s.transaction_date) < DATE_SUB(CURDATE(), INTERVAL 365 DAY);