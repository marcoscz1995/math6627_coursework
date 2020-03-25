import pandas as pd
from pandas import DataFrame
from itertools import chain


df=pd.read_excel(r'./data/case_study_1_cdd_database_final_0.xlsx')

####
#this file cleans the data of the CDD disaster database
####

###set numeric colms nans to 0
df[list(chain(list(df.columns)[7:12], list(df.columns)[13:]))] = df[list(chain(list(df.columns)[7:12], list(df.columns)[13:]))].fillna(0)

#Add names to missing values in Province/Territory
df[df['Province/Territory'].isnull()]
#set thunder bay(26), kirkland lake(28), st.lawrence river(756) to ON
#set deage to mont laurier(75), notre dame(81), st lawrence(756) to QC
df.at[26,'Province/Territory']= 'ON'
df.at[26,'Province/Territory']= 'ON'
df.at[28,'Province/Territory']= 'ON'
df.at[756,'Province/Territory']= 'ON QC'
df.at[75,'Province/Territory']= 'QC'
df.at[81,'Province/Territory']= 'QC'
df.at[285,'Province/Territory']= 'QC'

prov_terr = {
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
#Set  Across Canada to all the provinces
all_provinces_territories = ' '.join(map(str,list(prov_terr.keys())))

#Set western Canada to BC AB SK MB
western_canada = 'BC AB SK MB'
#Set eastern Canada to NB NL NS ON PE QC
eastern_canada = 'NB NL NS ON PE QC'
#Set maritimes to NB NS PE 
maritimes = 'NB NS PE' 
#Set Prairies to MB SK AB
prairies='MB SK AB'


def province_setter(x):
    if x == "Across Canada" :
        return all_provinces_territories
    elif x == "Maritimes" :
        return maritimes
    elif x == "Western Canada" :
        return western_canada
    elif x == "Eastern Canada" :
        return eastern_canada
    elif x == "Prairies" :
        return prairies
    else:
        return x

df['Province/Territory'] = df['Province/Territory'].apply(province_setter)

##Split the rows with multiple provinces into their own rows
#make Province/Territory into a list
df['Province/Territory'] = df['Province/Territory'].apply(lambda x: list(x.split(" ") ))

def row_exploder(df):
    for index, row in df.iterrows():
        province_list = row['Province/Territory']
        if len(province_list)>1 :
            for province in province_list :#change the 'Province/Territory' to province
                new_row = row 
                new_row['Province/Territory'] = province
                df = df.append(new_row,ignore_index=True)
            df.drop(df.index[index])
    return df
            
tes = row_exploder(df)
            
test = df['Province/Territory'].apply(lambda x: row_exploder(x))
df['Province/Territory'].apply(lambda x: )

for index, row in df.iterrows():
    prov_list = row['Province/Territory']
    new_row = row
    if len(x)>1 :
        for prov in prov_list :
            
            
            df.append(prov)
            break









