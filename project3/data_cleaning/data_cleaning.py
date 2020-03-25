import pandas as pd
from pandas import DataFrame
from itertools import chain


df=pd.read_excel(r'../data/case_study_1_cdd_database_final_0.xlsx')

####
#this file cleans the data of the CDD disaster database
####

###set numeric colms nans to 0
col_names = list(df.columns)
numeric_cols_names = list(chain(col_names[7:12], col_names[13:]))
df[numeric_cols_names] = df[numeric_cols_names].fillna(0)

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


def province_setter(x):
    if x == "Across Canada" :
        return 'AB BC MB NB NL NT NS NU ON PE QC SK YT'
    elif x == "Maritimes" :
        return 'NB NS PE'
    elif x == "Western Canada" :
        return 'BC AB SK MB'
    elif x == "Eastern Canada" :
        return 'NB NL NS ON PE QC'
    elif x == "Prairies" :
        return 'MB SK AB'
    else:
        return x


df['Province/Territory'] = df['Province/Territory'].apply(province_setter)
#slice the text into a list
df['Province/Territory'] = df['Province/Territory'].apply(lambda x: list(x.split(" ") ))


##Split the rows with multiple provinces into their own rows
#make Province/Territory into a list

def row_exploder(df):
    rows_to_drop = []
    for index, row in df.iterrows():
        province_list = row['Province/Territory']
        if len(province_list)>1 :
            print('index:' , index)
            print('df shape old:' , df.shape)
            print('num of provinces:' , len(province_list))
            for province in province_list :#change the 'Province/Territory' to province
                new_row = row 
                new_row['Province/Territory'] = province
                df = df.append(new_row,ignore_index=True)
            print('df shape new:' , df.shape)
            rows_to_drop.append(index)
    df = df.drop(df.index[rows_to_drop])
    return df, rows_to_drop

def duplicate_row_dropped(df, rows_to_drop):
    for duplicate_row in rows_to_drop:
        df = df.drop(df.index[duplicate_row])
        df.reset_index(drop=True, inplace=True)
    return df
           
test, rows_to_drop= row_exploder(df)
#test = duplicate_row_dropped(test, rows_to_drop)













