import pandas as pd
from itertools import chain
from datetime import datetime


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
# =============================================================================
#     this function appends rows to df for those values in which in an event occured across multiple provinces.
#       the appended rows are the same row as the row with multiple provinces, but each province gets its own row.
#       the original row with a list with multiple values gets dropped
#       single event rows get their list converted to string.
# =============================================================================
    rows_to_drop = []
    for index, row in df.iterrows():
        province_list = row['Province/Territory']
        if len(province_list)>1 :
            for province in province_list :#change the 'Province/Territory' to province
                new_row = row
                new_row['Province/Territory'] = province
                df = df.append(new_row,ignore_index=True)
            rows_to_drop.append(index)
        else:
            df.at[index,'Province/Territory'] = ' '.join(province_list)
    df = df.drop(df.index[rows_to_drop]) #drop duplicate rows
    return df

df= row_exploder(df)

# =============================================================================
# Clean dates to be all of the same format
# =============================================================================
#change values that do not mathch the rest of the columns date format for event start date
df.at[130,'EVENT START DATE']= datetime.strptime('2008-01-01 00:00:00', "%Y-%m-%d %H:%M:%S")
#find the average lenght of time for all events excluding those rows with incomplete data in 'EVENT END DATE'
def event_type_averages(df):
    ##find the average event duration for each event_type of event and set the events with placeholders to that value
    ##recall, we want to exclude the placeholders from the averages
    df_excluding_bad_rows = df[(df['event_duration']!=-1)]
    df_event_averages = df_excluding_bad_rows.groupby(['EVENT TYPE']).mean()
    return df_event_averages

def event_duration(df, bad_rows_present):
# =============================================================================
# this function creates a new column of event_duration for each event.
# bad rows defined by whether the EVENT END DATE follows the correct format or not
# good rows have their event_duration calculated. bad rows get a placeholder
# bad rows then get an event_duration that is the average duration for that observations event type
# =============================================================================
    df['event_duration'] = -1
    if bad_rows_present == 1 :
        ##find the event duration for good entries and set bad entries to -1 placeholder
        bad_event_index = list(range(844, 857))+ list(range(810, 813)) +list(range(0,3)) + list(range(5,8)) +[9,14,24]
        for index, row in df.iterrows() :
            if index not in bad_event_index :
                df.at[index, 'event_duration'] = (row['EVENT END DATE'] - row['EVENT START DATE']).days
            else:
                df.at[index, 'event_duration'] = -1
        print('done setting placeholders')
        #set averages by event types for bad rows
        df_event_averages = event_type_averages(df)
        for index in bad_event_index:
            bad_row_event_type = df.loc[index, 'EVENT TYPE']
            df.at[index, 'event_duration'] = df_event_averages.loc[bad_row_event_type, 'event_duration']
    else:
        df['event_duration'] = df.apply(lambda x:  x['EVENT END DATE'] - x['EVENT START DATE'])
    return df

df = event_duration(df, 1)
























