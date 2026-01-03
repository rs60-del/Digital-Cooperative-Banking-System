from django.contrib import admin

# Register your models here.
from .models import RegisterCustomer, RegisterEmployee
admin.site.register(RegisterCustomer)
admin.site.register(RegisterEmployee)