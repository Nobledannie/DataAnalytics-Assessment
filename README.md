# DataAnalytics-Assessment

1. High-Value Customers with Multiple Products
Using Common Table Expressions: I retrieved customers with regular savings and investment,
combined savings and investment plan data with customer details
Final output to show all customers with both savings and investment plans


2. Transaction Frequency Analysis
Using CTEs I retrieved valid transactions from savings or investment plans,
I calculated each user's tenure in months since they joined
Count the total number of valid transactions for each user
Calculated the average monthly transactions per user
Categorized users based on their transaction frequency
Took Count and average by frequency category


3. Account Inactivity Alert
Retrieved customers with either Regular savings plan or investment plans,
Filtered out plans that are deleted or archived
Considered only confirmed deposited transactions
Find the date of the last confirmed deposit
Calculated the number of days of inactivity
Filtered the result to return plans that has been inactive for moren than 365 days


4. Customer Lifetime Value (CLV) Estimation
Selected users with who has made confirmed transactions
Calculated their tenure
Count the number of transactions made
Estimate the CLV using a custom formula that assumes annualized transaction behaviour and average transaction value
Filtered out customers with zero months of tenure
Ranks users by estimated CLV in descending order
