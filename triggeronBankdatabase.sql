-- CUSTOMER_TRIGGER
CREATE TABLE customer_updation_audit(
    customerid_bef VARCHAR(30) NOT NULL,
	customerid_aft VARCHAR(30) NOT NULL,
    full_name_bef VARCHAR(225) NOT NULL,
	full_name_aft VARCHAR(225) NOT NULL,
    address_bef VARCHAR(225) NOT NULL,
	address_aft VARCHAR(225) NOT NULL,
    date_of_birth_bef DATE NOT NULL,
	date_of_birth_aft DATE NOT NULL,
    gender_bef gender NOT NULL,
	gender_aft gender NOT NULL,
    phonenumber_bef NUMERIC(15,0) NOT NULL,
	phonenumber_aft NUMERIC(15,0) NOT NULL,
    email_bef VARCHAR(50), 
	email_aft VARCHAR(50), 
    nationality_bef VARCHAR(50) NOT NULL,
	nationality_aft VARCHAR(50) NOT NULL,
    citizenship_number_bef NUMERIC(25,0), 
	citizenship_number_aft NUMERIC(25,0), 
    fathername_bef VARCHAR(50) NOT NULL,
	fathername_aft VARCHAR(50) NOT NULL, 
    mothername_bef VARCHAR(50) NOT NULL,
	mothername_aft VARCHAR(50) NOT NULL,
	grandfathername_bef VARCHAR(50) NOT NULL,
	grandfathername_aft VARCHAR(50) NOT NULL,
	updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION customers_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO customer_updation_audit(
        customerid_bef, customerid_aft, full_name_bef, full_name_aft, address_bef, address_aft, date_of_birth_bef,date_of_birth_aft, 
		gender_bef, gender_aft, phonenumber_bef,phonenumber_aft, email_bef, email_aft, nationality_bef,nationality_aft, citizenship_number_bef,
        citizenship_number_aft, fathername_bef,fathername_aft,  mothername_bef,mothername_aft, grandfathername_bef,grandfathername_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.customer_id, NEW.customer_id, OLD.full_name, NEW.full_name, OLD.address, NEW.address, OLD.date_of_birth, NEW.date_of_birth,
		OLD.gender, NEW.gender, OLD.phone_number, NEW.phone_number, OLD.email, NEW.email, OLD.nationality, NEW.nationality, OLD.citizenship_number,
        NEW.citizenship_number, OLD.fathername, NEW.fathername, OLD.mothername,  NEW.mothername, OLD.grandfathername, NEW.grandfathername,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customers_update_auditlog
AFTER UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION customers_update_auditlog();


UPDATE customer
SET 
    address = 'Lazimpat, Kathmandu',
    phone_number = 9801111222
WHERE customer_id = 'CUST002';

UPDATE customer
SET
    full_name = 'Priya D. Devi',
    nationality = 'Nepalese'
WHERE customer_id = 'CUST002';

SELECT * 
FROM customer_updation_audit
ORDER BY updated_at DESC;


--ACCOUNT
--delate
CREATE TABLE account_deletion_audit(
    account_number_bef NUMERIC(14) NOT NULL,
    account_type_bef accounttype NOT NULL,
    customer_id_bef VARCHAR(30),
    opening_date_bef DATE,
    status_bef status NOT NULL,
    totalamount_bef DECIMAL(15,2),
    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION account_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO account_deletion_audit (
        account_number_bef, account_type_bef, customer_id_bef,
        opening_date_bef, status_bef, totalamount_bef,
        deleted_by, deleted_at
    )
    VALUES (
        OLD.account_number, OLD.account_type, OLD.customer_id,
        OLD.opening_date, OLD.status, OLD.totalamount,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_delete_trigger
BEFORE DELETE ON account
FOR EACH ROW
EXECUTE FUNCTION account_delete_auditlog();

select * from account_deletion_audit;

--update
CREATE TABLE account_update_audit(
    account_number_bef NUMERIC(14),
    account_number_aft NUMERIC(14),
    account_type_bef accounttype NOT NULL,
    account_type_aft accounttype NOT NULL,
    customer_id_bef VARCHAR(30),
    customer_id_aft VARCHAR(30),
    opening_date_bef DATE,
    opening_date_aft DATE,
    status_bef status NOT NULL,
    status_aft status NOT NULL,
    totalamount_bef DECIMAL(15,2),
    totalamount_aft DECIMAL(15,2),
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION account_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO account_update_audit(
        account_number_bef, account_number_aft,
        account_type_bef, account_type_aft,
        customer_id_bef, customer_id_aft,
        opening_date_bef, opening_date_aft,
        status_bef, status_aft,
        totalamount_bef, totalamount_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.account_number, NEW.account_number,
        OLD.account_type, NEW.account_type,
        OLD.customer_id, NEW.customer_id,
        OLD.opening_date, NEW.opening_date,
        OLD.status, NEW.status,
        OLD.totalamount, NEW.totalamount,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_update_trigger
AFTER UPDATE ON account
FOR EACH ROW
EXECUTE FUNCTION account_update_auditlog();

-- View all account deletions
SELECT * FROM account_deletion_audit;

-- add cascade function to all these below table because in original table there wasn't cascade funtion and it give error while deleting and updating;
ALTER TABLE Branch
DROP CONSTRAINT branch_account_number_fkey;

ALTER TABLE Branch
ADD CONSTRAINT branch_account_number_fkey
FOREIGN KEY (Account_number)
REFERENCES Account(Account_number)
ON DELETE CASCADE
ON UPDATE CASCADE;
select * from branch;

-- Drop old FK
ALTER TABLE Employee
DROP CONSTRAINT employee_branch_id_fkey;

-- Add FK with cascade
ALTER TABLE Employee
ADD CONSTRAINT employee_branch_id_fkey
FOREIGN KEY (Branch_ID)
REFERENCES Branch(Branch_ID)
ON DELETE CASCADE
ON UPDATE CASCADE;
select * from employee;

--old FK
ALTER TABLE CreditScores
DROP CONSTRAINT creditscores_customerid_fkey,
DROP CONSTRAINT creditscores_borrowerid_fkey,
DROP CONSTRAINT creditscores_employee_id_fkey;

ALTER TABLE CreditScores
ADD CONSTRAINT creditscores_customerid_fkey
FOREIGN KEY (CustomerID) REFERENCES customer(Customer_ID)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE CreditScores
ADD CONSTRAINT creditscores_borrowerid_fkey
FOREIGN KEY (BorrowerID) REFERENCES Borrower(BorrowerID)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE CreditScores
ADD CONSTRAINT creditscores_employee_id_fkey
FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
ON DELETE CASCADE ON UPDATE CASCADE;
select * from CreditScores;

UPDATE account
SET 
    totalamount = totalamount + 5000.00,
    status = 'Active'
WHERE account_number = 100000000001;
-- View all account updates
SELECT * FROM account_update_audit;
select * from account;

DELETE FROM Account WHERE account_number = 100000000001;


--SAVING_TRIGGER
CREATE TABLE savings_deletion_audit (
    saving_id_bef INTEGER NOT NULL,
    account_number_bef NUMERIC(14),
    customer_id_bef VARCHAR(30),
    amount_bef DECIMAL(15,2),
    saving_date_bef DATE,
    saving_type_bef saving_type,

    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--DELETION
CREATE OR REPLACE FUNCTION savings_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO savings_deletion_audit(
        saving_id_bef, account_number_bef, customer_id_bef,
        amount_bef, saving_date_bef, saving_type_bef,
        deleted_by, deleted_at
    )
    VALUES (
        OLD.saving_id, OLD.account_number, OLD.customer_id,
        OLD.amount, OLD.saving_date, OLD.saving_type,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER savings_delete_trigger
BEFORE DELETE ON savings
FOR EACH ROW
EXECUTE FUNCTION savings_delete_auditlog();

--UPDATION
CREATE TABLE savings_update_audit (
    saving_id_bef INTEGER,
    saving_id_aft INTEGER,
    account_number_bef NUMERIC(14),
    account_number_aft NUMERIC(14),
    customer_id_bef VARCHAR(30),
    customer_id_aft VARCHAR(30),
    amount_bef DECIMAL(15,2),
    amount_aft DECIMAL(15,2),
    saving_date_bef DATE,
    saving_date_aft DATE,
    saving_type_bef saving_type,
    saving_type_aft saving_type,
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION savings_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO savings_update_audit(
        saving_id_bef, saving_id_aft,
        account_number_bef, account_number_aft,
        customer_id_bef, customer_id_aft,
        amount_bef, amount_aft,
        saving_date_bef, saving_date_aft,
        saving_type_bef, saving_type_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.saving_id, NEW.saving_id,
        OLD.account_number, NEW.account_number,
        OLD.customer_id, NEW.customer_id,
        OLD.amount, NEW.amount,
        OLD.saving_date, NEW.saving_date,
        OLD.saving_type, NEW.saving_type,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER savings_update_trigger
AFTER UPDATE ON savings
FOR EACH ROW
EXECUTE FUNCTION savings_update_auditlog();


select * from savings;
UPDATE Savings
SET amount = 6000.00,
    saving_type = 'weekly'
WHERE saving_id = 1;
SELECT * FROM savings_update_audit;
DELETE FROM Savings
WHERE saving_id = 3;
SELECT * FROM savings_deletion_audit;



--BRANCH
--DELETION
CREATE TABLE branch_deletion_audit (
    branch_id_bef VARCHAR(30) NOT NULL,
    branch_name_bef VARCHAR(225),
    branch_address_bef VARCHAR(225),
    branch_phonenum_bef NUMERIC(15),
    account_number_bef NUMERIC(14),

    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION branch_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO branch_deletion_audit(
        branch_id_bef, branch_name_bef, branch_address_bef,
        branch_phonenum_bef, account_number_bef,
        deleted_by, deleted_at
    )
    VALUES (
        OLD.branch_id, OLD.branch_name, OLD.branch_address,
        OLD.branch_phonenum, OLD.account_number,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER branch_delete_trigger
BEFORE DELETE ON branch
FOR EACH ROW
EXECUTE FUNCTION branch_delete_auditlog();

SELECT * FROM branch_deletion_audit;

--UPDATION
CREATE TABLE branch_update_audit (
    branch_id_bef VARCHAR(30),
    branch_id_aft VARCHAR(30),
    branch_name_bef VARCHAR(225),
    branch_name_aft VARCHAR(225),
    branch_address_bef VARCHAR(225),
    branch_address_aft VARCHAR(225),
    branch_phonenum_bef NUMERIC(15),
    branch_phonenum_aft NUMERIC(15),
    account_number_bef NUMERIC(14),
    account_number_aft NUMERIC(14),
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION branch_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO branch_update_audit(
        branch_id_bef, branch_id_aft,
        branch_name_bef, branch_name_aft,
        branch_address_bef, branch_address_aft,
        branch_phonenum_bef, branch_phonenum_aft,
        account_number_bef, account_number_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.branch_id, NEW.branch_id,
        OLD.branch_name, NEW.branch_name,
        OLD.branch_address, NEW.branch_address,
        OLD.branch_phonenum, NEW.branch_phonenum,
        OLD.account_number, NEW.account_number,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER branch_update_trigger
AFTER UPDATE ON branch
FOR EACH ROW
EXECUTE FUNCTION branch_update_auditlog();

--EMPLOYEE
CREATE TABLE employee_deletion_audit (
    employee_id_bef VARCHAR(30) NOT NULL,
    branch_id_bef VARCHAR(30),
    ename_bef VARCHAR(225),
    eaddress_bef VARCHAR(225),
    ephonenumber_bef NUMERIC(15),
    eroll_bef VARCHAR(50),
    salary_bef NUMERIC(7,2),
    hiredate_bef DATE,
    leftdate_bef DATE,

    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE FUNCTION employee_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employee_deletion_audit(
        employee_id_bef, branch_id_bef, ename_bef, eaddress_bef,
        ephonenumber_bef, eroll_bef, salary_bef, hiredate_bef, leftdate_bef,
        deleted_by, deleted_at
    )
    VALUES (
        OLD.employee_id, OLD.branch_id, OLD.ename, OLD.eaddress,
        OLD.ephonenumber, OLD.eroll, OLD.salary, OLD.hiredate, OLD.leftdate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER employee_delete_trigger
BEFORE DELETE ON employee
FOR EACH ROW
EXECUTE FUNCTION employee_delete_auditlog();

--UPDATION
CREATE TABLE employee_update_audit (
    employee_id_bef VARCHAR(30),
    employee_id_aft VARCHAR(30),
    branch_id_bef VARCHAR(30),
    branch_id_aft VARCHAR(30),
    ename_bef VARCHAR(225),
    ename_aft VARCHAR(225),
    eaddress_bef VARCHAR(225),
    eaddress_aft VARCHAR(225),
    ephonenumber_bef NUMERIC(15),
    ephonenumber_aft NUMERIC(15),
    eroll_bef VARCHAR(50),
    eroll_aft VARCHAR(50),
    salary_bef NUMERIC(7,2),
    salary_aft NUMERIC(7,2),
    hiredate_bef DATE,
    hiredate_aft DATE,
    leftdate_bef DATE,
    leftdate_aft DATE,
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE FUNCTION employee_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employee_update_audit(
        employee_id_bef, employee_id_aft,
        branch_id_bef, branch_id_aft,
        ename_bef, ename_aft,
        eaddress_bef, eaddress_aft,
        ephonenumber_bef, ephonenumber_aft,
        eroll_bef, eroll_aft,
        salary_bef, salary_aft,
        hiredate_bef, hiredate_aft,
        leftdate_bef, leftdate_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.employee_id, NEW.employee_id,
        OLD.branch_id, NEW.branch_id,
        OLD.ename, NEW.ename,
        OLD.eaddress, NEW.eaddress,
        OLD.ephonenumber, NEW.ephonenumber,
        OLD.eroll, NEW.eroll,
        OLD.salary, NEW.salary,
        OLD.hiredate, NEW.hiredate,
        OLD.leftdate, NEW.leftdate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER employee_update_trigger
AFTER UPDATE ON employee
FOR EACH ROW
EXECUTE FUNCTION employee_update_auditlog();

SELECT * FROM employee_update_audit;


--LOAN
--DELETION
CREATE TABLE loan_deletion_audit (
    loanid_bef VARCHAR(30) NOT NULL,
    customerid_bef VARCHAR(30),
    account_number_bef NUMERIC(14),
    borrowerid_bef VARCHAR(30),
    loanamount_bef DECIMAL(15,2),
    interestrate_bef DECIMAL(5,2),
    loantype_bef VARCHAR(50),
    startdate_bef DATE,
    enddate_bef DATE,
    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION loan_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO loan_deletion_audit(
        loanid_bef, customerid_bef, account_number_bef, borrowerid_bef,
        loanamount_bef, interestrate_bef, loantype_bef, startdate_bef, enddate_bef,
        deleted_by, deleted_at
    )
    VALUES (
        OLD.loanid, OLD.customerid, OLD.account_number, OLD.borrowerid,
        OLD.loanamount, OLD.interestrate, OLD.loantype, OLD.startdate, OLD.enddate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER loan_delete_trigger
BEFORE DELETE ON loan
FOR EACH ROW
EXECUTE FUNCTION loan_delete_auditlog();

SELECT * FROM loan_deletion_audit;

--UPDATION
CREATE TABLE loan_update_audit (
    loanid_bef VARCHAR(30),
    loanid_aft VARCHAR(30),
    customerid_bef VARCHAR(30),
    customerid_aft VARCHAR(30),
    account_number_bef NUMERIC(14),
    account_number_aft NUMERIC(14),
    borrowerid_bef VARCHAR(30),
    borrowerid_aft VARCHAR(30),
    loanamount_bef DECIMAL(15,2),
    loanamount_aft DECIMAL(15,2),
    interestrate_bef DECIMAL(5,2),
    interestrate_aft DECIMAL(5,2),
    loantype_bef VARCHAR(50),
    loantype_aft VARCHAR(50),
    startdate_bef DATE,
    startdate_aft DATE,
    enddate_bef DATE,
    enddate_aft DATE,
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION loan_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO loan_update_audit(
        loanid_bef, loanid_aft,
        customerid_bef, customerid_aft,
        account_number_bef, account_number_aft,
        borrowerid_bef, borrowerid_aft,
        loanamount_bef, loanamount_aft,
        interestrate_bef, interestrate_aft,
        loantype_bef, loantype_aft,
        startdate_bef, startdate_aft,
        enddate_bef, enddate_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.loanid, NEW.loanid,
        OLD.customerid, NEW.customerid,
        OLD.account_number, NEW.account_number,
        OLD.borrowerid, NEW.borrowerid,
        OLD.loanamount, NEW.loanamount,
        OLD.interestrate, NEW.interestrate,
        OLD.loantype, NEW.loantype,
        OLD.startdate, NEW.startdate,
        OLD.enddate, NEW.enddate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER loan_update_trigger
AFTER UPDATE ON loan
FOR EACH ROW
EXECUTE FUNCTION loan_update_auditlog();

SELECT * FROM loan_update_audit;


--BORROWER
--DELETION
CREATE TABLE borrower_deletion_audit (
    borrowerid_bef VARCHAR(30) NOT NULL,
    full_name_bef VARCHAR(225) NOT NULL,
    father_name_bef VARCHAR(225) NOT NULL,
    mother_name_bef VARCHAR(225) NOT NULL,
    grandfather_name_bef VARCHAR(225) NOT NULL,
    address_bef VARCHAR(225) NOT NULL,
    date_of_birth_bef DATE,
    gender_bef gender NOT NULL,
    phone_number_bef NUMERIC(15) NOT NULL,
    email_bef VARCHAR(50),
    nationality_bef VARCHAR(50) NOT NULL,
    citizenship_number_bef NUMERIC(25),
    national_identity_number_bef NUMERIC(30),
    image_path_bef VARCHAR(255),
    loanamount_bef DECIMAL(15,2) NOT NULL,
    interestrate_bef DECIMAL(5,2) NOT NULL,
    loantype_bef VARCHAR(50),
    startdate_bef DATE NOT NULL,
    enddate_bef DATE,
    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE FUNCTION borrower_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO borrower_deletion_audit(
        borrowerid_bef, full_name_bef, father_name_bef, mother_name_bef, grandfather_name_bef,
        address_bef, date_of_birth_bef, gender_bef, phone_number_bef, email_bef,
        nationality_bef, citizenship_number_bef, national_identity_number_bef,
        image_path_bef, loanamount_bef, interestrate_bef, loantype_bef,
        startdate_bef, enddate_bef, deleted_by, deleted_at
    )
    VALUES (
        OLD.borrowerid, OLD.full_name, OLD.father_name, OLD.mother_name, OLD.grandfather_name,
        OLD.address, OLD.date_of_birth, OLD.gender, OLD.phone_number, OLD.email,
        OLD.nationality, OLD.citizenship_number, OLD.nationalidentitynumber,
        OLD.image_path, OLD.loanamount, OLD.interestrate, OLD.loantype,
        OLD.startdate, OLD.enddate, current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER borrower_delete_trigger
BEFORE DELETE ON borrower
FOR EACH ROW
EXECUTE FUNCTION borrower_delete_auditlog();

--UPDATION

CREATE TABLE borrower_update_audit (
    borrowerid_bef VARCHAR(30),
    borrowerid_aft VARCHAR(30),
    full_name_bef VARCHAR(225),
    full_name_aft VARCHAR(225),
    father_name_bef VARCHAR(225),
    father_name_aft VARCHAR(225),
    mother_name_bef VARCHAR(225),
    mother_name_aft VARCHAR(225),
    grandfather_name_bef VARCHAR(225),
    grandfather_name_aft VARCHAR(225),
    address_bef VARCHAR(225),
    address_aft VARCHAR(225),
    date_of_birth_bef DATE,
    date_of_birth_aft DATE,
    gender_bef gender,
    gender_aft gender,
    phone_number_bef NUMERIC(15),
    phone_number_aft NUMERIC(15),
    email_bef VARCHAR(50),
    email_aft VARCHAR(50),
    nationality_bef VARCHAR(50),
    nationality_aft VARCHAR(50),
    citizenship_number_bef NUMERIC(25),
    citizenship_number_aft NUMERIC(25),
    national_identity_number_bef NUMERIC(30),
    national_identity_number_aft NUMERIC(30),
    image_path_bef VARCHAR(255),
    image_path_aft VARCHAR(255),
    loanamount_bef DECIMAL(15,2),
    loanamount_aft DECIMAL(15,2),
    interestrate_bef DECIMAL(5,2),
    interestrate_aft DECIMAL(5,2),
    loantype_bef VARCHAR(50),
    loantype_aft VARCHAR(50),
    startdate_bef DATE,
    startdate_aft DATE,
    enddate_bef DATE,
    enddate_aft DATE,
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION borrower_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO borrower_update_audit(
        borrowerid_bef, borrowerid_aft,
        full_name_bef, full_name_aft,
        father_name_bef, father_name_aft,
        mother_name_bef, mother_name_aft,
        grandfather_name_bef, grandfather_name_aft,
        address_bef, address_aft,
        date_of_birth_bef, date_of_birth_aft,
        gender_bef, gender_aft,
        phone_number_bef, phone_number_aft,
        email_bef, email_aft,
        nationality_bef, nationality_aft,
        citizenship_number_bef, citizenship_number_aft,
        national_identity_number_bef, national_identity_number_aft,
        image_path_bef, image_path_aft,
        loanamount_bef, loanamount_aft,
        interestrate_bef, interestrate_aft,
        loantype_bef, loantype_aft,
        startdate_bef, startdate_aft,
        enddate_bef, enddate_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.borrowerid, NEW.borrowerid,
        OLD.full_name, NEW.full_name,
        OLD.father_name, NEW.father_name,
        OLD.mother_name, NEW.mother_name,
        OLD.grandfather_name, NEW.grandfather_name,
        OLD.address, NEW.address,
        OLD.date_of_birth, NEW.date_of_birth,
        OLD.gender, NEW.gender,
        OLD.phone_number, NEW.phone_number,
        OLD.email, NEW.email,
        OLD.nationality, NEW.nationality,
        OLD.citizenship_number, NEW.citizenship_number,
        OLD.nationalidentitynumber, NEW.nationalidentitynumber,
        OLD.image_path, NEW.image_path,
        OLD.loanamount, NEW.loanamount,
        OLD.interestrate, NEW.interestrate,
        OLD.loantype, NEW.loantype,
        OLD.startdate, NEW.startdate,
        OLD.enddate, NEW.enddate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER borrower_update_trigger
AFTER UPDATE ON borrower
FOR EACH ROW
EXECUTE FUNCTION borrower_update_auditlog();

SELECT *  FROM borrower_update_audit;

--CREDITSCORES
--DELETION
CREATE TABLE creditscores_deletion_audit (
    rateddate_bef DATE,
    customerid_bef VARCHAR(30),
    customerrate_bef credit_score,
    borrowerid_bef VARCHAR(30),
    borrowerrate_bef credit_score,
    employee_id_bef VARCHAR(30),
    employeerate_bef credit_score,
    deleted_by VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION creditscores_delete_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO creditscores_deletion_audit(
        rateddate_bef, customerid_bef, customerrate_bef, 
        borrowerid_bef, borrowerrate_bef, 
        employee_id_bef, employeerate_bef, 
        deleted_by, deleted_at
    )
    VALUES (
        OLD.rateddate, OLD.customerid, OLD.customerrate,
        OLD.borrowerid, OLD.borrowerrate,
        OLD.employee_id, OLD.employeerate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER creditscores_delete_trigger
BEFORE DELETE ON creditscores
FOR EACH ROW
EXECUTE FUNCTION creditscores_delete_auditlog();

--UPDATION
CREATE TABLE creditscores_update_audit (
    rateddate_bef DATE,
    rateddate_aft DATE,
    customerid_bef VARCHAR(30),
    customerid_aft VARCHAR(30),
    customerrate_bef credit_score,
    customerrate_aft credit_score,
    borrowerid_bef VARCHAR(30),
    borrowerid_aft VARCHAR(30),
    borrowerrate_bef credit_score,
    borrowerrate_aft credit_score,
    employee_id_bef VARCHAR(30),
    employee_id_aft VARCHAR(30),
    employeerate_bef credit_score,
    employeerate_aft credit_score,
    updated_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION creditscores_update_auditlog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO creditscores_update_audit(
        rateddate_bef, rateddate_aft,
        customerid_bef, customerid_aft,
        customerrate_bef, customerrate_aft,
        borrowerid_bef, borrowerid_aft,
        borrowerrate_bef, borrowerrate_aft,
        employee_id_bef, employee_id_aft,
        employeerate_bef, employeerate_aft,
        updated_by, updated_at
    )
    VALUES (
        OLD.rateddate, NEW.rateddate,
        OLD.customerid, NEW.customerid,
        OLD.customerrate, NEW.customerrate,
        OLD.borrowerid, NEW.borrowerid,
        OLD.borrowerrate, NEW.borrowerrate,
        OLD.employee_id, NEW.employee_id,
        OLD.employeerate, NEW.employeerate,
        current_setting('myapp.user', true),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER creditscores_update_trigger
AFTER UPDATE ON creditscores
FOR EACH ROW
EXECUTE FUNCTION creditscores_update_auditlog();

SELECT * FROM creditscores_update_audit;
