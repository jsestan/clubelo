import psycopg2
import os
import boto3


# getting parameters
ssm = boto3.client('ssm')
db_host = ssm.get_parameter(Name='ucdb-postgres-host', WithDecryption=True)['Parameter']['Value']
db_port = ssm.get_parameter(Name='ucdb-postgres-port', WithDecryption=True)['Parameter']['Value']
db_user = ssm.get_parameter(Name='ucdb-postgres-user', WithDecryption=True)['Parameter']['Value']
db_password = ssm.get_parameter(Name='ucdb-postgres-password', WithDecryption=True)['Parameter']['Value']

# create connection to database
conn = psycopg2.connect(
    host=db_host,
    database="postgres",
    port=db_port,
    user=db_user,
    password=db_password)

sql_scripts = []
sql_scripts_names = []
cur = conn.cursor()

for filename in os.listdir("sql_scripts"):
    sql_scripts_names.append(filename)

    with open(os.path.join("sql_scripts", filename), 'r') as f:
        temp = f.read()
        sql_scripts.append(temp)

for i, script in enumerate(sql_scripts):
    try:
        print("Running... {}".format(sql_scripts_names[i]))
        cur.execute(script)
        
    except (Exception, psycopg2.DatabaseError) as error:
        print("Error at script: {} ".format(sql_scripts_names[i]))
        print(error)

conn.commit()
if conn is not None:
    conn.close()
    cur.close()