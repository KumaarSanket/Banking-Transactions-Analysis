# Banking-Transactions-Analysis

# 🏦 Customer Transactions (Banking) Dashboard

![Excel](https://img.shields.io/badge/Microsoft%20Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Records](https://img.shields.io/badge/Records-116%2C162-0A1628?style=for-the-badge)
![Value](https://img.shields.io/badge/Total%20Volume-₹478.57bn-C9A84C?style=for-the-badge)


## 🏦 Banking Transactions Dashboard
![Banking Transactions Dashboard](Banking%20Transactions%20Dashboard.jpeg)

> Data Analytics · K.S. · Tools: Excel → MySQL → Power BI

---

## 📌 Project Overview

Processed 116,201 raw banking transaction records through a 3-tool intermediate pipeline — removing 39 exact duplicates in Excel, engineering 5 derived analytical columns (CATEGORY using CHQ.NO. + keyword detection, TXN_TYPE, AMOUNT, TXN_YEAR, TXN_MONTH), importing 116,162 clean records into MySQL via LOAD DATA LOCAL INFILE after resolving 4 critical import errors. • Designed a MySQL database with 14-column transaction table and 1 analytical VIEW (vw_monthly_summary), executed 7 SQL queries covering KPIs, monthly trends, category breakdown, account performance, and YoY comparison. • Built a 3-page Power BI dashboard (18 visuals) with 7 DAX measures and Sync Slicers, surfacing ₹-1.83bn net negative cash flow, 2016 as peak value year (₹99.72bn deposits), Fund Transfer dominating 70.10% of total transaction value, and 99.22% digital payment adoption.

---

## 🎯 Problem Statement

Banking transaction data for 10 accounts spanning Jan 2015–Mar 2019 existed as a raw Excel file with 116,201 records, no transaction categorisation, no derived columns, and several data quality issues — 39 duplicate rows, dates in MySQL-incompatible formats, and empty cells in amount columns causing strict mode rejections. Management had zero visibility into category-wise spending patterns, account performance, monthly flow trends, or the growing negative balance position across a ₹478.57bn total transaction portfolio.

---

## 🎯 Objectives

- Clean raw banking data in Excel — remove duplicates, fix date formats, engineer 5 derived columns
- Build MySQL database — create schema, import 116,162 rows via LOAD DATA INFILE, execute 7 analytical queries
- Create 1 analytical VIEW (vw_monthly_summary) for Power BI performance optimisation
- Connect Power BI to MySQL live — fix data types, create 7 DAX measures
- Build 3-page dashboard with 18 visuals and Sync Slicers across all pages
- Surface net cash flow position, peak periods, category concentration, and account-level overdraft risk

---

## 📁 Dataset

| Attribute | Detail |
|-----------|--------|
| **Name** | Bank Transaction Data |
| **Source** | [Kaggle — apoorvwatsky/bank-transaction-data](https://www.kaggle.com/datasets/apoorvwatsky/bank-transaction-data) |
| **Format** | Microsoft Excel Workbook (.xlsx) |
| **Raw Records** | 116,201 rows · 9 original columns |
| **Clean Records** | 116,162 rows (39 duplicates removed) |
| **Date Range** | January 1, 2015 – March 5, 2019 |
| **Accounts** | 10 unique bank accounts |

### Final Column Schema (14 Columns in MySQL)

| Column | Type | Source | Description |
|--------|------|--------|-------------|
| account_no | VARCHAR(30) | Original | Bank account identifier |
| txn_date | DATE | Original | Transaction date (YYYY-MM-DD) |
| txn_details | VARCHAR(255) | Original | Description used for keyword categorisation |
| chq_no | VARCHAR(30) | Original (KEPT) | Cheque number — NULL=digital, value=cheque |
| value_date | DATE | Original | Settlement date |
| withdrawal_amt | DECIMAL(18,2) | Original | Withdrawal amount (NULL when deposit) |
| deposit_amt | DECIMAL(18,2) | Original | Deposit amount (NULL when withdrawal) |
| balance_amt | DECIMAL(18,2) | Original | Running balance (97.5% negative) |
| category | VARCHAR(50) | **Derived-Excel** | 11 categories using CHQ.NO. + keywords |
| txn_type | VARCHAR(15) | **Derived-Excel** | DEPOSIT or WITHDRAWAL |
| amount | DECIMAL(18,2) | **Derived-Excel** | Unified amount field |
| txn_year | INT | **Derived-Excel** | Year extracted (2015–2019) |
| txn_month | VARCHAR(15) | **Derived-Excel** | Month-Year string (e.g. Jun-2017) |

---

## 🛠️ Tools & Technologies

| Tool | Phase | Purpose |
|------|-------|---------|
| **Microsoft Excel** | Phase 1 | Data cleaning, duplicate removal, 5 derived columns, CSV export |
| **MySQL 8.0** | Phase 2 | Database design, table creation, bulk import, 7 queries, 1 VIEW |
| **MySQL Workbench** | Phase 2 | GUI client for schema design and query execution |
| **Power BI Desktop** | Phase 3 | Live MySQL connection, DAX measures, 3-page dashboard |
| **DAX** | Phase 3 | 7 calculated measures including Net Flow and Cheque count |
| **Sync Slicers** | Phase 3 | Cross-page filtering across all 3 dashboard pages |

---

## ⚙️ PHASE 1 — Excel (12 Steps)

```
Step 01 → Open bank.xlsx — explore 9-column structure
Step 02 → Delete trailing '.' junk column
Step 03 → Keep CHQ.NO. column — strategic decision (non-null = CHEQUE category)
Step 04 → Fix Account No apostrophe — Ctrl+H → find ' → replace with empty
Step 05 → Fix DATE column — Format Cells → Custom → YYYY-MM-DD
Step 06 → Fix VALUE DATE column — same YYYY-MM-DD format
Step 07 → Create CATEGORY column (col I):
          =IF(D2<>"","CHEQUE", nested SEARCH() for 14 keywords → 11 categories)
Step 08 → Create TXN_TYPE column (col J):
          =IF(F2>0,"WITHDRAWAL","DEPOSIT")
Step 09 → Create AMOUNT column (col K):
          =IF(F2>0,F2,G2)  — takes value from either withdrawal or deposit
Step 10 → Create TXN_YEAR column (col L):
          =YEAR(B2)
Step 11 → Create TXN_MONTH column (col M):
          =TEXT(B2,"MMM-YYYY")
Step 12 → Data → Remove Duplicates → ALL columns → 39 removed → 116,162 rows
Step 13 → File → Save As → CSV UTF-8 → bank_transactions_clean.csv
```

---

## ⚙️ PHASE 2 — MySQL

### Database & Table Creation

```sql
CREATE DATABASE IF NOT EXISTS banking_project;
USE banking_project;

CREATE TABLE bank_transactions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    account_no      VARCHAR(30),
    txn_date        DATE,
    txn_details     VARCHAR(255),
    chq_no          VARCHAR(30),
    value_date      DATE,
    withdrawal_amt  DECIMAL(18,2),
    deposit_amt     DECIMAL(18,2),
    balance_amt     DECIMAL(18,2),
    category        VARCHAR(50),
    txn_type        VARCHAR(15),
    amount          DECIMAL(18,2),
    txn_year        INT,
    txn_month       VARCHAR(15)
);
```

### Fast Bulk Import — LOAD DATA LOCAL INFILE

```sql
-- Enable local infile (server + client side)
SET GLOBAL local_infile = 1;
-- Also add OPT_LOCAL_INFILE=1 in MySQL Workbench → Connection → Advanced → Others

LOAD DATA LOCAL INFILE 'C:/path/to/bank_transactions_clean.csv'
INTO TABLE bank_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(account_no, txn_date, txn_details, chq_no, value_date,
 withdrawal_amt, deposit_amt, balance_amt, category,
 txn_type, amount, txn_year, txn_month);
-- Result: 116,162 rows imported in < 60 seconds
```

### 7 Analytical Queries

```sql
-- Q1: Overall KPIs
SELECT COUNT(*) total_txns,
       SUM(deposit_amt) total_deposits,
       SUM(withdrawal_amt) total_withdrawals,
       SUM(deposit_amt)-SUM(withdrawal_amt) net_flow,
       AVG(balance_amt) avg_balance,
       MAX(deposit_amt) max_deposit,
       MAX(withdrawal_amt) max_withdrawal
FROM bank_transactions;

-- Q2: Monthly Trend
SELECT txn_year, MONTH(txn_date) month_num,
       MONTHNAME(txn_date) month_name,
       COUNT(*) total_txns,
       SUM(deposit_amt) deposits,
       SUM(withdrawal_amt) withdrawals
FROM bank_transactions
GROUP BY txn_year, MONTH(txn_date), MONTHNAME(txn_date)
ORDER BY txn_year, month_num;

-- Q3: Category Breakdown
SELECT category, COUNT(*) txn_count,
       SUM(amount) total_amount,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM bank_transactions),2) pct_share
FROM bank_transactions
GROUP BY category ORDER BY txn_count DESC;

-- Q4: Account Performance
SELECT account_no, COUNT(*) total_txns,
       SUM(deposit_amt) deposits, SUM(withdrawal_amt) withdrawals,
       MAX(balance_amt) max_bal, MIN(balance_amt) min_bal,
       AVG(balance_amt) avg_bal
FROM bank_transactions
GROUP BY account_no ORDER BY total_txns DESC;

-- Q5: Year-over-Year
SELECT txn_year, COUNT(*) total_txns,
       SUM(deposit_amt) deposits, SUM(withdrawal_amt) withdrawals,
       AVG(balance_amt) avg_balance
FROM bank_transactions GROUP BY txn_year ORDER BY txn_year;

-- Q6: Deposit vs Withdrawal Split
SELECT txn_type, COUNT(*) txn_count,
       SUM(amount) total_amount, AVG(amount) avg_amount
FROM bank_transactions GROUP BY txn_type;

-- Q7: Create Analytical VIEW
CREATE VIEW vw_monthly_summary AS
SELECT txn_year, MONTH(txn_date) month_num,
       MONTHNAME(txn_date) month_name, category,
       txn_type, account_no,
       COUNT(*) txn_count,
       SUM(deposit_amt) deposits,
       SUM(withdrawal_amt) withdrawals,
       AVG(balance_amt) avg_balance
FROM bank_transactions
GROUP BY txn_year, MONTH(txn_date), MONTHNAME(txn_date),
         category, txn_type, account_no;
```

---

## 📐 DAX Measures (Power BI)

```dax
Total Deposits = SUM('banking_project bank_transactions'[deposit_amt])
-- ₹238,368,715,323.44

Total Withdrawals = SUM('banking_project bank_transactions'[withdrawal_amt])
-- ₹240,201,132,284.82

Net Flow = [Total Deposits] - [Total Withdrawals]
-- -₹1,832,416,961.38

Total Transactions = COUNTROWS('banking_project bank_transactions')
-- 116,162

Avg Balance = AVERAGE('banking_project bank_transactions'[balance_amt])
-- -₹1,404,802,148

Avg Transaction Amount = AVERAGE('banking_project bank_transactions'[amount])
-- ₹3,805,557 (deposits avg)

Cheque Transactions = COUNTROWS(
    FILTER('banking_project bank_transactions',
           'banking_project bank_transactions'[chq_no] <> BLANK()))
-- 905 (0.78%)
```

> ⚠️ **Key Note:** Single quotes `'banking_project bank_transactions'` required around table name because it contains spaces — mandatory in DAX when table names have spaces.

---

## 📊 3-Page Dashboard Structure (18 Visuals)

### Page 1 — Overview
| # | Visual | Fields |
|---|--------|--------|
| 1 | KPI Card | Total Deposits — ₹238.37bn |
| 2 | KPI Card | Total Withdrawals — ₹240.20bn |
| 3 | KPI Card | Total Transactions — 116,162 |
| 4 | KPI Card | Net Flow — -₹1.83bn |
| 5 | Line Chart | txn_date → Total Transactions |
| 6 | Clustered Column | txn_year → Total Deposits + Total Withdrawals |
| 7 | Slicer | txn_year (synced to all pages) |
| 8 | Slicer | txn_type (synced to all pages) |
| 9 | Slicer | category (synced to all pages) |

### Page 2 — Category & Accounts
| # | Visual | Fields |
|---|--------|--------|
| 10 | Donut Chart | Cheque vs Digital Split (0.78% vs 99.22%) |
| 11 | Bar Chart | account_no → Total Transactions |
| 12 | Bar Chart | category → Total Transactions |
| 13 | Donut Chart | txn_type → Deposits (53.92%) vs Withdrawals (46.08%) |

### Page 3 — Trends & Flow
| # | Visual | Fields |
|---|--------|--------|
| 14 | Clustered Column | txn_year → Total Deposits + Withdrawals |
| 15 | Clustered Column | txn_month → Total Deposits + Withdrawals |
| 16 | Line Chart | txn_date → Avg Balance |
| 17 | Slicer | account_no (Page 3 only) |
| 18 | Sync Slicers | Year/TXN Type/Category applied from Page 1 |

---

## 📈 Key Insights & Results

### Financial Position
- **Total Deposits: ₹238.37bn** | **Total Withdrawals: ₹240.20bn**
- **Net Flow: -₹1.83bn** — persistent negative cash flow across 4+ years
- **97.5% of all balance records are negative** (avg balance -₹1.40bn)
- Max single deposit: ₹544.8M | Max single withdrawal: ₹459.4M

### Year-over-Year
| Year | Transactions | Deposits | Withdrawals |
|------|-------------|----------|-------------|
| 2015 | 15,646 | ₹51.83bn | ₹52.98bn |
| **2016** | **30,367** | **₹99.72bn** | **₹100.11bn** |
| 2017 | 29,112 | ₹57.20bn | ₹56.86bn |
| **2018** | **35,517** | ₹28.54bn | ₹29.16bn |
| 2019 (partial) | 5,520 | ₹1.08bn | ₹1.09bn |

> 2016 = Peak VALUE year | 2018 = Peak VOLUME year

### Category Analysis
| Category | Transactions | Share | Total Amount |
|----------|-------------|-------|-------------|
| OTHER | 61,457 | 52.91% | ₹119.55bn |
| FUND TRANSFER | 33,109 | 28.50% | ₹297.20bn |
| INTERNAL TRANSFER | 16,851 | 14.51% | ₹54.95bn |
| POS PURCHASE | 2,387 | 2.05% | ₹1.98bn |
| ATM/CASH | 1,061 | 0.91% | ₹124.13M |
| CHEQUE | 905 | 0.78% | ₹3.46bn |
| LOAN/EMI | 373 | 0.32% | ₹1.30bn |
| UPI PAYMENT | 16 | 0.01% | ₹179,800 |
| REVERSAL/REFUND | 3 | 0.00% | ₹17,999 |

### Account Analysis
| Account | Transactions | Deposits | Withdrawals | Avg Balance |
|---------|-------------|---------|------------|------------|
| 1196428 | 48,758 | ₹68.30bn | ₹68.45bn | -₹1.67bn |
| 409000362497 | 29,840 | ₹101.72bn | ₹101.94bn | -₹1.47bn |
| 409000438620 | 13,454 | ₹43.21bn | ₹20.20bn | -₹1.44bn |
| 409000405747 | 51 | ₹228.79M | ₹420.32bn | -₹476.68bn ⚠️ |

### Payment Method Split
- **Digital: 115,257 transactions (99.22%)** — overwhelming digital dominance
- **Cheque: 905 transactions (0.78%)** — nearly extinct physical payment method

---

## 📊 KPI Summary

| KPI | Value | KPI | Value |
|-----|-------|-----|-------|
| Total Deposits | **₹238.37bn** | Total Withdrawals | **₹240.20bn** |
| Net Flow | **-₹1.83bn** | Total Transactions | **116,162** |
| Avg Balance | **-₹1.40bn** | Unique Accounts | **10** |
| Deposit Txns | 62,637 (53.92%) | Withdrawal Txns | 53,525 (46.08%) |
| Peak Year Value | 2016 — ₹99.72bn | Peak Year Volume | 2018 — 35,517 txns |
| Peak Month Txns | July 2018 — 3,969 | Peak Month Deposits | April 2016 — ₹9.92bn |
| Digital Txns | 115,257 (99.22%) | Cheque Txns | 905 (0.78%) |

---

## ⚡ Challenges & Solutions

**Challenge 1 — MySQL Date Format Rejection**
'DD-Mon-YY' dates rejected with Error: Incorrect date value. • Fixed: Format Cells → Custom → YYYY-MM-DD in Excel for both DATE and VALUE DATE columns before CSV export.

**Challenge 2 — MySQL Strict Mode Rejecting Empty Amount Cells**
Empty cells in WITHDRAWAL/DEPOSIT AMT rejected as 'Incorrect decimal value'. • Fixed: Recreated table with VARCHAR amounts initially; ultimately resolved via LOAD DATA INFILE handling blanks as NULL.

**Challenge 3 — LOAD DATA LOCAL INFILE Disabled (Error 3948 & 2068)**
Blocked at both server AND client level. • Fixed: SET GLOBAL local_infile=1 (server) + OPT_LOCAL_INFILE=1 in MySQL Workbench connection Advanced settings (client).

**Challenge 4 — Import Wizard Taking 9+ Hours**
GUI wizard processing only 200 rows/min → 9hr estimate for 116,162 rows. • Fixed: LOAD DATA LOCAL INFILE completed same import in under 60 seconds (500x faster).

**Challenge 5 — BOM Character Causing Column Mapping Shift**
CSV UTF-8 encoding added BOM → 'ï»¿Account No' in column mapping screen. • Fixed: Manually mapped this column to account_no in the wizard; BOM is harmless to data values.

**Challenge 6 — DAX Red Line (Space in Table Name)**
'banking_project bank_transactions' has a space → DAX formula error. • Fixed: Single quotes around full table name in every DAX formula.

**Challenge 7 — 14 Visuals Crowding 1 Page**
All visuals on 1 page = unprofessional, unreadable. • Fixed: Restructured into 3-page layout with Sync Slicers connecting pages via View → Sync Slicers.

---

## 🎓 Skills Learned

- **3-Tool Pipeline** — Excel → MySQL → Power BI with each tool playing a distinct role
- **LOAD DATA LOCAL INFILE** — Fastest MySQL import method; 2-level permission system (server + client)
- **MySQL VIEW** — Pre-aggregated vw_monthly_summary for Power BI performance
- **CHQ.NO. as Category Signal** — Physical column takes precedence over text keyword parsing
- **DAX with Space Names** — Single quotes mandatory for table names containing spaces
- **Sync Slicers** — Cross-page filter architecture; Sync vs Visible distinction
- **Banking Data Reading** — Net flow negativity, overdraft signals, value vs volume peaks

---

## 🎨 Custom Theme

`Banking_Premium_Navy_Gold_Theme.json` — Apply via **View → Themes → Browse for themes**

| Element | Color | Meaning |
|---------|-------|---------|
| Canvas | `#0A1628` — Deep Navy | Premium banking identity |
| Visuals | `#112240` — Navy Blue | Professional dark panels |
| KPI Borders | `#C9A84C` — Gold | Premium accent |
| KPI Numbers | `#C9A84C` — Gold | High visibility |
| Title Text | `#C9A84C` — Gold on Navy | Bank report style |
| Data Color 1 | `#C9A84C` — Gold | Primary series |
| Data Color 2 | `#1E88E5` — Blue | Secondary series |

---

## 📂 Repository Structure

```
banking-transactions-dashboard/
│
├── 📊 Banking_Transactions_Dashboard.pbix
├── 📁 Dataset/
│   └── bank.xlsx                              # Raw source (Kaggle)
├── 📁 Cleaned/
│   └── bank_transactions_clean.csv            # After Excel cleaning
├── 📁 MySQL/
│   ├── create_table.sql
│   ├── load_data.sql
│   └── analytical_queries.sql
├── 📁 Theme/
│   └── Banking_Premium_Navy_Gold_Theme.json
├── 📄 Banking_Transactions_Portfolio_Documentation.pdf
└── 📄 README.md
```

---

