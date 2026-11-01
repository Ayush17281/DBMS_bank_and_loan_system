DROP DATABASE IF EXISTS banking_loan_db;
CREATE DATABASE banking_loan_db;
USE banking_loan_db;

CREATE TABLE users (
 user_id INT PRIMARY KEY AUTO_INCREMENT,
 name VARCHAR(100) NOT NULL,
 email VARCHAR(100) UNIQUE NOT NULL,
 phone VARCHAR(15) UNIQUE NOT NULL,
 address VARCHAR(255),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
 account_id INT PRIMARY KEY AUTO_INCREMENT,
 user_id INT NOT NULL,
 account_number VARCHAR(20) UNIQUE NOT NULL,
 account_type VARCHAR(20) NOT NULL,
 balance DECIMAL(12,2) DEFAULT 0.00,
 status VARCHAR(20) DEFAULT 'ACTIVE',
 FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE transactions (
 transaction_id INT PRIMARY KEY AUTO_INCREMENT,
 account_id INT NOT NULL,
 transaction_type VARCHAR(20) NOT NULL,
 amount DECIMAL(12,2) NOT NULL,
 transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 description VARCHAR(255),
 FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE loan_applications (
 application_id INT PRIMARY KEY AUTO_INCREMENT,
 user_id INT NOT NULL,
 loan_type VARCHAR(30) NOT NULL,
 requested_amount DECIMAL(12,2) NOT NULL,
 application_date DATE DEFAULT (CURRENT_DATE),
 status VARCHAR(20) DEFAULT 'PENDING',
 FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE loans (
 loan_id INT PRIMARY KEY AUTO_INCREMENT,
 application_id INT NOT NULL,
 loan_amount DECIMAL(12,2) NOT NULL,
 interest_rate DECIMAL(5,2) NOT NULL,
 tenure_months INT NOT NULL,
 start_date DATE,
 status VARCHAR(20) DEFAULT 'ACTIVE',
 FOREIGN KEY (application_id) REFERENCES loan_applications(application_id)
);

CREATE TABLE emi_schedule (
 emi_id INT PRIMARY KEY AUTO_INCREMENT,
 loan_id INT NOT NULL,
 emi_number INT NOT NULL,
 due_date DATE NOT NULL,
 emi_amount DECIMAL(12,2) NOT NULL,
 paid_amount DECIMAL(12,2) DEFAULT 0.00,
 status VARCHAR(20) DEFAULT 'PENDING',
 FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

CREATE TABLE credit_scores (
 credit_score_id INT PRIMARY KEY AUTO_INCREMENT,
 user_id INT NOT NULL,
 score INT NOT NULL,
 score_date DATE DEFAULT (CURRENT_DATE),
 FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE audit_logs (
 audit_id INT PRIMARY KEY AUTO_INCREMENT,
 user_id INT,
 action VARCHAR(100) NOT NULL,
 action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 details VARCHAR(255),
 FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE fraud_alerts (
 alert_id INT PRIMARY KEY AUTO_INCREMENT,
 transaction_id INT NOT NULL,
 alert_type VARCHAR(100) NOT NULL,
 alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 status VARCHAR(20) DEFAULT 'OPEN',
 FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

INSERT INTO users (name,email,phone,address) VALUES
('John Smith','john@gmail.com','9000000001','New York'),
('Emma Wilson','emma@gmail.com','9000000002','London'),
('Daniel Brown','daniel@gmail.com','9000000003','Toronto'),
('Sophia Miller','sophia@gmail.com','9000000004','Sydney'),
('James Anderson','james@gmail.com','9000000005','Chicago');

INSERT INTO accounts (user_id,account_number,account_type,balance,status) VALUES
(1,'ACC10001','SAVINGS',5000,'ACTIVE'),
(2,'ACC10002','SAVINGS',8500,'ACTIVE'),
(3,'ACC10003','CURRENT',12000,'ACTIVE'),
(4,'ACC10004','SAVINGS',3500,'ACTIVE'),
(5,'ACC10005','CURRENT',15000,'ACTIVE'),
(1,'ACC10006','CURRENT',7000,'ACTIVE'),
(3,'ACC10007','SAVINGS',6200,'ACTIVE');

INSERT INTO transactions (account_id,transaction_type,amount,description) VALUES
(1,'DEPOSIT',2000,'Salary Credit'),
(1,'WITHDRAWAL',500,'ATM Withdrawal'),
(2,'DEPOSIT',3000,'Cash Deposit'),
(3,'WITHDRAWAL',1200,'Online Payment'),
(4,'DEPOSIT',1500,'Salary Credit'),
(5,'WITHDRAWAL',2000,'Bill Payment'),
(6,'DEPOSIT',2500,'Bank Transfer'),
(7,'WITHDRAWAL',700,'ATM Withdrawal');

INSERT INTO loan_applications (user_id,loan_type,requested_amount,status) VALUES
(1,'HOME',250000,'APPROVED'),
(2,'CAR',35000,'APPROVED'),
(3,'PERSONAL',15000,'PENDING'),
(4,'EDUCATION',20000,'APPROVED'),
(5,'HOME',180000,'PENDING'),
(1,'PERSONAL',10000,'REJECTED');

INSERT INTO loans (application_id,loan_amount,interest_rate,tenure_months,start_date,status) VALUES
(1,250000,7.50,240,'2026-01-15','ACTIVE'),
(2,35000,6.75,60,'2026-02-01','ACTIVE'),
(4,20000,5.50,48,'2026-03-10','ACTIVE');

INSERT INTO emi_schedule (loan_id,emi_number,due_date,emi_amount,paid_amount,status) VALUES
(1,1,'2026-02-15',2012.50,2012.50,'PAID'),
(1,2,'2026-03-15',2012.50,2012.50,'PAID'),
(1,3,'2026-04-15',2012.50,0,'PENDING'),
(2,1,'2026-03-01',690.50,690.50,'PAID'),
(2,2,'2026-04-01',690.50,0,'PENDING'),
(3,1,'2026-04-10',465,0,'PENDING'),
(3,2,'2026-05-10',465,0,'PENDING');

INSERT INTO credit_scores (user_id,score) VALUES
(1,780),(2,720),(3,690),(4,810),(5,750);

CREATE VIEW user_account_details AS
SELECT u.user_id,u.name,a.account_number,a.account_type,a.balance,a.status
FROM users u JOIN accounts a ON u.user_id=a.user_id;

CREATE VIEW loan_details AS
SELECT u.user_id,u.name,la.application_id,la.loan_type,
       la.status AS application_status,l.loan_id,l.loan_amount,l.interest_rate,l.tenure_months
FROM users u
JOIN loan_applications la ON u.user_id=la.user_id
LEFT JOIN loans l ON la.application_id=l.application_id;

CREATE VIEW transaction_details AS
SELECT u.name,a.account_number,a.account_type,t.transaction_id,
       t.transaction_type,t.amount,t.transaction_date,t.description
FROM users u
JOIN accounts a ON u.user_id=a.user_id
JOIN transactions t ON a.account_id=t.account_id;

DELIMITER //
CREATE TRIGGER check_fraud
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
 IF NEW.amount > 100000 THEN
  INSERT INTO fraud_alerts (transaction_id,alert_type,status)
  VALUES (NEW.transaction_id,'HIGH VALUE TRANSACTION','OPEN');
 END IF;
END//

CREATE TRIGGER audit_new_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
 INSERT INTO audit_logs (user_id,action,details)
 SELECT a.user_id,'TRANSACTION ADDED',
        CONCAT(NEW.transaction_type,' of ',NEW.amount,' on account ',a.account_id)
 FROM accounts a WHERE a.account_id=NEW.account_id;
END//
DELIMITER ;

-- Test both triggers with a high-value transaction
INSERT INTO transactions (account_id,transaction_type,amount,description)
VALUES (1,'WITHDRAWAL',150000,'Test high-value transaction');

SHOW TABLES;
SELECT * FROM fraud_alerts;
SELECT * FROM audit_logs;



