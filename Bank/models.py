from django.db import models


# Create your models here.

class RegisterCustomer(models.Model):
    full_name = models.CharField(max_length=200)
    email = models.EmailField(unique=True, null=True, blank=True)
    phone = models.CharField(max_length=20, unique=True)
    password = models.CharField(max_length=128)  # hashed password

    def __str__(self):
        return self.full_name

class RegisterEmployee(models.Model):
    full_name = models.CharField(max_length=100)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=20, unique=True)
    password = models.CharField(max_length=255)
    role = models.CharField(max_length=50, default="Employee")