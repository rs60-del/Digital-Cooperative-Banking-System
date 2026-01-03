
from django.urls import path
from . import views

urlpatterns = [
    
    path("register/", views.register_customer, name="register"),
    path("login/", views.login_customer, name="login"),
    path("logout/", views.logout_customer, name="logout"),
    path("dashboard/", views.customer_dashboard, name="customer_dashboard"),
    path("employeedashboard/", views.employee_dashboard, name="employee_dashboard"),

    #CUSTOMER
   path('show_customer_details/',views.show_customer_details, name='show_customer_details'),
   path('add_customer/', views.add_customer, name='add_customer'),
   path('update_customer/<str:cid>/', views.update_customer, name='update_customer'),
   path('delete_customer/<str:cid>/', views.delete_customer, name='delete_customer'),

   #ACCOUNT
   path('show_Account_details/',views.show_Account_details, name='show_Account_details'),
   path('add_account/', views.add_account, name='add_account'),

   #SAVING
   path('show_saving_details/', views.show_saving_details, name='show_saving_details'),
   path('add_saving/', views.add_saving, name='add_saving'),
  
   # BRANCH
   path('show_branch_details/', views.show_branch_details, name='show_branch_details'),
    path('add_branch/', views.add_branch, name='add_branch'),

    # TRANSACTIONS
    path('add_transaction/', views.add_transaction, name='add_transaction'),

    # EMPLOYEE
    path('show_employee_details/', views.show_employee_details, name='show_employee_details'),
    path('add_employee/', views.add_employee, name='add_employee'),

    # LOAN
    path('show_loan_details/', views.show_loan_details, name='show_loan_details'),
    path('add_loan/', views.add_loan, name='add_loan'),

    # BORROWER
    path('show_borrower_details/', views.show_borrower_details, name='show_borrower_details'),
    path('add_borrower/', views.add_borrower, name='add_borrower'),

    # CREDIT SCORE
    path('show_creditScore_details/', views.show_creditScore_details, name='show_creditScore_details'),
    path('add_credit_score/', views.add_credit_score, name='add_credit_score'),


  
]