# Digital-Cooperative-Banking-System
This project is a Digital Cooperative Banking System implemented using PostgreSQL and Python Django (for the web interface). 
It includes:
- Customer management
- Account management
- Savings management
- Loan management with Borrowers
- Employee and Branch management
- Credit scoring system for Customers, Borrowers, and Employees
- Audit logging for all critical operations (insert, update, delete)

- ## Features
- Create, update, and delete Customers, Accounts, Savings, Loans, Branches, and Employees
- Automatic audit logs for:
  - Customer updates
  - Account updates and deletions
  - Savings updates and deletions
- Credit scoring system
- Referential integrity enforced through Foreign Keys
- Triggers for maintaining data consistency

## Database Schema
- customer: Stores customer information
- Account: Stores account information linked to customers
- Savings: Records savings transactions
- Loan: Stores loan information linked to customers and borrowers
- Borrower: Stores borrower details for loans
- Branch: Stores corprate bank branch information
- Employee: Stores employee information for branches
- CreditScores: Stores credit ratings for customers, borrowers, and employees
- Audit tables: customer_updation_audit, account_update_audit, account_deletion_audit, savings_update_audit, savings_deletion_audit

## Installation / Setup
1. Install PostgreSQL on your machine.
2. Create a new database:
3. sql
   CREATE DATABASE <data_base_name>;
   ```sql
   CREATE DATABASE coop_bank;
