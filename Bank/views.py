from django.db import connection
from django.core.files.storage import FileSystemStorage
from django.shortcuts import render, redirect
from django.http import HttpResponse
from datetime import date
from django.contrib import messages
from django.contrib.auth.hashers import make_password, check_password
from .models import RegisterCustomer, RegisterEmployee


# Create your views here.

#i have done here customer/employee registration and login 

def register_customer(request):
     # Clear old messages so only fresh ones appear
    list(messages.get_messages(request))

    if request.method == "POST":
        full_name = request.POST.get("full_name")
        email = request.POST.get("email") or None
        phone = request.POST.get("phone")
        password = request.POST.get("password")
        user_type = request.POST.get("user_type")

        hashed_password = make_password(password)

        if user_type == "customer":
            if RegisterCustomer.objects.filter(phone=phone).exists():
                messages.error(request, "Phone already used!", extra_tags="register")
                return redirect("login")
            RegisterCustomer.objects.create(
                full_name=full_name,
                email=email,
                phone=phone,
                password=hashed_password
            )
            messages.success(request, "Customer registered successfully!", extra_tags="register")
        
        elif user_type == "employee":
            if RegisterEmployee.objects.filter(phone=phone).exists():
                messages.error(request, "Phone already used!", extra_tags="register")
                return redirect("login")
            RegisterEmployee.objects.create(
                full_name=full_name,
                email=email,
                phone=phone,
                password=hashed_password
            )
            messages.success(request, "Employee registered successfully!", extra_tags="register")

        return redirect("login")

    return render(request, "Bank/auth.html")

    
def login_customer(request):
     # Clear old messages so only fresh ones appear
    list(messages.get_messages(request))
    if request.method == "POST":
        login_id = request.POST.get("login_id")  # email or phone
        password = request.POST.get("password")
        user_type = request.POST.get("user_type")

        # check by email OR phone
        user = None

        if user_type == "customer":
            if RegisterCustomer.objects.filter(phone=login_id).exists():
                user = RegisterCustomer.objects.get(phone=login_id)
            elif RegisterCustomer.objects.filter(email=login_id).exists():
                user = RegisterCustomer.objects.get(email=login_id)
            else:
                messages.error(request, "Customer not found!", extra_tags="login")
                return redirect("login")

        elif user_type == "employee":
            if RegisterEmployee.objects.filter(phone=login_id).exists():
                user = RegisterEmployee.objects.get(phone=login_id)
            elif RegisterEmployee.objects.filter(email=login_id).exists():
                user = RegisterEmployee.objects.get(email=login_id)
            else:
                messages.error(request, "Employee not found!", extra_tags="login")
                return redirect("login")

        # password verification
        if not check_password(password, user.password):
            messages.error(request, "Incorrect password!", extra_tags="login")
            return redirect("login")

        # Store correct session keys
        if user_type == "customer":
            request.session["customer_id"] = user.id
            request.session["customer_name"] = user.full_name
            return redirect("customer_dashboard")

        else:
            request.session["employee_id"] = user.id
            request.session["employee_name"] = user.full_name
            return redirect("employee_dashboard")

    return render(request, "Bank/auth.html")



def logout_customer(request):
    request.session.flush()
    return redirect("login")

def customer_dashboard(request):
    if "customer_id" not in request.session:
        return redirect("login")

    name = request.session.get("customer_name")

    return render(request, "Bank/dashboard.html", {"name": name})

def employee_dashboard(request):
    if "employee_id" not in request.session:
        return redirect("login")

    name = request.session.get("employee_name")

    return render(request, "Bank/employeedashbord.html", {"name": name})




#CUSTOMER DETAIL
def show_customer_details(request):
     with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM customer")
        rows = cursor.fetchall()
        return render(request, 'Bank/customer_list.html', {'rows': rows})

def add_customer(request):
    if request.method == "POST":
        cid = request.POST['Customer_ID']
        name = request.POST['Full_name']
        address = request.POST['Address']
        dob = request.POST['Date_of_Birth']
        gender = request.POST['Gender']
        phone = request.POST['Phone_number']
        email = request.POST['Email']
        nationality = request.POST['Nationality']
        citizenship = request.POST['Citizenship_number']
        image = request.POST['image_path']

        with connection.cursor() as cursor:
            cursor.execute("""
             INSERT INTO customer 
             (Customer_ID, Full_name, Address, Date_of_Birth, Gender, Phone_number,
             Email, Nationality, Citizenship_number, image_path)
             VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, [cid, name, address, dob, gender, phone, email, nationality, citizenship, image])
        return HttpResponse('Customer added!')

    return render(request, 'Bank/add_customer.html')

def update_customer(request, cid):
    if request.method == "POST":
        name = request.POST['Full_name']
        email = request.POST['Email']

        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE customer
                SET Full_name = %s, Email = %s         
                WHERE Customer_ID = %s
            """, [name, email, str(cid)])

        return HttpResponse("Customer updated!")
 
    return render(request, "Bank/update_customer.html")


def delete_customer(request, cid):
    if request.method == "POST":
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM customer WHERE Customer_ID = %s", [str(cid)])
        return HttpResponse("Customer deleted!")

    return render(request, "Bank/delete_customer.html")


#Account 
def show_Account_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM Account")
        rows = cursor.fetchall()
        return render(request, 'Bank/account_list.html', {'rows': rows})
     

def add_account(request):
    # Load customers to populate dropdown (optional)
    customers = []
    with connection.cursor() as cursor:
        cursor.execute("SELECT Customer_ID FROM customer ORDER BY Full_name;")
        customers = cursor.fetchall()  # list of tuples (Customer_ID, Full_name)

    if request.method == "POST":
        acc_no = request.POST.get("Account_Number").strip()
        acc_type = request.POST.get("Account_type")
        cust_id = request.POST.get("Customer_ID")
        opening_date = request.POST.get("Opening_date") or None   # string 'YYYY-MM-DD' or None
        status = request.POST.get("status")
        total = request.POST.get("totalAmount") or "0"

        # convert numeric fields safely
        try:
            total_amount = float(total)
        except Exception:
            return HttpResponse("Invalid totalAmount value", status=400)

        # Insert into DB (use parameterized query to avoid SQL injection)
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO Account
                (Account_Number, Account_type, Customer_ID, Opening_date, status, totalAmount)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, [acc_no, acc_type, cust_id, opening_date, status, total_amount])

        return HttpResponse("Account created successfully!")

    # pass today's date to prefill input if you like (format YYYY-MM-DD)
    context = {
        "customers": customers,
        "today": date.today().isoformat()
    }
    return render(request, "Bank/add_account.html", context)


# saving details;
def show_saving_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM SAVINGS")
        rows = cursor.fetchall()
        return render(request, 'Bank/saving_list.html', {'rows': rows})

def add_saving(request):
    # Load accounts & customers for dropdown
    with connection.cursor() as cursor:
        cursor.execute("SELECT Account_Number FROM Account ORDER BY Account_Number;")
        accounts = cursor.fetchall()

        cursor.execute("SELECT Customer_ID, Full_name FROM customer ORDER BY Full_name;")
        customers = cursor.fetchall()

    if request.method == "POST":
        acc_no = request.POST.get("Account_Number")
        cust_id = request.POST.get("Customer_ID")
        amount = request.POST.get("Amount")
        saving_date = request.POST.get("Saving_Date") or None
        saving_type = request.POST.get("Saving_Type")

        with connection.cursor() as cursor:
            # (1) Insert into Savings table
            cursor.execute("""
                INSERT INTO Savings (Account_Number, Customer_ID, Amount, Saving_Date, Saving_Type)
                VALUES (%s, %s, %s, %s, %s)
            """, [acc_no, cust_id, amount, saving_date, saving_type])

            # (2) Update Account totalAmount = previous + new amount
            cursor.execute("""
                UPDATE Account
                SET totalAmount = COALESCE(totalAmount, 0) + %s
                WHERE Account_Number = %s
            """, [amount, acc_no])

        return HttpResponse("Saving entry added successfully!")
    

    context = {
        "accounts": accounts,
        "customers": customers,
        "today": date.today().isoformat()
    }
    return render(request, "Bank/add_saving.html", context)


#BRANCH 
def show_branch_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM BRANCH")
        rows = cursor.fetchall()
        return render(request, 'Bank/branch_list.html', {'rows': rows})

def add_branch(request):
     # Load accounts dropdown
    with connection.cursor() as cursor:
        cursor.execute("SELECT Account_Number FROM Account ORDER BY Account_Number;")
        accounts = cursor.fetchall()

    if request.method == "POST":
        bid = request.POST.get['Branch_ID']
        name = request.POST.get['Branch_name']
        address = request.POST.get['Branch_address']
        phone = request.POST.get['Branch_phonenum']
        select_account = request.POST.get['Account_number']

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO branch(Branch_ID, Branch_name, Branch_address, Branch_phonenum, Account_number)
                VALUES (%s, %s, %s, %s, %s)
            """, [bid, name, address, phone, select_account])

        return redirect('add_branch')
    context = {
        "accounts": accounts
    }

    return render(request, 'Bank/add_branch.html', context)


#TRANSACTION 
def add_transaction(request):
     # Load accounts & customers for dropdown
    with connection.cursor() as cursor:
        cursor.execute("SELECT Customer_ID FROM customer;")
        customers = cursor.fetchall()
    
        cursor.execute("SELECT Account_Number FROM Account ORDER BY Account_Number;")
        accounts = cursor.fetchall()


    if request.method == "POST":
        tid = request.POST.get['Transaction_ID']
        cid = request.POST.get['Customer_id']
        acc = request.POST.get['Account_number']
        ttype = request.POST.get['Transactiontype']
        amount = request.POST.get['Amount']
        tdate = request.POST.get['TransactionDate']
        ttime = request.POST.get['TransactionTime']
        desc = request.POST.get['Description']

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO transactions(Transaction_ID, Customer_id, Account_number, Transactiontype, Amount, TransactionDate, TransactionTime, Description)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, [tid, cid, acc, ttype, amount, tdate, ttime, desc])

        return redirect('add_transaction')
    
    context = {
        "accounts": accounts,
        "customers": customers,
        "today": date.today().isoformat()
    }


    return render(request, 'Bank/add_transaction.html', context)

# EMPLOYEE 
def show_employee_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM EMPLOYEE")
        rows = cursor.fetchall()
        return render(request, 'Bank/employee_list.html', {'rows': rows})


def add_employee(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT Branch_ID FROM branch ORDER BY Branch_ID;")
        branches = cursor.fetchall()


    if request.method == "POST":
        eid = request.POST.get['Employee_ID']
        bid = request.POST.get['Branch_ID']
        name = request.POST.get['Ename']
        address = request.POST.get['Eaddress']
        phone = request.POST.get['Ephonenumber']
        roll = request.POST.get['Eroll']
        salary = request.POST.get['salary']
        hire = request.POST.get['Hiredate']
        leftdate = request.POST.get['Leftdate']

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO employee(Employee_ID, Branch_ID, Ename, Eaddress, Ephonenumber, Eroll, salary, Hiredate, Leftdate)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, [eid, bid, name, address, phone, roll, salary, hire, leftdate])

        return redirect('add_employee')
    context = {
        "branches": branches
    }

    return render(request, 'Bank/add_employee.html', context)


# LOAN
def show_loan_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM LOAN")
        rows = cursor.fetchall()
        return render(request, 'Bank/loan_list.html', {'rows': rows})

def add_loan(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT Customer_ID FROM customer ORDER BY Customer_ID;")
        customers = cursor.fetchall()

        
        cursor.execute("SELECT Account_Number FROM Account ORDER BY Account_Number;")
        accounts = cursor.fetchall()

        cursor.execute("SELECT BorrowerID FROM Borrower ORDER BY BorrowerID;")
        borrowers = cursor.fetchall()


    if request.method == "POST":
        lid = request.POST.get("LoanID")
        amount = request.POST.get("LoanAmount")
        rate = request.POST.get("InterestRate")
        ltype = request.POST.get("LoanType")
        sdate = request.POST.get("StartDate")
        edate = request.POST.get("EndDate")
        loan_by = request.POST.get("loan_taken_by")

        # If loan taken by customer
        if loan_by == "customer":
            customer_id = request.POST.get("CustomerID")
            acc_number = request.POST.get("Account_Number")
            borrower_id = None

        # If loan taken by external borrower
        else:
            borrower_id = request.POST.get("BorrowerID")
            acc_number = None
            customer_id = None

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO loan
                (LoanID, CustomerID, Account_Number, BorrowerID, LoanAmount, 
                 InterestRate, LoanType, StartDate, EndDate)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, [
                lid, customer_id, acc_number, borrower_id, amount,
                rate, ltype, sdate, edate
            ])

        return HttpResponse("Loan added successfully!")

    context = {
        "accounts": accounts,
        "customers": customers,
        "borrowers": borrowers,
        "today": date.today().isoformat()
    }

    return render(request, 'Bank/add_loan.html',context)


#BORROWER
def show_borrower_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM BORROWER")
        rows = cursor.fetchall()
        return render(request, 'Bank/borrower_list.html', {'rows': rows})



def add_borrower(request):
    if request.method == "POST":

        # SAFE FILE UPLOAD 
        image_file = request.FILES.get("image_path")   # safe method, no error
        
        image_path = None
        if image_file:
            fs = FileSystemStorage()
            image_path = fs.save(image_file.name, image_file)

        # COLLECT ALL FORM FIELDS
        def clean_date(value):
            return value if value else None     # convert "" → None
        
        data = {
            'BorrowerID': request.POST.get('BorrowerID'),
            'Full_name': request.POST.get('Full_name'),
            'Father_name': request.POST.get('Father_name'),
            'Mother_name': request.POST.get('Mother_name'),
            'GrandFather_name': request.POST.get('GrandFather_name'),
            'Address': request.POST.get('Address'),
            'Date_of_Birth': request.POST.get('Date_of_Birth'),
            'Gender': request.POST.get('Gender'),
            'Phone_number': request.POST.get('Phone_number'),
            'Email': request.POST.get('Email'),
            'Nationality': request.POST.get('Nationality'),
            'Citizenship_number': request.POST.get('Citizenship_number'),
            'NationalIdentityNumber': request.POST.get('NationalIdentityNumber'),
            'image_path': image_path,   # saved file path or None
            'LoanAmount': request.POST.get('LoanAmount'),
            'InterestRate': request.POST.get('InterestRate'),
            'LoanType': request.POST.get('LoanType'),
            'StartDate': clean_date(request.POST.get('StartDate')),
            'EndDate': clean_date(request.POST.get('EndDate')), 
        }

        #DATABASE INSERT
        with connection.cursor() as cursor:
            cursor.execute(f"""
                INSERT INTO borrower (
                    BorrowerID, Full_name, Father_name, Mother_name, GrandFather_name,
                    Address, Date_of_Birth, Gender, Phone_number, Email, Nationality,
                    Citizenship_number, NationalIdentityNumber, image_path, LoanAmount,
                    InterestRate, LoanType, StartDate, EndDate
                )
                VALUES ({','.join(['%s'] * len(data))})
            """, list(data.values()))

        return redirect('add_borrower')

    return render(request, 'Bank/add_borrower.html')


# CREDIT SCORE 

def show_creditScore_details(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM CreditScores")
        rows = cursor.fetchall()
        return render(request, 'Bank/creditscore_list.html', {'rows': rows})


def add_credit_score(request):

    # Load dropdown data
    with connection.cursor() as cursor:
        cursor.execute("SELECT Customer_ID FROM customer ORDER BY Customer_ID;")
        customers = cursor.fetchall()

        cursor.execute("SELECT BorrowerID FROM Borrower ORDER BY BorrowerID;")
        borrowers = cursor.fetchall()

        cursor.execute("SELECT Employee_ID FROM employee ORDER BY Employee_ID;")
        employees = cursor.fetchall()

    if request.method == "POST":
        rating_for = request.POST.get("rating_for")   # customer / borrower / employee
        
        # Default NULL values
        cid = None
        crate = None
        bid = None
        brate = None
        eid = None
        erate = None

        # Apply selected rating logic
        if rating_for == "customer":
            cid = request.POST.get("CustomerID")
            crate = request.POST.get("customerRate")

        elif rating_for == "borrower":
            bid = request.POST.get("BorrowerID")
            brate = request.POST.get("BorrowerRate")

        elif rating_for == "employee":
            eid = request.POST.get("Employee_ID")
            erate = request.POST.get("EmployeeRate")

        # Insert into DB
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO creditscores(CustomerID, customerRate, BorrowerID, BorrowerRate, Employee_ID, EmployeeRate)
                VALUES (%s,%s,%s,%s,%s,%s)
            """, [cid, crate, bid, brate, eid, erate])

        return HttpResponse("Credit score updated!")

    context = {
        "customers": customers,
        "borrowers": borrowers,
        "employees": employees,
    }
    return render(request, 'Bank/add_credit_score.html', context)
