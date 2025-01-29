import pyodbc
import csv
import os

def fetch_income_factors_for_neighborhoods():
    try:
        # Connection string for SQL Server
        # This assumes you're using Windows Authentication
        conn_str = (
            "DRIVER={SQL Server};"
            "SERVER=AsTxDBProd;"
            "DATABASE=GRM_Main;"
            "Trusted_Connection=yes;"
        )
        # If you need to use SQL Server Authentication, use this conn_str format instead:
        # conn_str = (
        #     "DRIVER={SQL Server};"
        #     "SERVER=AsTxDBProd;"
        #     "DATABASE=GRM_Main;"
        #     "UID=your_username;"
        #     "PWD=your_password;"
        # )

        # Connect to the SQL Server database
        conn = pyodbc.connect(conn_str)

        # Create a cursor object
        cursor = conn.cursor()

        # Define lists for neighborhoods, prop_types, and rent_classes
        neighborhoods = [1998, 1999, 2996, 2997, 2998, 2999, 3810, 3997, 3998, 3999, 4833, 4840, 4997, 4998, 4999]
        prop_types = [21, 22, 23]
        rent_classes = [1, 2, 3]

        # Define CSV file path
        output_dir = "C:\\Users\\kmallery\\Documents"
        csv_filename = "combined_results.csv"
        csv_filepath = os.path.join(output_dir, csv_filename)

        # Open CSV file for writing
        with open(csv_filepath, 'w', newline='', encoding='utf-8') as csvfile:
            csv_writer = csv.writer(csvfile)

            # Write header row to CSV file
            header_written = False

            # Loop through each neighborhood
            for neighborhood in neighborhoods:
                print(f"Fetching data for Neighborhood {neighborhood}:")

                # Loop through each prop_type and rent_class combination
                for prop_type in prop_types:
                    for rent_class in rent_classes:
                        # Define your SQL query with neighborhood, prop_type, and rent_class as parameters
                        sql_query = f"""
                            SELECT msn as Model_number, 
                                table_type, 
                                year_group, 
                                neighborhood,
                                    CASE prop_type
                                        WHEN 21 THEN 'Duplex'
                                        WHEN 22 THEN 'TRIPLEX'
                                        WHEN 23 THEN 'FOURPLEX'
                                    END AS BUILDING_CLASS,
                                df1 AS '1/1',
                                df2 AS '2/1',
                                df3 AS '2/1.5+',
                                df4 AS '3/1',
                                df5 AS '3/1.5+',
                                df6 AS '3/2',
                                df7 AS '4/2'
                            FROM dbo.income_factors
                            WHERE table_type LIKE 'GIM' 
                                AND version_num = 4 
                                AND msn = 300024 
                                AND neighborhood = '{neighborhood}'
                                AND prop_type = {prop_type}
                                AND rent_class = {rent_class}
                        """

                        # Execute the SQL query
                        cursor.execute(sql_query)

                        # Fetch all rows from the result set
                        rows = cursor.fetchall()

                        # Write data rows to CSV file
                        if not header_written:
                            csv_writer.writerow([i[0] for i in cursor.description])
                            header_written = True
                        
                        csv_writer.writerows(rows)

            print(f"Combined results CSV file saved: {csv_filepath}")

    except pyodbc.Error as e:
        print(f"An error occurred: {e}")

    finally:
        # Close the cursor and connection
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    fetch_income_factors_for_neighborhoods()
