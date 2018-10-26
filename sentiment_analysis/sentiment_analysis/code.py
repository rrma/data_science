import pandas as pd
from KaggleWord2VecUtility import KaggleWord2VecUtility
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression as LR

output_file = 'test_predictions.csv'


print "Read files..."

train = pd.read_csv("TrainDataset.tsv",
                    header=0,
                    delimiter="\t",
                    quoting=3)
test = pd.read_csv("TestDataset.tsv",
                   header=0,
                   delimiter="\t",
                   quoting=3)

print "Parsing train and test reviews..."

clean_train_reviews = []
for review in train['review']:
    clean_train_reviews.append(" ".join(KaggleWord2VecUtility.review_to_wordlist(review)))

clean_test_reviews = []
for review in test['review']:
    clean_test_reviews.append(" ".join(KaggleWord2VecUtility.review_to_wordlist(review)))

vectorizer = TfidfVectorizer(max_features=40000, ngram_range=(1, 3),
                             sublinear_tf=True)

train_x = vectorizer.fit_transform(clean_train_reviews)

test_x = vectorizer.transform(clean_test_reviews)

print "Train model..."

model = LR()
model.fit(train_x, train["sentiment"])
p = model.predict_proba(test_x)[:, 1]
pClass = model.predict(test_x)

print "Writing results..."

output = pd.DataFrame(data={"document_id": test["document_id"], "sentiment": pClass})
output.to_csv(output_file, index=False, quoting=3)
