create  type Gender as Enum('Male', 'Female', 'Other'); 
create table customer(
Customer_ID varchar(30) primary key,
Full_name varchar(225) not null,
Address varchar(225) not null,
Date_of_Birth DATE,
Gender Gender not null,
Phone_number numeric(15) not null,
Email varchar(50) Unique,
Nationality varchar(50) not null,
Citizenship_number numeric(25) unique
);


create type accounttype as Enum('Saving','Current','Loan','Joint','Fixed_deposit','Recurring_deposit');
create type status as Enum('Active', 'Inactive','Closed');

create table Account(
Account_Number numeric(14) primary key,
Account_type accounttype not null,
Customer_ID varchar(30),
Opening_date date,
status status not null,
totalAmount decimal(15,2),
foreign key (Customer_ID) references customer(Customer_ID)
On update cascade
On delete cascade
);

INSERT INTO account(
	account_number, account_type, customer_id, opening_date, status, totalamount)
	VALUES (100000000001, 'Saving', 'CUST001', '2023-02-15', 'Active', 150000.00),

(100000000002, 'Current', 'CUST002', '2022-11-10', 'Active', 52000.50),

(100000000003, 'Fixed_deposit', 'CUST003', '2024-01-05', 'Active', 300000.00);

select * from account;



CREATE TYPE saving_type AS ENUM('Daily','weekly','Monthly');

CREATE TABLE Savings (
    Saving_ID SERIAL PRIMARY KEY,
    Account_Number NUMERIC(14) REFERENCES Account(Account_Number)
        ON UPDATE CASCADE ON DELETE CASCADE,
    Customer_ID VARCHAR(30) REFERENCES customer(Customer_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    Amount DECIMAL(15,2) NOT NULL,
    Saving_Date DATE DEFAULT CURRENT_DATE,
    Saving_Type saving_type NOT NULL
);
INSERT INTO Savings (
    Account_Number, Customer_ID, Amount, Saving_Date, Saving_Type
)
VALUES
(100000000001, 'CUST001', 2000.00, '2024-03-20', 'weekly'),

(100000000002, 'CUST002', 3500.00, '2024-02-25', 'Monthly'),

(100000000003, 'CUST003', 10000.00, '2024-01-15', 'Monthly');

select * from savings;

create table Branch(
Branch_ID varchar(30) primary key,
Branch_name varchar(225),
Branch_address varchar(225),
Branch_phonenum numeric(15),
Account_number numeric(14),
foreign key (Account_number) references Account(Account_number)
);

INSERT INTO Branch (
    Branch_ID, Branch_name, Branch_address, Branch_phonenum, Account_number
)
VALUES
-- Branch for CUST001 (Saving Account)
('BR001', 'Kathmandu Main Branch', 'New Baneshwor, Kathmandu', 014785210, 100000000001),

-- Branch for CUST002 (Current Account)
('BR002', 'Biratnagar City Branch', 'Traffic Chowk, Biratnagar', 021532145, 100000000002),

-- Branch for CUST003 (Fixed Deposit Account)
('BR003', 'Lalitpur South Branch', 'Jawalakhel, Lalitpur', 015520987, 100000000003);
select * from Branch;

create type trans_type as enum('Deposit', 'Withdrawal','Transfer');
create table Transactions(
Transaction_ID varchar(30) primary key,
Customer_id varchar(30),
Account_number numeric(14),
Transactiontype trans_type not null,
Amount numeric(9,2) not null,
TransactionDate date not null,
TransactionTime time not null,
Description text,
foreign key (Customer_ID) references customer(Customer_ID),
foreign key (Account_number) references Account(Account_number)
on update cascade
on delete cascade
);


create table Employee(
Employee_ID varchar(30) primary key,
Branch_ID varchar(30),
Ename varchar(225) not null,
Eaddress varchar(225) not null,
Ephonenumber  numeric(15) not null,
Eroll varchar(50) not null ,
salary numeric(7,2),
Hiredate date not null,
Leftdate date,
foreign key (Branch_ID) references Branch(Branch_ID)
);

INSERT INTO Employee (
    Employee_ID, Branch_ID, Ename, Eaddress, Ephonenumber, Eroll, salary, Hiredate, Leftdate
)
VALUES
-- Kathmandu Main Branch (CUST001 branch)
('EMP001', 'BR001', 'Sanjay Thapa', 'Koteshwor, Kathmandu', 9841234567,
 'Branch Manager', 85000.00, '2022-05-10', NULL),

('EMP002', 'BR001', 'Anita KC', 'Baneshwor, Kathmandu', 9812345678,
 'Account Officer', 55000.00, '2023-01-12', NULL),

-- Biratnagar City Branch (CUST002 branch)
('EMP003', 'BR002', 'Rohit Yadav', 'Biratnagar-09, Morang', 9807654321,
 'Cashier', 42000.00, '2023-07-05', NULL),

('EMP004', 'BR002', 'Sita Rai', 'Biratnagar-03, Morang', 9823456789,
 'Customer Service Assistant', 38000.00, '2024-02-18', NULL),

-- Lalitpur South Branch (CUST003 branch)
('EMP005', 'BR003', 'Prakash Shrestha', 'Jawalakhel, Lalitpur', 9845566778,
 'Loan Officer', 60000.00, '2022-11-20', NULL);
select * from employee;



create table Borrower(
BorrowerID varchar(30) primary key,
Full_name varchar(225) not null,
Father_name varchar(225) not null,
Mother_name varchar(225) not null,
GrandFather_name varchar(225) not null,
Address varchar(225) not null,
Date_of_Birth DATE,
Gender Gender not null,
Phone_number numeric(15) not null,
Email varchar(50) Unique,
Nationality varchar(50) not null,
Citizenship_number numeric(25) unique,
NationalIdentityNumber numeric(30),
image_path varchar(255),
LoanAmount decimal(15,2) not null,
InterestRate decimal(5,2) not null,
LoanType varchar(50),
StartDate date not null,
EndDate date
);


INSERT INTO Borrower (
    BorrowerID, Full_name, Father_name, Mother_name, GrandFather_name, Address, Date_of_Birth, Gender, Phone_number, Email, 
	Nationality, Citizenship_number, NationalIdentityNumber, image_path, LoanAmount, InterestRate, LoanType, StartDate, EndDate
)
VALUES
-- Borrower for CUST001 (Kathmandu – Business Loan)
('BOR001', 'Rahul Sharma', 'Ramesh Sharma', 'Sita Sharma', 'Hari Prasad Sharma',
 'Kathmandu, Nepal', '1995-03-12', 'Male', 9812345678,
 'rahul.sharma@example.com', 'Nepalese', 1234567890123, 111122223333,
 '/images/borrowers/bor001.jpg',
 250000.00, 11.75, 'Small Business Loan', '2024-02-10', NULL),

-- Borrower for CUST002 (Biratnagar – Personal Loan)
('BOR002', 'Priya Devi', 'Mahesh Devi', 'Gita Devi', 'Ram Prasad Devi',
 'Biratnagar, Nepal', '1998-07-20', 'Female', 9807654321,
 'priya.devi@example.com', 'Nepalese', 4567890123456, 222233334444,
 '/images/borrowers/bor002.jpg',
 120000.00, 12.50, 'Personal Loan', '2023-06-15', '2026-06-15'),

-- Borrower for CUST003 (Lalitpur – FD Secured Loan)
('BOR003', 'Amit Kumar', 'Suresh Kumar', 'Rekha Kumar', 'Bishnu Prasad Kumar',
 'Lalitpur, Nepal', '1992-11-05', 'Male', 9840011223,
 'amit.kumar@example.com', 'Nepalese', 7890123456789, 333344445555,
 '/images/borrowers/bor003.jpg',
 180000.00, 10.25, 'FD Secured Loan', '2023-12-05', '2025-12-05');

 select * from Borrower;



 create table Loan(
LoanID varchar(30) primary key,
CustomerID varchar(30),
Account_Number numeric(14),
BorrowerID varchar(30),
LoanAmount decimal(15,2) not null,
InterestRate decimal(5,2) not null,
LoanType varchar(50),
StartDate date not null,
EndDate date,
FOREIGN KEY (CustomerID)
        REFERENCES customer(Customer_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (Account_Number)
        REFERENCES Account(Account_Number)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (BorrowerID)
        REFERENCES Borrower(BorrowerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


INSERT INTO Loan (
    LoanID, CustomerID, Account_Number, BorrowerID, LoanAmount, InterestRate, LoanType, StartDate, EndDate
)
VALUES
-- Personal Loan for CUST002
('LN001', 'CUST002', 100000000002, 'BOR002',
 120000.00, 12.50, 'Personal Loan', '2023-06-15', '2026-06-15'),

-- Business Loan for CUST001
('LN002', 'CUST001', 100000000001, 'BOR001',
 250000.00, 11.75, 'Small Business Loan', '2024-02-10', NULL),

-- Loan for CUST003
('LN003', 'CUST003', 100000000003, 'BOR003',
 180000.00, 10.25, 'FD Secured Loan', '2023-12-05', '2025-12-05');
 select * from Loan;

create type credit_score as ENUM('One_Star', 'Two_Star','Three_star');
create table CreditScores(
RatedDate DATE DEFAULT CURRENT_DATE,
CustomerID varchar(30),
customerRate credit_score,
BorrowerID varchar(30), 
BorrowerRate credit_score,
Employee_ID varchar(30),
EmployeeRate credit_score,
foreign key(CustomerID) references customer(Customer_ID),
foreign key(BorrowerID) references Borrower(BorrowerID),
foreign key(Employee_ID) references Employee(Employee_ID)
);

INSERT INTO CreditScores (
    RatedDate, CustomerID, customerRate, BorrowerID, BorrowerRate, Employee_ID, EmployeeRate
)
VALUES
-- Rating for CUST001 / BOR001 / EMP001
('2024-03-01', 'CUST001', 'Three_star', 'BOR001', 'Three_star', 'EMP001', 'Three_star'),

-- Rating for CUST002 / BOR002 / EMP003
('2024-03-01', 'CUST002', 'Two_Star', 'BOR002', 'Two_Star', 'EMP003', 'Two_Star'),

-- Rating for CUST003 / BOR003 / EMP005
('2024-03-01', 'CUST003', 'Three_star', 'BOR003', 'Three_star', 'EMP005', 'Three_star');

select * from creditScores;




ALTER TABLE public.customer
    DROP COLUMN password,
    ADD COLUMN fathername VARCHAR(50) NOT NULL,
    ADD COLUMN mothername VARCHAR(50) NOT NULL,
    ADD COLUMN grandfathername VARCHAR(50) NOT NULL;

TRUNCATE TABLE customer CASCADE;

INSERT INTO customer(
	customer_id, full_name, address, date_of_birth, gender, phone_number, email, nationality, citizenship_number, image_path, fathername, mothername, grandfathername)
	VALUES ('CUST001', 'Rahul Sharma', 'Kathmandu, Nepal', '1995-03-12', 'Male',
 9812345678, 'rahul.sharma@example.com', 'Nepalese', 1234567890123,
 '/images/customers/cust001.jpg', 'Ramesh Sharma', 'Sita Sharma', 'Hari Prasad Sharma'),

('CUST002', 'Priya Devi', 'Biratnagar, Nepal', '1998-07-20', 'Female',
 9807654321, 'priya.devi@example.com', 'Nepalese', 4567890123456,
 '/images/customers/cust002.jpg', 'Mahesh Devi', 'Gita Devi', 'Ram Prasad Devi'),

('CUST003', 'Amit Kumar', 'Lalitpur, Nepal', '1992-11-05', 'Male',
 9840011223, 'amit.kumar@example.com', 'Nepalese', 7890123456789,
 '/images/customers/cust003.jpg', 'Suresh Kumar', 'Rekha Kumar', 'Bishnu Prasad Kumar');
	
select * from customer;