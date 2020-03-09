import re
import gensim
from sklearn.cluster import KMeans
#from preprocessing import n
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import DBSCAN
import scipy
from scipy.cluster import hierarchy
from sklearn.cluster import AgglomerativeClustering
import pandas as pd



def kmeans_bow(df, n, label):
    
    count_vect = CountVectorizer()
    bow = count_vect.fit_transform(df[label].values)
    bow.shape
    
    
    #use n which is set in preprocessing
    #n is the number of clusters we want
    model = KMeans(n_clusters = n ,init='k-means++', n_jobs = -1,random_state=99)
    model.fit(bow)
    model.predict(bow)
    
    # Giving Labels/assigning a cluster to each point/text
    df['BOW_Clus_Label'] = model.labels_ # the last column you can see the label numebers

    
    print("top terms per cluster:")
    order_centroids = model.cluster_centers_.argsort()[:, ::-1]
    terms = count_vect.get_feature_names()
    
    names_list =[]
    list_ints = list(range(0,n))
    
    for i in range(n):
        for ind in order_centroids[i, :n]:
            print(' %s' % terms[ind])
            names_list.append(terms[ind])
            break
    # Create a zip object from two lists
    zipbObj = zip(list_ints, names_list)
    # Create a dictionary from zip object
    dictOfWords = dict(zipbObj)
    
    df['BOW_Clus_with_Label']=df['BOW_Clus_Label'].replace(dictOfWords)
    
    return

"""
Kmeans with tf-idf
"""
def kmeans_tfidf(df,n, label):

    tfidf_vect = TfidfVectorizer()
    tfidf = tfidf_vect.fit_transform(df[label].values)
    tfidf.shape
    
    model_tf = KMeans(n_clusters = n, n_jobs = -1,random_state=99)
    model_tf.fit(tfidf)

    df['Tfidf_clus_label'] = model_tf.labels_
    
    names_list =[]
    list_ints = list(range(0,n))
    terms_tfidf = tfidf_vect.get_feature_names()
    order_centroids = model_tf.cluster_centers_.argsort()[:, ::-1]
    for i in range(n):
        for ind in order_centroids[i, :n]:
            print(' %s' % terms_tfidf[ind])
            names_list.append(terms_tfidf[ind])
            break
    # Create a zip object from two lists
    zipbObj = zip(list_ints, names_list)
    # Create a dictionary from zip object
    dictOfWords = dict(zipbObj)
    
    df['tfidf_Clus_with_Label']=df['Tfidf_clus_label'].replace(dictOfWords)
    
    return










