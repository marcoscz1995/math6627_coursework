import pandas as pd

df = pd.read_csv(r'../data/final_cleaned.csv')

def normalizer_and_composite_score_maker(df, norm_cols_range, composite_score_name):
    """
    This function normalizes the 'proportionalized' columns in df with column number norm_cols_range. Each column is normalized
    and set to a new column. These columns are then summed to create a composite_score_name
    """
    new_cols_to_norm = []
    for col in norm_cols_range:
        original_col_name = df.columns[col]
        normalized_col_name = 'norm_' + original_col_name
        #normalize the old column and write to new column
        df[normalized_col_name] = df[original_col_name].apply(lambda x: (x - x.min()) / (x.max() - x.min()))
        new_cols_to_norm.append(normalized_col_name)
    df[composite_score_name] = df[new_cols_to_norm].sum(axis=1)
    return df

#initialize the column ranges
cols_range_human = list(range(30,33)) +list(range(42,43))
cols_range_econ = list(range(33,42))
import
df = normalizer_and_composite_score_maker(df, cols_range_human, 'human_cost_comp_score')
df = normalizer_and_composite_score_maker(df, cols_range_econ, 'econ_cost_comp_score')


