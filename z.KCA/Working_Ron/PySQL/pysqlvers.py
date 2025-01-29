import pyodbc  # You need to install this module: pip install pyodbc

def get_mssql_version():
    try:
        # Connection string for SQL Server
        # This conn_str assumes you're using Windows Authentication
        conn_str = (
            "DRIVER={SQL Server};"
            "SERVER=AsTxDBProd;"
            "DATABASE=GRM_Main;"
            "Trusted_Connection=yes;"
        )
        # This conn_str assumes you're using SQL Server Authentication
        # conn_str = (
            # "DRIVER={SQL Server};"
            # "SERVER=AsTxDBProd;"
            # "DATABASE=GRM_Main;"
            # "UID=your_username;"
            # "PWD=your_password;"
        # )
        
        # Connect to the SQL Server database
        conn = pyodbc.connect(conn_str)
        
        # Create a cursor object
        cursor = conn.cursor()
        
        # Execute SQL to get the SQL Server version
        cursor.execute("SELECT @@VERSION;")
        
        # Fetch the result
        version = cursor.fetchone()
        
        # Print the version
        print(f"MSSQL Database Version: {version[0]}")
        
    except pyodbc.Error as e:
        print(f"An error occurred: {e}")
        
    finally:
        # Close the cursor and connection
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    get_mssql_version()