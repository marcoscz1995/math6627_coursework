import pandas as pd

df = pd.read_csv(r'../data/final_cleaned.csv')
gdp = pd.read_csv(r'../data/canada_govt_spending.csv')
def normalizer_and_composite_score_maker(df, norm_cols_range, composite_score_name):
    """
    This function normalizes the 'proportionalized' columns in df with column number norm_cols_range. Each column is normalized
    and set to a new column. These columns are then summed to create composite_score_name
    """
    new_cols_to_norm = []
    for col in norm_cols_range:
        original_col_name = df.columns[col]
        col_max = df[original_col_name].max()
        col_min = df[original_col_name].min()
        normalized_col_name = 'norm_' + original_col_name
        #normalize the old column and write to new column
        df[normalized_col_name] = df[original_col_name].apply(lambda x: (x - col_min) / (col_max - col_min))
        new_cols_to_norm.append(normalized_col_name)

    df[composite_score_name] = df[new_cols_to_norm].sum(axis=1)
    print(list(df))
    return df

#initialize the column ranges
col_names = list(df.columns)
cols_range_human = list(range(30,33)) + [34]
df = normalizer_and_composite_score_maker(df, cols_range_human, 'human_cost_comp_score')

def num_provinces_involved(df):
    df['num_provinces_involved'] = -1
    for index, row in df.iterrows() :
         if row['provinces_level'] == 'single' :
             df.at[index, 'num_provinces_involved'] = 1
         elif row['provinces_level'] == 'canada' :
             df.at[index, 'num_provinces_involved'] = 13
         elif row['provinces_level'] == 'western_canada' :
             df.at[index, 'num_provinces_involved'] = 4
         elif row['provinces_level'] == 'eastern_canada' :
             df.at[index, 'num_provinces_involved'] = 6
         elif row['provinces_level'] == 'maritimes' :
             df.at[index, 'num_provinces_involved'] = 3
         elif row['provinces_level'] == 'prairies' :
             df.at[index, 'num_provinces_involved'] = 3
         else :
             df.at[index, 'num_provinces_involved'] = len(list(row['provinces_level'].strip().split(' ')))
    return df

def bc_on_or_not(df):
    df['BC_or_ON'] = -1
    for index, row in df.iterrows():
        df.at[index, 'BC_or_ON'] = 1 if row['Province/Territory'] == 'BC' or row['Province/Territory'] == 'ON' else 0
    return df

#add government spending
df = pd.merge_asof(df.sort_values('closest_year'), gdp, left_on='closest_year', right_on='year', direction='nearest')


df = num_provinces_involved(df)
df['NORMALIZED TOTAL COST'] = (df['NORMALIZED TOTAL COST']/1000000).round(3)
df.to_csv(r'../data/final_cleaned_with_composite_scores.csv', index = False)





























