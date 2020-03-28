import numpy as np
import pandas as pd
#from __future__ import division
from itertools import chain
from datetime import datetime, timedelta
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

df =year_of_event(df)

def add_population_to_provinces(event_df, population_df):
    """
    we add the population to df for each province and year. The population data is pulled from common_years_df.
    To do so we take the absolute difference between the year which the event took place from the years in common_years_df,
    we then find the index where the absolute min is in year_list to get the closest year in common_years_df to the year of the event in
    df. We then put this closest year and the population at that year from common_years_df into the df.
    """
    year_list = list(population_df['year']) #list of all years
    year_array = np.array(population_df['year']) #make the above list as a np array
    event_df['closest_year'] = -1
    event_df['population'] = -1
    for index, row in event_df.iterrows():
        event_avg_year = row['avg_year_of_event']
        year_list_differnce_absolute = [abs(event_avg_year-event_year) for event_year in year_array]
        index_min = np.argmin(year_list_differnce_absolute)
        year_list_value_at_index_min = year_list[index_min]
        event_df.at[index, 'closest_year'] = year_list_value_at_index_min
        province_abbreviation = row['Province/Territory']
        event_df.at[index, 'population'] = population_df.at[index_min, province_abbreviation]
    return event_df

df = add_population_to_provinces(df, common_years_df)


# =============================================================================
# divide the respective variables by their proportional population weights
# =============================================================================

#find the prop weights for each event
#add total populations per event_id
def add_total_event_population_to_provinces(event_df, population_df):
    '''
    for those events that either involved only one province, or had one of the defined canadian geographies (canada, western canada,...)
    we set their total population in 'total_event_population'. For those events with one province, 'total_event_population' is the same as 'population'.
    For those with defined geography, they get their respective total population from common_years_df for the respective year that the event took place.
    '''
    event_df['total_event_population'] = -1
    for index, row in event_df.iterrows():
        provinces_involved = row['provinces_level']
        if provinces_involved != 'single' :
            if provinces_involved in ['canada', 'maritimes', 'western_canada', 'eastern_canada', 'western_canada', 'prairies'] :
                year = row['closest_year']
                event_df.at[index, 'total_event_population'] = population_df.loc[population_df['year']==year, provinces_involved]
        else :
            event_df.at[index, 'total_event_population'] = event_df.at[index, 'population']
    return df
df = add_total_event_population_to_provinces(df, common_years_df)

####here we add the sumed population for those events where 'total_event_population' == -1. ie those events with more than one provinces,
###but not enough to be a geographic region. We create a subset of the df with only these events, them group them by event_id and take their sum.
##This sum is their total_event_population. We make a dictionary with the event id and its total population to be used later to add them to df.
##We then map the df for those odd events using their event_id to the dictionary, and set non mapped values to their original value.
odd_events_population_dictionary = df[df['total_event_population'] == -1].groupby('event_id')['population'].sum().to_dict()
df['total_event_population'] = df['event_id'].map(odd_events_population_dictionary).fillna(df['total_event_population'])

#add the proportional weights
df['prop_pop_weight'] = df['population']/df['total_event_population']

#multiply the columns [7:11], [13:20] by proportional weights to get provincial columns
def proportional_effects(df):
    columns_to_proportionalize = list(range(7,12))+list(range(13,21))
    for col in columns_to_proportionalize :
        original_column_name = df.columns[col]
        proportional_column_name = 'proportional_'+original_column_name
        df[proportional_column_name] = df[original_column_name]*df['prop_pop_weight']
    return df

df = proportional_effects(df)

df.to_csv(r'../data/final_cleaned.csv', index = False)













