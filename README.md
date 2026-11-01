# Banking and Loan System

A DBMS course project developed to demonstrate the practical implementation of database management concepts in a banking environment.

## About the Project

The Banking and Loan System is a database-based application designed to store and manage customer details, bank accounts, financial transactions, loan applications, EMI schedules, and credit scores.

The project focuses on applying important DBMS concepts such as relational database design, SQL queries, primary and foreign keys, views, joins, ACID properties, and database triggers.

## Tech Stack

- **Frontend:** HTML, CSS, JavaScript
- **Backend:** Node.js, Express.js
- **Database:** MySQL
- **Database Connectivity:** mysql2

## Key Features

- Customer and bank account records
- Deposit and withdrawal operations
- Transaction history
- Loan applications and loan details
- EMI schedule tracking
- Credit score records
- Automatic fraud alerts for transactions above ₹1,00,000
- Automatic audit log generation

## DBMS Concepts Implemented

| Concept | Application |
|---|---|
| Relational Database | Stores information in related tables |
| Primary Keys | Uniquely identify records |
| Foreign Keys | Establish relationships between tables |
| SQL Queries | Insert, update and retrieve records |
| Joins | Retrieve data from multiple tables |
| Views | Simplify access to related information |
| ACID Properties | Support reliable transaction processing |
| COMMIT & ROLLBACK | Save or undo transaction changes |
| Row Locking | Uses `SELECT ... FOR UPDATE` |
| Triggers | Generate fraud alerts and audit logs |

## Database Tables

- `users`
- `accounts`
- `transactions`
- `loan_applications`
- `loans`
- `emi_schedule`
- `credit_scores`
- `fraud_alerts`
- `audit_logs`

## Project Structure

```text
banking-and-loan-system/
│
├── backend/
│   └── server.js
│
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── database/
│   └── schema.sql
│
├── .env.example
├── .gitignore
└── README.md
```

## How to Run

1. Clone the repository.

```bash
git clone <repository-url>
```

2. Navigate to the project folder.

```bash
cd banking-and-loan-system
```

3. Install backend dependencies.

```bash
cd backend
npm install
```

4. Configure the MySQL database and environment variables.

5. Start the backend server.

```bash
node server.js
```

6. Open `frontend/index.html` in your browser.

## Learning Outcomes

Through this project, we gained practical experience in relational database design, SQL operations, transaction management, ACID properties, database triggers, and connecting a MySQL database with a web application.

## Academic Project

**Course:** Database Management Systems (DBMS)  
**Department:** Computer Science and Engineering (AI)  
**Institute:** Vishwakarma Institute of Technology, Pune
