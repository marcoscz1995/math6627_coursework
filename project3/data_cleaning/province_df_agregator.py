import pandas as pd
from functools import reduce

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
#import the data
df_list = []
def df_creator(province):
    csv_name = r'../data/'+'df_'+ province +'.csv'
    df = pd.read_csv(csv_name)
    df.columns = ['year',province+'_population']
    df_list.append(df)
    return df

df_Alberta = df_creator('Alberta')
df_British_Columbia = df_creator('British_Columbia')
df_Manitoba = df_creator('Manitoba')
df_New_Brunswick = df_creator('New_Brunswick')
df_Newfoundland_and_Labrador = df_creator('Newfoundland_and_Labrador')
df_Northwest_Territories = df_creator('Northwest_Territories')
df_Nova_Scotia = df_creator('Nova_Scotia')
df_Nunavut = df_creator('Northwest_Territories')
df_Ontario = df_creator('Ontario')
df_Prince_Edward_Island = df_creator('Prince_Edward_Island')
df_Quebec = df_creator('Quebec')
df_Saskatchewan = df_creator('Saskatchewan')
df_Yukon = df_creator('Yukon')


# =============================================================================
# Join the data on common years
# =============================================================================
year_list=[df['year'] for df in df_list]
common_years = sorted(list(set(year_list[0]).intersection(*year_list)))
df_list = [df[df['year'].isin(common_years)] for df in df_list]
common_years_df = reduce(lambda left,right: pd.merge(left,right,on='year'), df_list)
common_years_df.to_csv(r'../data/provinces_common_years_population.csv', index = False)








