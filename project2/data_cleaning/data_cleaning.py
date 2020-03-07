import warnings
warnings.filterwarnings('ignore')
import ast
import pandas as pd
# =============================================================================
# import numpy as np
# import matplotlib
# import matplotlib.pyplot as plot
# from textblob import TextBlob
# from keras.models import Sequential
# from keras.layers import Dense, Activation, Dropout
# from keras.regularizers import l2
# from keras.optimizers import SGD
# import scipy.stats
# from scipy.stats import gaussian_kde
# import re
# import ast
# import random
# from sklearn import preprocessing
# =============================================================================

df=pd.read_csv("../data/ted_main.csv")

# =============================================================================
# Turn the ratings dictionary into a score.
#Will look into adding weights to these to account for frequencies of certain
#words i.e account for 
# =============================================================================

#turns stringified dictionary into python dictionary
df['ratings'] = df['ratings'].apply(lambda x: eval(str(x))) 

counter = {'Funny':0, 'Beautiful':0, 'Ingenious':0, 'Courageous':0, 
           'Longwinded':0, 'Confusing':0, 'Informative':0, 
           'Fascinating':0, 'Unconvincing':0, 'Persuasive':0,
           'Jaw-dropping':0, 'OK':0, 'Obnoxious':0, 'Inspiring':0}

#adds a count to 
for i in range(len(df['ratings'])):
    for j in range(len(df['ratings'][i])):
        counter[df['ratings'][i][j]['name']] += df['ratings'][i][j]['count']
        
df['aggregateRatings'] = df['ratings'].apply(lambda x: \
                                            x[0]['count']+ \
                                            x[1]['count']- \
                                            x[2]['count']+ \
                                            x[3]['count']- \
                                            x[4]['count']- \
                                            x[5]['count']+ \
                                            x[6]['count']+ \
                                            x[7]['count']+ \
                                            x[8]['count']+ \
                                            x[9]['count']+ \
                                            x[10]['count']+ \
                                            x[11]['count']- \
                                            x[12]['count']- \
                                            x[13]['count'])
# =============================================================================
# To account for the bias in positive reviews we introduce an average 
# rating.
# =============================================================================
    
df['totalRatings'] = df['ratings'].apply(lambda x: sum([x[i]['count'] for i in range(len(x))]))

df['avgPerRating'] = df['aggregateRatings']/df['totalRatings']




























