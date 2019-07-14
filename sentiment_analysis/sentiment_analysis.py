import pandas as pd
import time
from KaggleWord2VecUtility import KaggleWord2VecUtility
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression


def get_words(reviews):
    """
    Gets list of relevant words per review using Kaggle's Word2VecUtility
    https://github.com/danielfrg/kaggle-word2vec/blob/master/DeepLearningMovies/KaggleWord2VecUtility.py_
    :param reviews: list of reviews which should be transformed to words
    :return: list of words per review
    """
    words = []
    for review in reviews:
        words.append("".join(KaggleWord2VecUtility.review_to_wordlist(review)))

    return words


def main():
    start = time.time()

    input_train = 'TrainDataset.tsv'
    input_test = 'TestDataset.tsv'
    output_file = 'predictions.csv'

    train = pd.read_csv(input_train,
                        header=0,
                        delimiter="\t",
                        quoting=3)
    test = pd.read_csv(input_test,
                       header=0,
                       delimiter="\t",
                       quoting=3)

    # get words from reviews
    train_reviews = get_words(train['review'])
    test_reviews = get_words(test['review'])

    print(train.shape)
    print(test.shape)

    vectorizer = TfidfVectorizer(max_features=40000,
                                 ngram_range=(1, 3),
                                 sublinear_tf=True)

    train_x = vectorizer.fit_transform(train_reviews)
    test_x = vectorizer.transform(test_reviews)

    # train model
    model = LogisticRegression()
    model.fit(train_x, train["sentiment"])

    # predict sentiment and store result
    predicted = model.predict(test_x)

    output = pd.DataFrame(data={"document_id": test["document_id"], "sentiment": predicted})
    output.to_csv(output_file, index=False, quoting=3)

    end = time.time()
    print('Execution time: {} seconds'.format(end - start))


if __name__ == "__main__":
    main()
