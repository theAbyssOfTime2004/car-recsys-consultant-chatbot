#!/usr/bin/env python3
import psycopg2
import sys

try:
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        database="car_recsys",
        user="admin",
        password="admin123"
    )
    
    cur = conn.cursor()
    
    # Get column names
    cur.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_schema = 'raw' AND table_name = 'used_vehicles'
        ORDER BY ordinal_position;
    """)
    
    print("=== Column names in raw.used_vehicles ===")
    columns = []
    for row in cur.fetchall():
        print(f"{row[0]:30} {row[1]}")
        columns.append(row[0])
    
    print(f"\nTotal columns: {len(columns)}")
    
    # Get sample data
    if columns:
        col_list = ', '.join([f'"{col}"' for col in columns[:10]])
        cur.execute(f'SELECT {col_list} FROM raw.used_vehicles LIMIT 1;')
        print("\n=== Sample row (first 10 columns) ===")
        row = cur.fetchone()
        if row:
            for i, val in enumerate(row):
                print(f"{columns[i]:30} = {str(val)[:50]}")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
