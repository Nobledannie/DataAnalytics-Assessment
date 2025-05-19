SELECT 
    u.id AS user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
     -- Calculate how long the user has been on the platform (in months)
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    -- Total number of confirmed transactions made by the user
    COUNT(s.id) AS total_transactions,
    
     -- Estimate Customer Lifetime Value (CLV)
    ROUND(
        (COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())-- Avg transactions per month
        ) * 12 * -- Annualize it
        ((SUM(s.confirmed_amount) * 0.001) / COUNT(s.id) -- Average transaction value in Naira (from Kobo)
        ), 2
    ) AS estimated_clv
FROM users_customuser u
JOIN savings_savingsaccount s 
    ON u.id = s.owner_id
    -- Consider only confirmed deposit transactions
WHERE s.confirmed_amount > 0
-- Group by user for aggregation
GROUP BY u.id, u.email, u.date_joined
-- Filter out users who have been on the platform less than 1 month
HAVING tenure_months > 0
-- Rank users by their estimated CLV (highest first)
ORDER BY estimated_clv DESC;
