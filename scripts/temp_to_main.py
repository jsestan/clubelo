import psycopg2
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

cur = conn.cursor()

sql = """
INSERT INTO club_elo.club_elo
WITH imported_dates as (
	SELECT distinct rank_date
	FROM club_elo.club_elo
)
SELECT *
FROM club_elo.club_elo_temp
WHERE rank_date not in (SELECT DISTINCT rank_date FROM imported_dates);

TRUNCATE TABLE club_elo.club_elo_temp;"""

try:
    cur.execute(sql)
    
except (Exception, psycopg2.DatabaseError) as error:
    print("Error at stat: {} ".format(stat))
    print(error)

conn.commit()
if conn is not None:
    cur.close()
    conn.close()

