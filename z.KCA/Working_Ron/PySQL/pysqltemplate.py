import pyodbc  # You need to install this module: pip install pyodbc


def execute_sql_file(sql_file_path):
    try:
        # Connection string for SQL Server
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
        
        # Read the SQL file
        with open(sql_file_path, 'r') as sql_file:
            sql_script = sql_file.read()
        
        # Execute the SQL script
        for statement in sql_script.split(';'):
            if statement.strip():
                cursor.execute(statement)
        
        # Commit the transaction
        conn.commit()
        
        print("SQL script executed successfully")
        
    except pyodbc.Error as e:
        print(f"An error occurred: {e}")
        
    finally:
        # Close the cursor and connection
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    sql_file_path = "path/to/your/sql_script.sql"
    execute_sql_file(sql_file_path)