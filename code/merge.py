import json
import numpy as np
import pandas as pd

business = []
with open('yelp_Fall2023/business.json', encoding='utf-8') as file:
    for line in file:
        json_data = json.loads(line)
        d = pd.json_normalize(json_data)
        
        # Corrected boolean indexing with parentheses around each condition
        condition = (
            d['categories'].notna() & 
            (d['state'] == 'CA') & 
            d['categories'].str.contains('Hotel|Hotel & Travel', na=False)
        )
        if condition.all():  # Check if any row in 'd' meets the condition
            business.append(d[condition])

# Concatenate the list of dataframes
business_df = pd.concat(business, ignore_index=True)

review = []
with open('yelp_Fall2023/review.json', encoding='utf-8') as file:
    for line in file:
        json_data = json.loads(line)
        review.append(json_data)

review_df = pd.DataFrame(review)

hotel_CA = business_df.merge(review_df, on='business_id', suffixes=['_business', '_review'])

trips = pd.read_csv('yelp_Fall2023/Trips_by_Distance.csv')

# subset trips for santa barbara county
santa = trips[(trips['County Name']=='Santa Barbara County') &  (trips['County FIPS'].notna()) & (trips['State Postal Code']=='CA')]
santa = santa.reset_index()

# subset json of cities for santa barbara county
cities = ['Montecito', 'Santa Barbara', 'SANTA BARBARA AP', 'Goleta', 'Carpinteria', 
          'Real Goleta', 'Summerland', 'Isla Vista', 'Santa Maria']
hotel_santa = hotel_CA[hotel_CA['city'].isin(cities)]
hotel_santa = hotel_santa.reset_index()

# reformat date in json
def replace_date(date):
    new_date1 = date.split(' ')[0]
    new_date2 = new_date1.replace('-', '/')
    return new_date2

hotel_santa['date'] = hotel_santa['date'].apply(replace_date)

col_lst = ['Population Staying at Home',
       'Population Not Staying at Home', 'Number of Trips',
       'Number of Trips <1', 'Number of Trips 1-3', 'Number of Trips 3-5',
       'Number of Trips 5-10', 'Number of Trips 10-25',
       'Number of Trips 25-50', 'Number of Trips 50-100',
       'Number of Trips 100-250', 'Number of Trips 250-500',
       'Number of Trips >=500']

santa_subset = santa[['Date'] + col_lst]
merged = hotel_santa.merge(santa_subset, left_on='date', right_on='Date')

merged.to_csv('hotel_SB_county.csv')
