# config.py
import os

class Config:
    # Secret key for session management - change this to a random string!
    SECRET_KEY = 'iti-exam-system-secret-key-2024'
    
    # Database configuration
    DATABASE_CONFIG = {
        'server': 'DESKTOP-BH2IKQU\\SQLEXPRESS',
        'database': 'ITI_System', 
        'driver': 'ODBC Driver 17 for SQL Server',
        'trusted_connection': 'yes'
    }