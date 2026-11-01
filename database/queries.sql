USE banking_loan_db;

-- 1. All customers
SELECT * FROM users;

-- 2. Customers living in London
SELECT * FROM users WHERE address='London';

-- 3. Customers and their account details (JOIN)
SELECT u.name,a.account_number,a.account_type,a.balance
FROM users u JOIN accounts a ON u.user_id=a.user_id;

-- 4. Total and average account balance
SELECT SUM(balance) AS total_balance FROM accounts;
SELECT AVG(balance) AS average_balance FROM accounts;

-- 5. Count accounts by type
SELECT account_type,COUNT(*) AS total_accounts
FROM accounts GROUP BY account_type;

-- 6. Total transaction amounts by type
SELECT transaction_type,SUM(amount) AS total_amount
FROM transactions GROUP BY transaction_type;

-- 7. Customers whose credit score is above average (subquery)
SELECT u.name,c.score
FROM users u JOIN credit_scores c ON u.user_id=c.user_id
WHERE c.score > (SELECT AVG(score) FROM credit_scores);

-- 8. Pending loan applications
SELECT u.name,la.loan_type,la.requested_amount,la.status
FROM users u JOIN loan_applications la ON u.user_id=la.user_id
WHERE la.status='PENDING';

-- 9. Pending EMI instalments
SELECT * FROM emi_schedule WHERE status='PENDING';

-- 10. Views
SELECT * FROM user_account_details;
SELECT * FROM loan_details;
SELECT * FROM transaction_details;

-- 11. UPDATE example (uncomment to run)
-- UPDATE loan_applications SET status='APPROVED' WHERE application_id=3;

-- 12. ROLLBACK demo: the balance change is undone
START TRANSACTION;
UPDATE accounts SET balance=balance-100 WHERE account_id=1;
SELECT balance FROM accounts WHERE account_id=1;
ROLLBACK;
SELECT balance FROM accounts WHERE account_id=1;

-- 13. COMMIT demo: the change is saved
START TRANSACTION;
UPDATE accounts SET balance=balance+100 WHERE account_id=1;
COMMIT;
SELECT balance FROM accounts WHERE account_id=1;
-- Restore the sample balance after demonstrating COMMIT
UPDATE accounts SET balance=balance-100 WHERE account_id=1;

-- 14. Check trigger results
SELECT * FROM fraud_alerts;
SELECT * FROM audit_logs;
SHOW TRIGGERS;
