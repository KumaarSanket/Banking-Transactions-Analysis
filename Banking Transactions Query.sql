CREATE DATABASE IF NOT EXISTS banking_project;
USE banking_project;

CREATE TABLE bank_transactions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    account_no      VARCHAR(30),
    txn_date        DATE,
    txn_details     VARCHAR(255),
    chq_no          VARCHAR(30),
    value_date      DATE,
    withdrawal_amt  DECIMAL(18,2) DEFAULT 0,
    deposit_amt     DECIMAL(18,2) DEFAULT 0,
    balance_amt     DECIMAL(18,2),
    category        VARCHAR(50),
    txn_type        VARCHAR(15),
    amount          DECIMAL(18,2),
    txn_year        INT,
    txn_month       VARCHAR(15)
);

ALTER TABLE bank_transactions 
MODIFY withdrawal_amt DECIMAL(18,2) NULL DEFAULT NULL,
MODIFY deposit_amt DECIMAL(18,2) NULL DEFAULT NULL,
MODIFY balance_amt DECIMAL(18,2) NULL DEFAULT NULL,
MODIFY amount DECIMAL(18,2) NULL DEFAULT NULL;

USE banking_project;
SET GLOBAL sql_mode = '';
SET SESSION sql_mode = '';

USE banking_project;
TRUNCATE TABLE bank_transactions;

USE banking_project;

DROP TABLE IF EXISTS bank_transactions;

CREATE TABLE bank_transactions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    account_no      VARCHAR(30),
    txn_date        DATE,
    txn_details     VARCHAR(255),
    chq_no          VARCHAR(30),
    value_date      DATE,
    withdrawal_amt  VARCHAR(30),
    deposit_amt     VARCHAR(30),
    balance_amt     VARCHAR(30),
    category        VARCHAR(50),
    txn_type        VARCHAR(15),
    amount          VARCHAR(30),
    txn_year        VARCHAR(10),
    txn_month       VARCHAR(15)
);

SELECT * FROM bank_transactions ;

USE banking_project;
ALTER TABLE bank_transactions 
MODIFY account_no VARCHAR(30);

UPDATE bank_transactions 
SET account_no = TRIM(TRAILING '.00' FROM account_no);



SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';

USE banking_project;
TRUNCATE TABLE bank_transactions;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank.csv'
INTO TABLE bank_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(account_no, txn_date, txn_details, chq_no, value_date, withdrawal_amt, deposit_amt, balance_amt, category, txn_type, amount, txn_year, txn_month);


SELECT * FROM bank_transactions;
SELECT COUNT(*) FROM bank_transactions;

USE banking_project;

ALTER TABLE bank_transactions 
MODIFY withdrawal_amt DECIMAL(18,2),
MODIFY deposit_amt DECIMAL(18,2),
MODIFY balance_amt DECIMAL(18,2),
MODIFY amount DECIMAL(18,2);

SELECT MAX(withdrawal_amt), 
MIN(withdrawal_amt),
AVG(withdrawal_amt)
FROM bank_transactions
WHERE withdrawal_amt > 0;

USE banking_project;
DELETE FROM bank_transactions 
WHERE txn_date = '0000-00-00' 
OR txn_date IS NULL 
OR account_no IS NULL 
OR account_no = '';

-- Query 1 — Overall KPIs:
SELECT
    COUNT(*) AS total_transactions,
    SUM(deposit_amt) AS total_deposits,
    SUM(withdrawal_amt) AS total_withdrawals,
    SUM(deposit_amt) - SUM(withdrawal_amt) AS net_flow,
    COUNT(DISTINCT account_no) AS unique_accounts,
    AVG(balance_amt) AS avg_balance,
    MAX(deposit_amt) AS max_single_deposit,
    MAX(withdrawal_amt) AS max_single_withdrawal
FROM bank_transactions;

-- Query 2 — Monthly Trend:
SELECT
    txn_year,
    MONTH(txn_date) AS month_num,
    MONTHNAME(txn_date) AS month_name,
    COUNT(*) AS total_txns,
    SUM(deposit_amt) AS total_deposits,
    SUM(withdrawal_amt) AS total_withdrawals,
    SUM(deposit_amt) - SUM(withdrawal_amt) AS net_flow
FROM bank_transactions
GROUP BY txn_year, MONTH(txn_date), MONTHNAME(txn_date)
ORDER BY txn_year, month_num;

-- Query 3 — Spending by Category:
SELECT
    category,
    COUNT(*) AS txn_count,
    SUM(amount) AS total_amount,
    SUM(deposit_amt) AS total_deposits,
    SUM(withdrawal_amt) AS total_withdrawals,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bank_transactions), 2) AS pct_share
FROM bank_transactions
GROUP BY category
ORDER BY txn_count DESC;

-- Query 4 — Account-wise Performance:
SELECT
    account_no,
    COUNT(*) AS total_txns,
    SUM(deposit_amt) AS total_deposits,
    SUM(withdrawal_amt) AS total_withdrawals,
    MAX(balance_amt) AS max_balance,
    MIN(balance_amt) AS min_balance,
    AVG(balance_amt) AS avg_balance
FROM bank_transactions
GROUP BY account_no
ORDER BY total_txns DESC;

-- Query 5 — Year-over-Year:
SELECT
    txn_year,
    COUNT(*) AS total_txns,
    SUM(deposit_amt) AS total_deposits,
    SUM(withdrawal_amt) AS total_withdrawals,
    AVG(balance_amt) AS avg_balance
FROM bank_transactions
GROUP BY txn_year
ORDER BY txn_year;

-- Query 6 — Deposit vs Withdrawal Split:
SELECT
    txn_type,
    COUNT(*) AS txn_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    MAX(amount) AS max_amount
FROM bank_transactions
GROUP BY txn_type;

-- Query 7 — Create VIEW:
CREATE VIEW vw_monthly_summary AS
SELECT
    txn_year,
    MONTH(txn_date) AS month_num,
    MONTHNAME(txn_date) AS month_name,
    category,
    txn_type,
    account_no,
    COUNT(*) AS txn_count,
    SUM(deposit_amt) AS deposits,
    SUM(withdrawal_amt) AS withdrawals,
    AVG(balance_amt) AS avg_balance
FROM bank_transactions
GROUP BY txn_year, MONTH(txn_date),
         MONTHNAME(txn_date), category,
         txn_type, account_no;
         
SELECT COUNT(*) FROM bank_transactions;

SELECT txn_date FROM bank_transactions LIMIT 5;

SHOW FULL TABLES IN banking_project WHERE TABLE_TYPE = 'VIEW';