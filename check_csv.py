import csv

with open('MONTHLY_STATS.csv', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    count = line.count(',')
    if count != 5:
        print(f"Line {i+1} has {count} commas: {line.strip()}")
        if i > 10:
            break
