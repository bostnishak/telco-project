import csv

def generate_sql():
    with open('02_SEED_DATA.sql', 'w', encoding='utf-8') as out:
        out.write("SET DEFINE OFF;\n")
        out.write("ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';\n")
        out.write("ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';\n\n")

        # TARIFFS
        out.write("-- TARIFFS INSERTIONS\n")
        with open('TARIFFS.csv', 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader)  # Skip header
            for row in reader:
                if not row:
                    continue
                out.write(f"INSERT INTO TARIFFS (TARIFF_ID, NAME, MONTHLY_FEE, DATA_LIMIT, MINUTE_LIMIT, SMS_LIMIT) "
                          f"VALUES ({row[0]}, '{row[1]}', {row[2]}, {row[3]}, {row[4]}, {row[5]});\n")
        
        # CUSTOMERS
        out.write("\n-- CUSTOMERS INSERTIONS\n")
        with open('CUSTOMERS.csv', 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader)  # Skip header
            for row in reader:
                if not row:
                    continue
                name = row[1].replace("'", "''")
                city = row[2].replace("'", "''")
                date_val = row[3]
                tariff_id = row[4]
                out.write(f"INSERT INTO CUSTOMERS (CUSTOMER_ID, NAME, CITY, SIGNUP_DATE, TARIFF_ID) "
                          f"VALUES ({row[0]}, '{name}', '{city}', TO_DATE('{date_val}', 'DD/MM/YYYY'), {tariff_id});\n")

        # MONTHLY STATS
        out.write("\n-- MONTHLY_STATS INSERTIONS\n")
        with open('MONTHLY_STATS.csv', 'r', encoding='utf-8') as f:
            lines = f.readlines()
            # skip header
            for i in range(1, len(lines)):
                line = lines[i].strip()
                if not line:
                    continue
                parts = line.split(',')
                # If length is 7, the DATA_USAGE had a comma that split into parts[2] and parts[3]
                if len(parts) == 6:
                    stat_id, cust_id, data, minute, sms, status = parts
                elif len(parts) == 7:
                    stat_id, cust_id = parts[0], parts[1]
                    data = f"{parts[2]}.{parts[3]}"
                    minute, sms, status = parts[4], parts[5], parts[6]
                else:
                    continue
                
                out.write(f"INSERT INTO MONTHLY_STATS (STAT_ID, CUSTOMER_ID, DATA_USAGE, MINUTE_USAGE, SMS_USAGE, PAYMENT_STATUS) "
                          f"VALUES ({stat_id}, {cust_id}, {data}, {minute}, {sms}, '{status}');\n")
        
        out.write("\nCOMMIT;\n")

if __name__ == "__main__":
    print("Generating 02_SEED_DATA.sql...")
    generate_sql()
    print("Done!")
