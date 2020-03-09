import pandas as pd
from operator import itemgetter
import ast
import clustering
import nltk
import re
nltk.download("stopwords")
from nltk.corpus import stopwords

#I assume you are in /data_cleaning
df=pd.read_csv("../data/ted_main.csv")

##Need to standardize the views by its age.
#add a number of days since video was published up to December 31, 2017 
#(unix timestamps is 1514678400) when the data set was created
df['publication_age'] = (1514678400-df['published_date'])/(60*60*24)
df['avg_views_per_day'] = df['views']/ df['publication_age']
#round to nearest integer because we work with poisson
df['avg_views_per_day']=df['avg_views_per_day'].round(0).astype(int)

##Add how old the video
#that is how many days since it was made (not published) to 
#December 31, 2017 (unix timestamps is 1514678400) when the dataset 
#was published
df['film_age'] = (1514678400-df['film_date'])/(60*60*24)

###Get the number of related talks.
#acts as a measure of how close to the center of the ted talks universe is a
#a video. The higher the more popular.
df['related_talks_count'] = df['related_talks'].apply(lambda x: len(x))

###Standardize number of comments by views.
#The nature of some videos could lead to more comments but not necessarily more
#views such as a video on a contentious topic like religion.
df['comments_per_views'] = df['views']/ df['comments']


### Turn the ratings dictionary into a score.
#Will look into adding weights to these to account for frequencies of certain
#words i.e account for 

#turns stringified dictionary into python dictionary
df['ratings'] = df['ratings'].apply(lambda x: eval(str(x))) 

counter = {'Funny':0, 'Beautiful':0, 'Ingenious':0, 'Courageous':0, 
           'Longwinded':0, 'Confusing':0, 'Informative':0, 
           'Fascinating':0, 'Unconvincing':0, 'Persuasive':0,
           'Jaw-dropping':0, 'OK':0, 'Obnoxious':0, 'Inspiring':0}

#adds a count to ratings
for i in range(len(df['ratings'])):
    for j in range(len(df['ratings'][i])):
        counter[df['ratings'][i][j]['name']] += df['ratings'][i][j]['count']


getter = itemgetter("name", "count")     
#convert list of dictionary to list of list
df['ratings1'] = df['ratings'].apply(lambda x: [list(getter(item)) for item in x]) 
#sor the list by name of rating type
df['ratings1'] = df['ratings1'].apply(lambda x: sorted(x, key=itemgetter(0)))
#add up all the rating counts
df['aggregateRatings'] = df['ratings1'].apply(lambda x: x[0][1]-x[1][1]+x[2][1]+x[3][1]
                                                          +x[4][1]+x[5][1]+x[6][1]+x[7][1]+x[8][1]
                                                          -x[9][1]-x[10][1]-x[11][1]+x[12][1]-x[13][1])
                                         
# To account for the bias in positive reviews we introduce an average 
# rating.
    
df['totalRatings'] = df['ratings'].apply(lambda x: sum([x[i]['count'] for i in range(len(x))]))

df['avgPerRating'] = df['aggregateRatings']/df['totalRatings']

###Themes
##categorize each video by a theme using clustering.
#convert the list of tags to a sentence
df['tags_text'] = df['tags'].apply(lambda x: ''.join(x)) 
#cluster using kmeans with tfidf and bow
#cluster into 20 groups
clustering.kmeans_bow(df, 10, 'tags_text', 'tags_label_bow')
clustering.kmeans_tfidf(df, 10, 'tags_text', 'tags_label_tfidf')

###Video Titles Sentiment
##categorize each video title by a theme using clustering.
#convert the list of tags to a sentence
#cluster using kmeans with tfidf and bow
#cluster into 2 groups (oridnary title, click bait)

#some cleaning
df['title'] = df['title'].str.lower().str.split(' ') 
stop = stopwords.words('english')
df['title_cleaned'] = df['title'].apply(lambda x: [item for item in x if item not in stop])
df['title_cleaned'] = df['title_cleaned'].apply(lambda x: ' '.join(x)) 
#the clustering
clustering.kmeans_bow(df, 4, 'title_cleaned', 'title_sentiment_bow')
clustering.kmeans_tfidf(df, 4, 'title_cleaned', 'title_sentiment_tfidf')


##Length of title (by number of works)
df['title_length']=df['title'].apply(lambda x: len(x))

###Popularity score
##Normailze the new response variables and sum them

#normalization
cols_to_norm = ['avg_views_per_day','avgPerRating', 'comments_per_views', 'related_talks_count']
#save the normed columns in new columns
new_cols_to_norm = ['avg_views_per_day_norm','avgPerRating_norm', 'comments_per_views_norm', 'related_talks_count_norm']
other_cols_to_norm = ['comments',
 'duration',
 'num_speaker',
 'views',
 'publication_age',
 'film_age',
 'aggregateRatings',
 'totalRatings',
 'title_length']

#these columns are made so as to make the latex tables for continuous/categorical data 
#easier to create without affecting the established models
old_columns_without_norm = ['comments_no_norm',
 'duration_no_norm',
 'num_speaker_no_norm',
 'views_no_norm',
 'publication_age_no_norm',
 'film_age_no_norm',
 'aggregateRatings_no_norm',
 'totalRatings_no_norm',
 'title_length_no_norm']
df[old_columns_without_norm ] = df[other_cols_to_norm]
#save these normed columns to new columns
df[new_cols_to_norm]= df[cols_to_norm].apply(lambda x: (x - x.min()) / (x.max() - x.min()))
#change these columns
df[other_cols_to_norm]= df[other_cols_to_norm].apply(lambda x: (x - x.min()) / (x.max() - x.min()))
df['popularity'] = df[new_cols_to_norm].sum(axis=1)

df.to_csv(r'../data/cleaned_data.csv', index = False)










