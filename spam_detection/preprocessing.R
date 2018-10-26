getSpecialChars <- function(filename) {
  oDocuments <- read.csv(fileName, header=TRUE, row.names=NULL, sep=";", colClasses=c("factor","character"))
  
  rows <- nrow(oDocuments)
  targetCol <- "SMS"
  
  uniqueChars <- c();
  
  for(row in 1:rows){
    oEntry <- tolower(oDocuments[row, targetCol])
    
    allChars <- c(uniqueChars, strsplit(oEntry, NULL)[[1]])
    uniqueChars <- unique(allChars)
  }
  
  uniqueChars[grep("[^A-Za-z0-9]", uniqueChars)]
}


fileName <- "Documents.csv"

getSpecialChars(fileName)

#remove them from the splitted words
acceptedSpecialChars <- c("(", ")", "&", "'", "!", "?", "£", "*", ">", "/", "+", ":", "=", "-", "‘", ";", "#", "\"", "@", "$", "-", "<", ">", "…", "%")


#used for columns
countFeatures <- c("!", "?", "£", "*", "<", ">", "/", "+", "=", "-", "#", "@", "$", "%", "…", "\"")
countSmileys <- c(":)", ";)")

# 1. to lower case
# 2. split into words
# 3. remove all special characters from word
# 4. replace multiple spaces with one, trim


# BEGIN FEATURE SELECTION
oDocuments <- read.csv(fileName, header=TRUE, row.names=NULL, sep=";", colClasses=c("factor","character"))
rows <- nrow(oDocuments)
#rows <- 30
targetCol <- "SMS"

featureWords <- c()

for(row in 1:rows){
  entry <- tolower(oDocuments[row, targetCol])
  
  #split into words
  curWords <- strsplit(entry, ' ')[[1]]
  
  words <- c()
  
  for(word in 1:length(curWords)){
    #remove special chars from word
    newWord <- gsub("[^A-Za-z0-9]", "", curWords[word])
   
    if(newWord == ""){
      next()
    }
    
     newWordNumber <- as.numeric(newWord)
    #check
    if(is.numeric(newWordNumber) & !is.na(newWordNumber)){
      #print("VALID NUMERIC")
    }else{
      
     # print(newWord)
      words <- c(words, newWord)
    }
  }
  
  featureWords <- unique(c(featureWords, words))
  
} 

allFeatures <- c(featureWords, countFeatures) 

getFeatureIndex <- function(featureName){
  index <- which(allFeatures==featureName) #grep(featureName, x=allFeatures, fixed=TRUE)
  
  if(length(index) == 0){
    #special char is not availble
     index <- -1
  }
  
  index
}

# END FEATURE SELECTION


#    -> check if word contains special character
#    -> if yes:  count++ and remove special character from word


buildTable <- function(fileName) {
  oDocuments <- read.csv(fileName, header=TRUE, row.names=NULL, sep=";", colClasses=c("factor","character"))
  
  #str(oDocuments)
  #rows <- 6
  rows <- nrow(oDocuments)
  targetCol <- "SMS"
  
  
  words <- c()
  specialChars <- c()
  uniqueChars <- c()

  result <- matrix(nrow=rows, ncol=length(allFeatures))
  
  
  
  for(row in 1:rows){
    featureEntry <- rep(0, times=length(allFeatures))
    entry <- tolower(oDocuments[row, targetCol])
    
    #count smileys (at first, because multiple chars)
    #smiley chars are removed
    for(i in 1:length(countSmileys)){
      smiley <- countSmileys[i]
      cntSmileys <- gregexpr(smiley, entry)[[1]][1]
      
      if(cntSmileys > 0){
        index <- getFeatureIndex(smiley) #grep(pattern=smiley, x=allFeatures, fixed=TRUE)
        
        if(index != -1){
          featureEntry[index] <- featureEntry[index] + cntSmileys
        }
        entry <- gsub(smiley, "", entry)
      }
    }
    
    #split into words
    curWords <- strsplit(entry, ' ')[[1]]
    
    #count special characters features
    for(j in 1:length(curWords)){
      #split word in single chars
      
      allChars <- strsplit(curWords[j], NULL)[[1]]

      #get all special characters in the word
      allSpecialChars <- allChars[grep("[^A-Za-z0-9]", allChars)]

      if(length(allSpecialChars) > 0){

          for(k in 1:length(allSpecialChars)){
          
          index <- getFeatureIndex(allSpecialChars[k])
  
          if(index == -1){
            #special char is not supported
            next
          }
  
          featureEntry[index] <- featureEntry[index] + 1
        }
      }
      
      #remove all special chars from word
      word <- gsub("[^A-Za-z0-9]", "", curWords[j])
      
      if(word != ""){
        index <- getFeatureIndex(word)
        if(index != -1){
          featureEntry[index] <- featureEntry[index] + 1
        }
      }
    }
 
    
    result[row,] <- featureEntry
  }
}


write.csv(result, file="FeatureTable_v0.csv")
  
#doPreprocessing("Documents.csv")


