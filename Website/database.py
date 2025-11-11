# database.py
import pyodbc

def get_db_connection():
    try:
        connection_string = (
            "Driver={ODBC Driver 17 for SQL Server};"
            "Server=DESKTOP-BH2IKQU\\SQLEXPRESS;"
            "Database=ITI_System;"
            "Trusted_Connection=yes;"
        )
        connection = pyodbc.connect(connection_string)
        return connection
    except Exception as e:
        print(f"Database connection failed: {e}")
        return None

def test_connection():
    conn = get_db_connection()
    if conn:
        print(" Database connection successful!")
        conn.close()
        return True
    else:
        print(" Database connection failed!")
        return False

if __name__ == "__main__":
    test_connection()