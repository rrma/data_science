# Sentiment Analysis

## Task Description

The task is to classify each movie review into positive and negative sentiment. 
The data set is the movie reviews collected from IMDb.

## Data

*TrainDataset.tsv* contains the training set and labels (25,000 samples). 
*TestDataset.tsv* holds the test set (25,000 samples).

Given fields:
  * document_id
  * sentiment
  * review

## Result

The implementation of this project was done during my time at university where this task was 
a [Kaggle competition](https://www.kaggle.com/c/sentiment-analysis/overview) amongst the course participants 
(December 2016). 

I used [KaggleWord2VecUtitility](https://github.com/danielfrg/kaggle-word2vec/blob/master/DeepLearningMovies/KaggleWord2VecUtility.py) 
to extract the words from the movie reviews and TfidfTransformer of sklearn to transform the extracted words 
to a word-frequency matrix including ngrams with up to 3 words.

I reached an *accuracy score of 89.872%* on the holdout set.


