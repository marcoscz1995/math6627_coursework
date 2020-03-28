import pandas as pd
from functools import reduce
"""
	This file aggregates the provincial dfs web scraped from provincial_data_web_importer.
	It then finds the total populations for the main geographical areas of canada for each year that 
	is common among all provincial data.
"""
#import the data
df_list = []
def df_creator(province):
    csv_name = r'../data/'+'population_by_year_df_'+province+'.csv'
    df = pd.read_csv(csv_name)
    df_list.append(df)
    return df

df_Alberta = df_creator('AB')
df_British_Columbia = df_creator('BC')
df_Manitoba = df_creator('MB')
df_New_Brunswick = df_creator('NB')
df_Newfoundland_and_Labrador = df_creator('NL')
df_Northwest_Territories = df_creator('NT')
df_Nova_Scotia = df_creator('NS')
df_Nunavut = df_creator('NU')
df_Ontario = df_creator('ON')
df_Prince_Edward_Island = df_creator('PE')
df_Quebec = df_creator('QC')
df_Saskatchewan = df_creator('SK')
df_Yukon = df_creator('YT')


# =============================================================================
# Join the data on common years
# =============================================================================
year_list=[df['year'] for df in df_list]
common_years = sorted(list(set(year_list[0]).intersection(*year_list)))
df_list = [df[df['year'].isin(common_years)] for df in df_list]
common_years_df = reduce(lambda left,right: pd.merge(left,right,on='year'), df_list)

#add total populations for each geography group
def total_population(df):
    df['canada'] = df.iloc[:, 1:13].sum(axis=1)
    df['maritimes'] = df[['NB','NS','PE']].sum(axis=1)
    df['western_canada'] = df[['BC','AB','SK','MB']].sum(axis=1)
    df['eastern_canada'] = df[['NB','NL','NS','ON','PE','QC']].sum(axis=1)
    df['prairies'] = df[['MB','SK','AB']].sum(axis=1)
    return df
common_years_df  = total_population(common_years_df )

common_years_df.to_csv(r'../data/provinces_common_years_population.csv', index = False)








