import psycopg2
import boto3
import io
from io import StringIO
import argparse
import datetime
import requests


# getting parameters
ssm = boto3.client('ssm')
access_key = ssm.get_parameter(Name='ucdb-access_key', WithDecryption=True)['Parameter']['Value']
secret_access_key = ssm.get_parameter(Name='ucdb-secret_access_key', WithDecryption=True)['Parameter']['Value']
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

# connecting to s3 service on aws
s3 = boto3.resource('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_access_key)
bucket = s3.Bucket('ucdb-stage')

cur = conn.cursor()
for obj in bucket.objects.filter(Prefix='clubelo/data'):
    key = obj.key
    # accessing data from S3 bucket
    data = obj.get()['Body'].read().decode('utf-8')
    print("Importing csv file: {} into database".format(key.split('/')[2]))
    
    # removing first row
    data = data[data.find('To')+3:]
    # changing data so read() method can be called on it
    data_readable = StringIO(data)
    cur.copy_from(data_readable, 'club_elo.club_elo_temp', sep=',')
    

conn.commit()
if conn is not None:
    cur.close()
    conn.close()
