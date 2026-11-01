const API = "http://localhost:5000/api";

async function loadCustomers() {
    const response = await fetch(`${API}/customers`);
    const data = await response.json();

    document.getElementById("customers").innerHTML = data.map(c => `
        <tr>
            <td>${c.user_id}</td>
            <td>${c.name}</td>
            <td>${c.email}</td>
            <td>${c.phone}</td>
            <td>${c.address || ""}</td>
        </tr>
    `).join("");
}

async function loadAccounts() {
    const response = await fetch(`${API}/accounts`);
    const data = await response.json();

    document.getElementById("accounts").innerHTML = data.map(a => `
        <tr>
            <td>${a.name}</td>
            <td>${a.account_number}</td>
            <td>${a.account_type}</td>
            <td>${a.balance}</td>
            <td>${a.status}</td>
        </tr>
    `).join("");
}

async function loadTransactions() {
    const response = await fetch(`${API}/transactions`);
    const data = await response.json();

    document.getElementById("transactions").innerHTML = data.map(t => `
        <tr>
    <td>${t.transaction_id}</td>
    <td>${t.name}</td>
    <td>${t.account_number}</td>
    <td>${t.transaction_type}</td>
    <td>${t.amount}</td>
    <td>${t.description || "-"}</td>
</tr>
    `).join("");
}


async function loadLoans() {
    const response = await fetch(`${API}/loans`);
    const data = await response.json();

    document.getElementById("loans").innerHTML = data.map(l => `
        <tr>
            <td>${l.name}</td>
            <td>${l.loan_type}</td>
            <td>${l.application_status || "-"}</td>
            <td>${l.loan_amount ?? "-"}</td>
            <td>${l.interest_rate ?? "-"}</td>
        </tr>
    `).join("");
}


async function loadAlerts() {
    const response = await fetch(`${API}/fraud-alerts`);
    const data = await response.json();

    document.getElementById("alerts").innerHTML = data.map(a => `
        <tr>
            <td>${a.alert_id}</td>
            <td>${a.transaction_id}</td>
            <td>${a.alert_type}</td>
            <td>${a.status}</td>
        </tr>
    `).join("");
}

// Load customer details when the page opens
loadCustomers();


async function loadAccountOptions() {
    const response = await fetch(`${API}/accounts`);
    const accounts = await response.json();

    document.getElementById("account_id").innerHTML =
        '<option value="">Select account</option>' +
        accounts.map(a =>
            `<option value="${a.account_id}">${a.name} - ${a.account_number}</option>`
        ).join("");
}

document.getElementById("transactionForm").addEventListener("submit", async (event) => {
    event.preventDefault();

    const message = document.getElementById("transactionMessage");
    message.textContent = "Submitting...";

    try {
        const response = await fetch(`${API}/transactions`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                account_id: document.getElementById("account_id").value,
                transaction_type: document.getElementById("transaction_type").value,
                amount: document.getElementById("amount").value,
                description: document.getElementById("description").value
            })
        });

        const result = await response.json();
        message.textContent = result.message || result.error;

        if (response.ok) {
            document.getElementById("transactionForm").reset();
           await Promise.all([
    loadAccountOptions(),
    loadAccounts(),
    loadTransactions(),
    loadAlerts()
]);
        }
    } catch {
        message.textContent = "Could not connect to the backend.";
    }
});

loadAccountOptions();

async function loadEMIs() {
    const response = await fetch(`${API}/emi-schedule`);
    const data = await response.json();

    document.getElementById("emis").innerHTML = data.map(e => `
        <tr>
            <td>${e.name}</td>
            <td>${e.loan_id}</td>
            <td>${e.emi_number}</td>
            <td>₹${e.emi_amount}</td>
            <td>₹${e.paid_amount}</td>
            <td>${new Date(e.due_date).toLocaleDateString()}</td>
            <td>${e.status}</td>
        </tr>
    `).join("");
}

async function loadCreditScores() {
    const response = await fetch(`${API}/credit-scores`);
    const data = await response.json();

    document.getElementById("creditScores").innerHTML = data.map(c => {
        let category = c.score >= 750 ? "Excellent" :
                       c.score >= 700 ? "Good" :
                       c.score >= 650 ? "Fair" : "Poor";

        return `
            <tr>
                <td>${c.name}</td>
                <td>${c.score}</td>
                <td>${new Date(c.score_date).toLocaleDateString()}</td>
                <td>${category}</td>
            </tr>
        `;
    }).join("");
}



