import requests

# Replace with your WAF public IP
WAF_IP = "xx.xxx.xxx.xx"
TARGET_URL = f"http://{WAF_IP}/vulnerabilities/sqli/"

# List of attack payloads (common SQL Injection payloads)
payloads = [
    "'",
    "''",
    "`",
    "``",
    ",",
    "\"",
    "\"\"",
    "//",
    "\\",
    "\\\\",
    ";",
    "' or \"",
    "-- or #",
    "' OR '1",
    "' OR 1 -- -",
    "\" OR \"\" = \"",
    "\" OR 1 = 1 -- -",
    "' OR '' = '",
    
    "'='",
    "'LIKE'",
    "'=0--+",
    " OR 1=1",
    "' OR 'x'='x",
    "' AND id IS NULL; --",
    "'''''''''''''UNION SELECT '2",
    "%00",
    "/*…*/",
    "+",
    "||",
    "%",
    "@variable",
    "@@variable",
    "# Numeric",
    "AND 1",
    "AND 0",
    "AND true",
    "AND false",
    "1-false",
    "1-true",
    "1*56",
    "-2",
    "1' ORDER BY 1--+",
    "1' ORDER BY 2--+",
    "1' ORDER BY 3--+",
    "1' ORDER BY 1,2--+",
    "1' ORDER BY 1,2,3--+",
    "1' GROUP BY 1,2,--+",
    "1' GROUP BY 1,2,3--+",
    "' GROUP BY columnnames having 1=1 --",
    "-1' UNION SELECT 1,2,3--+",
    "' UNION SELECT sum(columnname ) from tablename --",
    "-1 UNION SELECT 1 INTO @,@",
    "-1 UNION SELECT 1 INTO @,@,@",
    "1 AND (SELECT * FROM Users) = 1",
    "' AND MID(VERSION(),1,1) = '5';",
    "' and 1 in (select min(name) from sysobjects where xtype = 'U' and name > '.') --",
    "Finding the table name",
    "Time-Based:",
    ",(select * from (select(sleep(10)))a)",
    "%2c(select%20*%20from%20(select(sleep(10)))a)",
    "';WAITFOR DELAY '0:0:30'--",
    "Comments:#",
    "/*",
    "-- -",
    ";%00",
    "`"
]

print(f"Starting Pentest against WAF: {WAF_IP}\n")

blocked_count = 0

for i, payload in enumerate(payloads, 1):
    print(f"Attempting attack #{i}: {payload}")
    
    try:
        # Send the payload as a GET parameter
        params = {'id': payload, 'Submit': 'Submit'}
        response = requests.get(TARGET_URL, params=params, timeout=5)
        
        if response.status_code == 403:
            print("BLOCKED (403 Forbidden)")
            blocked_count += 1
        else:
            print(f"ALLOWED (Status: {response.status_code})")
            
    except Exception as e:
        print(f"Connection error: {e}")

print(f"\n--- Summary ---")
print(f"Blocked attacks: {blocked_count}/{len(payloads)}")
