import argparse
from datetime import datetime, date
from time import sleep
import requests
from requests import RequestException
import boto3


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('scraper_type', type=str)
    args = parser.parse_args()
    return args.scraper_type


def handle_request(target_date):
    # getting parameters
    ssm = boto3.client('ssm')
    access_key = ssm.get_parameter(Name='ucdb-access_key', WithDecryption=True)['Parameter']['Value']
    secret_access_key = ssm.get_parameter(Name='ucdb-secret_access_key', WithDecryption=True)['Parameter']['Value']

    # connecting to s3 service on aws
    s3 = boto3.client('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_access_key)

    max_retries = 5
    retry_number = 0
    date_str = target_date.strftime('%Y-%m-%d')
    print(f'Handling request http://api.clubelo.com/{date_str}...')
    while retry_number < max_retries:
        try:
            r = requests.get(f'http://api.clubelo.com/{date_str}')
            break
        except RequestException:
            sleep(30)
            retry_number += 1

    if retry_number < max_retries and r.status_code == 200:
        elo_list = r.text.split('\n')
        result_list = []
        rank = 0
        for row in elo_list:
            if row == "":
                continue
            # add scraping date label to first row
            elif row == "Rank,Club,Country,Level,Elo,From,To":
                new_row = "DateScraped," + row
            # assign rank to every row (sometimes it's the same rank, we don't want that)
            else:
                row_parts = row.split(',')
                rank += 1
                # determine how many characters to remove from the row start
                if row_parts[0] == 'None':
                    row = str(rank) + row[4:]
                else:
                    idx = number_of_digits(int(row_parts[0]))
                    row = str(rank) + row[idx:]
                new_row = date_str + ',' + row
            result_list.append(new_row)
        # after rank assignment write results to csv file
        result = "\n".join(result_list)

        csv_file = f'{date_str}.csv'
        # creating and uploading file to s3 bucket
        upload_file_bucket = 'ucdb-stage'
        upload_file_key = 'clubelo/data/' + str(csv_file)
        s3.put_object(Body=result, Bucket=upload_file_bucket, Key=upload_file_key)
    
    else:
        print('Error while scraping for date {date_str}\n')


def add_month(current_scrape_date):
    year = current_scrape_date.year
    month = current_scrape_date.month + 1
    # if we get to 13th month, add one year and set month to january
    if month > 12:
        month = 1
        year += 1
    # datetime.date(year, month, current_scrape_date.day) -> generates error
    new_date_str = '{:d}-{:02d}-{:02d}'.format(year, month, current_scrape_date.day)
    return date.fromisoformat(new_date_str)


def number_of_digits(num):
    count = 1
    while(num >= 10):
        num /= 10
        count += 1
    return count


if __name__ == "__main__":
    scraper_type = 'daily'
    date_today = date.fromisoformat(datetime.today().strftime('%Y-%m-%d'))
    
    # strip() added to work with docker
    if scraper_type.strip() == "daily":
        scrape_date = date_today
        handle_request(scrape_date)
    
    elif scraper_type.strip() == "historic":
        scrape_date = date.fromisoformat('1960-01-01')
        while (date_today - scrape_date).days > 0:
            handle_request(scrape_date)
            scrape_date = add_month(scrape_date)
    else:
        print("Add 'daily' or 'historic' in a script call to select scraper type!")
