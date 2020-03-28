import pandas as pd
import numpy as np
df=pd.read_csv(r'../data/provinces_common_years_population.csv')

#first add total populations for each geography in the common_years_df
def total_population(df):
    df['canada'] = df.iloc[:, 1:13].sum(axis=1)
    df['maritimes'] = df[['NB','NS','PE']].sum(axis=1)
    df['western_canada'] = df[['BC','AB','SK','MB']].sum(axis=1)
    df['eastern_canada'] = df[['NB','NL','NS','ON','PE','QC']].sum(axis=1)
    df['prairies'] = df[['MB','SK','AB']].sum(axis=1)
    return df
df = total_population(df)