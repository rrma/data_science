#remove all features, which occurr only once

library(dplyr)

#fileName <- "FeatureTable_v0_label1.csv"

#allFtrs <- read.csv(fileName, header=TRUE, row.names=NULL, sep=";")

getFtrsOccurrenceGtOne <- function(features) {
  cols <- ncol(features)
  takeCols <- rep(FALSE, cols)
  
  #SMS id
  takeCols[1] <- TRUE
  takeCols[2] <- TRUE
  
  for(col in 3:cols){
    #is the feature available in 2 rows?
    if(sum(features[,col] > 0) > 1) {
      takeCols[col] <- TRUE
    }else{
      takeCols[col] <- FALSE
    }
  }
  
  features[,takeCols]

}

filteredFtrs <- getFtrsOccurrenceGtOne(allFtrs)

#start Added second round
filteredFtrs <- newFilteredFtrs
#end

labelledRowIndex <- is.na(filteredFtrs[,2]) == FALSE

labelledFtrs <- filteredFtrs[labelledRowIndex, ]

hamWords <- c()
spamWords <- c()

#go through all labelled Rows and collect the words, which are unique for ham/spam
#label: 0 = ham, 1 = spam

for(row in 1:nrow(labelledFtrs)){
  
  label <- labelledFtrs[row, "label"]
  
  for (col in which(labelledFtrs[row,] > 0)) {
      if(label == 0) {
        #0 - HAM
        hamWords <- unique(c(col, hamWords))
        
      }else if(label == 1) {
        #1 - SPAM
        spamWords <- unique(c(col, spamWords))
        
      }else{
        print("INVALID LABEL!!! at pos ", col)
        #break
      }
  }
}

finalHamWords <- setdiff(hamWords, spamWords)
finalSpamWords <- setdiff(spamWords, hamWords)

#remove label column
finalSpamWords <- finalSpamWords[-which(finalSpamWords == 2)]

#unlabelledFtrs <- filteredFtrs[is.na(filteredFtrs[,2]), ]

newFilteredFtrs <- filteredFtrs

for(row in 1:nrow(newFilteredFtrs)){
  
  if(is.na(newFilteredFtrs[row, 2]) == FALSE){
    #is labelled
    next
  }
  
  cntHam <- sum(newFilteredFtrs[row, finalHamWords] > 0)
  cntSpam <- sum(newFilteredFtrs[row, finalSpamWords] > 0)
  
  if(is.na(cntHam) || is.na(cntSpam)){
    if(is.na(cntHam) && is.na(cntSpam) == FALSE && cntSpam > 0){
      #assign label => SPAM
      #TODO improve in the future => use a threshold
      newFilteredFtrs[row, 2] = 1
  
    }else if(is.na(cntHam) == FALSE && is.na(cntSpam) && cntHam > 0){
      #assign label => HAM
      newFilteredFtrs[row, 2] = 0
    }
  }else {
    if(cntHam == cntSpam){
      #label cannot be assigned
      
    }else if(cntSpam > 0 && cntHam < cntSpam){
      #assign label => SPAM
      newFilteredFtrs[row, 2] = 1
      
    }else if(cntHam > 0){
      #assign label => HAM
      newFilteredFtrs[row, 2] = 0
    }
  }
}

sum(filteredFtrs[4155, finalHamWords] > 0)
sum(filteredFtrs[4155, finalSpamWords] > 0)


newLabelledRowIndex <- is.na(newFilteredFtrs[,2]) == FALSE

# number of unlabelled SMS
sum(is.na(newFilteredFtrs[,2]))
sum(is.na(filteredFtrs[,2]))

# 1st round: 673 left

write.csv(newFilteredFtrs[,2], file="result_table_v0.csv")