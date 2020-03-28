import pandas as pd
import requests
from bs4 import BeautifulSoup
from tabulate import tabulate
import csv
import numpy as np
'''
'''

prov_terr_dict = {
    'AB': 'Alberta',
    'BC': 'British Columbia',
    'MB': 'Manitoba',
    'NB': 'New Brunswick',
    'NL': 'Newfoundland and Labrador',
    'NT': 'Northwest Territories',
    'NS': 'Nova Scotia',
    'NU': 'Nunavut',
    'ON': 'Ontario',
    'PE': 'Prince Edward Island',
    'QC': 'Quebec',
    'SK': 'Saskatchewan',
    'YT': 'Yukon'
}

prov_terr = list(prov_terr_dict.values())



# =============================================================================
# make the df for each province and save them to csv
# =============================================================================
def province_df_maker(province,abrev, location):
    url = 'https://en.wikipedia.org/wiki/Demographics_of_' + province
    res = requests.get(url)
    soup = BeautifulSoup(res.content,'lxml')
    table = soup.find_all('table')[location]
    df = pd.read_html(str(table))[0]
    print(url)
    print('original df shape ', df.shape)
    df_1 = df[df.columns[0]]
    df_2 = df[df.columns[1]]
    df = pd.concat([df_1, df_2], axis = 1, sort = False)
    df.columns = ['year',abrev]
    if province == 'Nova_Scotia'  :
        rows_to_drop = [0,1,2, 15,16]
        df = df.drop(df.index[rows_to_drop])
        df = df.astype(int)
    if province == 'Newfoundland_and_Labrador'  :
        df['year'] = df['year'].apply(lambda x: x[:4])
        df = df.astype(int)
        df.at[3,abrev] = 20129
        df.at[4,abrev] = 6507
        print(df.dtypes)
        missing_dates = pd.DataFrame([[1901, 220984], [1911, 242619], [1921, 263033],[1931, 289588], [1941, 321819]], columns=df.columns)
        df = pd.concat([missing_dates, df], ignore_index=True)
    if province == 'Northwest_Territories'  :
        df.at[3,abrev] = 20129
        df.at[4,abrev] = 6507
        df.at[18,abrev] = 37360
        df = df.astype(int)
        print(df.dtypes)
    print('new df shape ', df.shape)
    print(df.dtypes)
    csv_name = r'../data/'+'population_by_year_df_'+abrev+'.csv'
    df.to_csv(csv_name, index = False)
    return df


df_Alberta = province_df_maker('Alberta','AB', 0)
df_British_Columbia = province_df_maker('British_Columbia','BC', 0)
df_Manitoba = province_df_maker('Manitoba','MB', 0)
df_New_Brunswick = province_df_maker('New_Brunswick','NB', 2)
df_Newfoundland_and_Labrador = province_df_maker('Newfoundland_and_Labrador','NL', 0) #starts at 1951 and has weird format on years
df_Northwest_Territories = province_df_maker('Northwest_Territories','NT', 0) #has stars
df_Nova_Scotia = province_df_maker('Nova_Scotia','NS', 2) #need to drop rows 0-2, 15,16
df_Nunavut = province_df_maker('Northwest_Territories','NU', 0) #set nunavuts population as NWT
df_Ontario = province_df_maker('Ontario','ON', 0)
df_Prince_Edward_Island = province_df_maker('Prince_Edward_Island','PE', 2)
df_Quebec = province_df_maker('Quebec','QC', 1)
df_Saskatchewan = province_df_maker('Saskatchewan','SK', 0)
df_Yukon = province_df_maker('Yukon','YT', 0)





















