import numpy as np
import pandas as pd
from itertools import chain
from datetime import datetime, timedelta
import cpi
'''
This file cleans the data of the CDD disaster database.
Since this file uses cleaned data from other files, please run provincial_data_web_importer first then province_df_agregator
if you cannot access the data they created in ../data/
'''

###

df=pd.read_excel(r'../data/case_study_1_cdd_database_final_0.xlsx')
common_years_df=pd.read_csv(r'../data/provinces_common_years_population.csv')

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


def province_and_geography_labels_setter(df):
    """
    adds new column that determine which geographical region of canada was involved.
    add single if only one province was involved and one of "across canada, western canada,
    eastern canada...
    adds an event id to each event
    """
    df['provinces_level'] = 'single'
    df['event_id'] = -1
    for index, row in df.iterrows():
        province_or_area = row['Province/Territory']
        if province_or_area == "Across Canada" :
            df.at[index, 'Province/Territory'] = 'AB BC MB NB NL NT NS NU ON PE QC SK YT'
            df.at[index, 'provinces_level'] = 'canada'
            df.at[index, 'event_id'] = index
        elif province_or_area == "Maritimes" :
            df.at[index, 'Province/Territory'] = 'NB NS PE'
            df.at[index, 'provinces_level'] = 'maritimes'
            df.at[index, 'event_id'] = index
        elif province_or_area == "Western Canada" :
            df.at[index, 'Province/Territory'] = 'BC AB SK MB'
            df.at[index, 'provinces_level'] = 'western_canada'
            df.at[index, 'event_id'] = index
        elif province_or_area == "Eastern Canada" :
            df.at[index, 'Province/Territory'] = 'NB NL NS ON PE QC'
            df.at[index, 'provinces_level'] = 'eastern_canada'
            df.at[index, 'event_id'] = index
        elif province_or_area == "Prairies" :
            df.at[index, 'Province/Territory'] = 'MB SK AB'
            df.at[index, 'provinces_level'] = 'prairies'
            df.at[index, 'event_id'] = index
        else :
            df.at[index, 'event_id'] = index
            if len(list(province_or_area.split(" ")))>1 :
                df.at[index, 'provinces_level'] = province_or_area
    return df

df = province_and_geography_labels_setter(df)
#slice the text into a list
df['Province/Territory'] = df['Province/Territory'].apply(lambda x: list(x.split(" ") ))


##Split the rows with multiple provinces into their own rows
#make Province/Territory into a list
def row_exploder(df):
    """
    this function appends rows to df for those values in which in an event occured across multiple provinces.
    the appended rows are the same row as the row with multiple provinces, but each province gets its own row.
    the original row with a list with multiple values gets dropped
    single event rows get their list converted to string.
    since each province is of different sizes we need to divide the variables in the new rows
    by each provinces population proportions.
    """
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
    """
    find the average event duration for each event_type of event and set the events with placeholders to that value
    recall, we want to exclude the placeholders from the averages
    """
    df_excluding_bad_rows = df[(df['event_duration']!=-1)]
    df_event_averages = df_excluding_bad_rows.groupby(['EVENT TYPE']).mean()
    return df_event_averages

def event_duration(df, bad_rows_present):
    """
    this function creates a new column of event_duration for each event, in days
    bad rows defined by whether the EVENT END DATE follows the correct format or not
    good rows have their event_duration calculated. bad rows get a placeholder
    bad rows then get an event_duration that is the average duration for that observations event type
    """
    df['event_duration'] = -1
    if bad_rows_present == 1 :
        ##find the event duration for good entries and set bad entries to -1 placeholder
        bad_event_index = list(range(844, 857))+ list(range(810, 813)) +list(range(0,3)) + list(range(5,8)) +[9,14,24]
        for index, row in df.iterrows() :
            if index not in bad_event_index :
                df.at[index, 'event_duration'] = (row['EVENT END DATE'] - row['EVENT START DATE']).days
            else:
                df.at[index, 'event_duration'] = -1
        #set averages by event types for bad rows
        df_event_averages = event_type_averages(df)
        for index in bad_event_index:
            bad_row_event_type = df.loc[index, 'EVENT TYPE']
            df.at[index, 'event_duration'] = df_event_averages.loc[bad_row_event_type, 'event_duration']
    else:
        df['event_duration'] = df.apply(lambda x:  x['EVENT END DATE'] - x['EVENT START DATE'])
    return df

df = event_duration(df, 1)


# =============================================================================
# Add the population of the province when the event took place
#if an event took place over many years we take the average of the population
#durring that time.
#we also add the total_event_population of all provinces invloved in that event. if an event
#involved a single province then population = total_event_population, else total_event_population
#is the sum of the populations of all provinces involved in the event at that year
# =============================================================================
def year_of_event(df):
    df['avg_year_of_event'] = -1
    for index, row in df.iterrows():
        avg_days_duration = df.loc[index, 'event_duration']/2
        df.at[index, 'avg_year_of_event'] =(row['EVENT START DATE'] + timedelta(days=avg_days_duration)).year
    return df

df = year_of_event(df)

def inflation(df):
    for index, row in df.iterrows():
        if row['avg_year_of_event'] >1912 :
            df.at[index, 'NORMALIZED TOTAL COST'] = cpi.inflate(row['ESTIMATED TOTAL COST'], row['avg_year_of_event'], to = 2014)
        else :
            df.at[index, 'NORMALIZED TOTAL COST'] = cpi.inflate(row['ESTIMATED TOTAL COST'], 1913, to = 2014)
    return df

df = inflation(df)

def st


