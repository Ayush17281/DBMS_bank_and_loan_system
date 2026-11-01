    const express = require("express");
    const mysql = require("mysql2");
    const cors = require("cors");
    require("dotenv").config();

    const app = express();

    app.use(cors());
    app.use(express.json());

    const db = mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    db.connect((err) => {
        if (err) {
            console.log("MySQL connection failed:", err.message);
            return;
        }
        console.log("Connected to MySQL!");
    });

    // Display customers
    app.get("/api/customers", (req, res) => {
        db.query("SELECT * FROM users", (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results);
        });
    });

    // Display customer accounts

app.get("/api/accounts", (req, res) => {
    const sql = `
        SELECT a.account_id, u.name, a.account_number,
               a.account_type, a.balance, a.status
        FROM accounts a
        JOIN users u ON a.user_id = u.user_id
    `;

    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});
    // Display transactions
    app.get("/api/transactions", (req, res) => {
        db.query("SELECT * FROM transaction_details", (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results);
        });
    });

    // Display loans
    app.get("/api/loans", (req, res) => {
        db.query("SELECT * FROM loan_details", (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results);
        });
    });

    // Display fraud alerts
    app.get("/api/fraud-alerts", (req, res) => {
        db.query("SELECT * FROM fraud_alerts", (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results);
        });
    });



app.post("/api/transactions", (req, res) => {
    const { account_id, transaction_type, amount, description } = req.body;

    const accountId = Number(account_id);
    const transactionAmount = Number(amount);

    // Validate input
    if (
        !Number.isInteger(accountId) ||
        accountId <= 0 ||
        !["DEPOSIT", "WITHDRAWAL"].includes(transaction_type) ||
        !Number.isFinite(transactionAmount) ||
        transactionAmount <= 0
    ) {
        return res.status(400).json({
            error: "Enter valid transaction details."
        });
    }

    // Start MySQL transaction
    db.beginTransaction((err) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        // Lock account row while processing
        const checkSql = `
            SELECT balance, status
            FROM accounts
            WHERE account_id = ?
            FOR UPDATE
        `;

        db.query(checkSql, [accountId], (err, accounts) => {
            if (err) {
                return db.rollback(() =>
                    res.status(500).json({ error: err.message })
                );
            }

            if (accounts.length === 0 || accounts[0].status !== "ACTIVE") {
                return db.rollback(() =>
                    res.status(400).json({
                        error: "Active account not found."
                    })
                );
            }

            const currentBalance = Number(accounts[0].balance);

            // Check sufficient balance for withdrawal
            if (
                transaction_type === "WITHDRAWAL" &&
                transactionAmount > currentBalance
            ) {
                return db.rollback(() =>
                    res.status(400).json({
                        error: "Insufficient account balance."
                    })
                );
            }

            // Calculate updated balance
            const newBalance =
                transaction_type === "DEPOSIT"
                    ? currentBalance + transactionAmount
                    : currentBalance - transactionAmount;

            // Update account balance
            const updateSql = `
                UPDATE accounts
                SET balance = ?
                WHERE account_id = ?
            `;

            db.query(updateSql, [newBalance, accountId], (err) => {
                if (err) {
                    return db.rollback(() =>
                        res.status(500).json({ error: err.message })
                    );
                }

                // Insert transaction record
                const insertSql = `
                    INSERT INTO transactions
                    (account_id, transaction_type, amount, description)
                    VALUES (?, ?, ?, ?)
                `;

                db.query(
                    insertSql,
                    [
                        accountId,
                        transaction_type,
                        transactionAmount,
                        description || null
                    ],
                    (err, result) => {
                        if (err) {
                            return db.rollback(() =>
                                res.status(500).json({ error: err.message })
                            );
                        }

                        // Commit only when both operations succeed
                        db.commit((err) => {
                            if (err) {
                                return db.rollback(() =>
                                    res.status(500).json({ error: err.message })
                                );
                            }

                            res.status(201).json({
                                message: "Transaction completed successfully!",
                                transaction_id: result.insertId,
                                previous_balance: currentBalance,
                                new_balance: newBalance
                            });
                        });
                    }
                );
            });
        });
    });
});

// Display EMI schedules
app.get("/api/emi-schedule", (req, res) => {
    const sql = `
        SELECT
            e.emi_id,
            l.loan_id,
            u.name,
            e.emi_number,
            e.emi_amount,
            e.paid_amount,
            e.due_date,
            e.status
        FROM emi_schedule e
        JOIN loans l ON e.loan_id = l.loan_id
        JOIN loan_applications la
            ON l.application_id = la.application_id
        JOIN users u ON la.user_id = u.user_id
        ORDER BY e.due_date;
    `;

    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});


app.get("/api/credit-scores", (req, res) => {
    const sql = `
        SELECT u.user_id, u.name, c.score, c.score_date
        FROM users u
        JOIN credit_scores c ON u.user_id = c.user_id
        ORDER BY c.score DESC
    `;

    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

    app.listen(process.env.PORT || 5000, () => {
        console.log("Server running on port 5000");
    });