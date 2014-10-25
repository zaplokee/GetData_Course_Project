library(stringr)
library(dplyr)

grandpaDirectory<-getwd()

#download data for analysis
if(!file.exists("UCI HAR Dataset")) {
    fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, destfile="data_for_course_project.zip")
    unzip("data_for_course_project.zip")
}
setwd("./UCI HAR Dataset")
parentDirectory<-getwd()




#data from features.txt will be names of the columns for variables
readedFeaturesTxt<-read.table("features.txt", sep=" ", col.names=c("numberForFeature", "feature"), colClasses="character")
featuresNames561<-readedFeaturesTxt$feature




#read data from activity_labels.txt
readedActivityLabelsTxt<-read.table("activity_labels.txt", sep=" ", col.names=c("numberOfActivity", "activityLabel"), colClasses="character")
activityLabels<-readedActivityLabelsTxt$activityLabel
activityLabels<-tolower(activityLabels) #change upper-case letters to lower-case




#create function for repeating similar steps for different kinds of observations: "train" and "test"
combineSubjectXsetActivityKind<-function(kindOfObservation) {
    setwd(paste0(parentDirectory, "/", kindOfObservation))
    nameOfXSet<-paste0("X_", kindOfObservation)
    nameOfXSetTxt<-paste0(nameOfXSet, ".txt")
    nameOfySet<-paste0("y_", kindOfObservation)
    nameOfySetTxt<-paste0(nameOfySet, ".txt")
    nameOfSubjectSetTxt<-paste0("subject_", kindOfObservation, ".txt")
    
    readedySet<-read.table(nameOfySetTxt, sep="\n", col.names=nameOfySet, colClasses="integer")
    ySet<-as.factor(readedySet[,1]) #character vector with class label of activity
    levels(ySet)<-activityLabels #STEP3: descriptive activity names

    readedXSet<-read.table(nameOfXSetTxt, colClasses="numeric")

    XySet<-cbind(readedXSet, activityLabel=ySet) #combine X_set and y_set
    
    vectKindOfObservation<-rep(kindOfObservation, length(ySet))    
    XySetWithKindOfObservation<-cbind(XySet, kindOfObservation=vectKindOfObservation) #a part of dataset with observations for 561 variables, labels of activity and specified kind of observation (test or train)
    
    readedSubjectSet<-read.table(nameOfSubjectSetTxt, sep="\n", col.names="subject", colClasses="character")    
    functionResult<-cbind(subject=readedSubjectSet$subject, XySetWithKindOfObservation)
    
    
    return(functionResult)
}
#create test and train datasets
testDataset<-combineSubjectXsetActivityKind("test")
trainDataset<-combineSubjectXsetActivityKind("train")




#STEP1: merge test and train datasets
mergedDataset<-merge(testDataset, trainDataset, all=T)
setwd(grandpaDirectory)




#give columns names from source dataset (features.txt)
colnamesFormergedDataset<-colnames(mergedDataset)
for (i in 2:562) {
    colnamesFormergedDataset[i]<-featuresNames561[i-1]
}
colnames(mergedDataset)<-colnamesFormergedDataset




#STEP2: extracting only columns with mean() and std() to extractedMeanStdDataset 
meanInColnames<-str_detect(colnames(mergedDataset), "(.+)-mean\\(\\)(.*)")
stdInColnames<-str_detect(colnames(mergedDataset), "(.+)-std\\(\\)(.*)")
logicalCondition<-meanInColnames | stdInColnames
logicalCondition[c(1,563,564)]<-TRUE #include additional columns with observation number, subject identifier, activity label, kind of observation ("test" or "train")
extractedMeanStdDataset<-mergedDataset[1:nrow(mergedDataset),][, logicalCondition] #data frame with only mean and std variables for observations




#create conveniet order of columns 
extractedMeanStdDataset<-tbl_df(extractedMeanStdDataset)
extractedMeanStdDataset<-select(extractedMeanStdDataset, c(68, 1, -69, 2:67))


#auxiliary step - helps to place old names and new names of variables to CodeBook
oldColnames<-colnames(extractedMeanStdDataset)


#STEP4: use descriptive variable names
makeVariableNamesPretty<-function(extraSymbol, x) {
    
    splitted<-strsplit(x, split=extraSymbol)
    
    newVector<-character()
    for (i in 1:length(splitted)) { #choose element from the list
        
        changedNameOfVariable<-splitted[[i]][1]
        
        if (length(splitted[[i]])>1) { #if it contains more than 1 element  

            for (j in 2:length(splitted[[i]])) { #choose words from the list element
                firstChar<-substr(splitted[[i]][j],1,1)
                firstCharUpper<-toupper(firstChar)
                splitted[[i]][j]<-sub(pattern=firstChar, replacement=firstCharUpper, splitted[[i]][j]) #make the first letter upper-case
                changedNameOfVariable<-paste0(changedNameOfVariable, splitted[[i]][j])
            }
        }
        

        changedNameOfVariable<-sub(pattern="BodyBody", replacement="Body", changedNameOfVariable) #remove extra word "Body"
        changedNameOfVariable<-str_replace_all(changedNameOfVariable, pattern="\\(\\)", replacement="") #remove "()"
        newVector<-c(newVector, changedNameOfVariable)
    }
    
    
    return(newVector)
}
colnames(extractedMeanStdDataset)<-makeVariableNamesPretty(extraSymbol="-", colnames(extractedMeanStdDataset))




#STEP5: create independent data set with the average of each variable for each activity and each subject
calculateAverageByActivityAndSubject<-function(dataset) {
    dataset<-tbl_df(dataset)
    newDataset<-select(dataset, 1:ncol(dataset))
    newDataset<-group_by(newDataset, activityLabel, subject)
    newDataset<-summarise_each(newDataset, funs(mean))
        
    return(newDataset)
}
resultDataset<-calculateAverageByActivityAndSubject(extractedMeanStdDataset)
print(resultDataset)
write.table(resultDataset, file="result_dataset.txt", row.names=F)




#auxiliary step - helps to place old names and new names of variables to CodeBook
newColnames<-colnames(extractedMeanStdDataset)
resultDatasetColnames<-colnames(resultDataset)
changedColnames<-cbind(newColnames=newColnames, resultDatasetColnames=resultDatasetColnames, oldColnames=oldColnames)
write.table(changedColnames, file="changed_colnames.txt")
