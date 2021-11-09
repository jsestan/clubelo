#!/bin/bash
python scrape_club_elo.py daily
python csv_to_postgres.py 
python temp_to_main.py 
python run_sql_scripts.py 