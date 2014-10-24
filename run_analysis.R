library(stringr)
library(dplyr)

#download data for analysis
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile="data_for_course_project.zip")
unzip("data_for_course_project.zip")
setwd("./UCI HAR Dataset")
parent_directory<-getwd()




#data from features.txt will be names of the columns for variables
readed_features.txt<-read.table("features.txt", sep=" ", col.names=c("number_of_feature", "feature"), colClasses="character")
features_names_561<-readed_features.txt$feature

features_names_561<-sub(pattern="BodyBody", replacement="Body", features_names_561) #remove extra word "Body"
features_names_561<-str_replace_all(features_names_561, pattern="-", replacement="_") #replace "-" with "_"




#read data from activity_labels.txt
readed_activity_labels.txt<-read.table("activity_labels.txt", sep=" ", col.names=c("number_of_activity", "activity_label"), colClasses="character")
activity_labels<-readed_activity_labels.txt$activity_label
activity_labels<-tolower(activity_labels) #change upper-case letters to lower-case




#create function for repeating similar steps for different kinds of observations: "train" and "test"
combine_columns_for_subject_561features_labels_kind<-function(kind_of_observation) {
    setwd(paste0(parent_directory, "/", kind_of_observation))
    name_of_X_set<-paste0("X_", kind_of_observation)
    name_of_X_set.txt<-paste0(name_of_X_set, ".txt")
    name_of_y_set<-paste0("y_", kind_of_observation)
    name_of_y_set.txt<-paste0(name_of_y_set, ".txt")
    name_of_subject_set.txt<-paste0("subject_", kind_of_observation, ".txt")
    
    readed_y_set.txt<-read.table(name_of_y_set.txt, sep="\n", col.names=name_of_y_set, colClasses="integer")
    y_set<-as.factor(readed_y_set.txt[,1]) #character vector with class label of activity
    levels(y_set)<-activity_labels #STEP3: descriptive activity names

    readed_X_set.txt<-read.table(name_of_X_set.txt, colClasses="numeric")

    X_set_with_y_set<-cbind(readed_X_set.txt, activity_label=y_set) #combine X_set and y_set
    
    vect_kind_of_observation<-rep(kind_of_observation, length(y_set))    
    X_set_with_y_set_with_kind_of_observation<-cbind(X_set_with_y_set, kind_of_observation=vect_kind_of_observation) #a part of dataset with observations for 561 variables, labels of activity and specified kind of observation (test or train)
    
    readed_subject_set<-read.table(name_of_subject_set.txt, sep="\n", col.names="subject", colClasses="character")    
    function_result<-cbind(subject=readed_subject_set$subject, X_set_with_y_set_with_kind_of_observation)
    
    
    return(function_result)
}




#create additional column for number of observation
test_dataset<-combine_columns_for_subject_561features_labels_kind("test")
test_rows<-seq(from=1, to=nrow(test_dataset), by=1)
test_dataset<-cbind(observation_number=test_rows, test_dataset)

train_dataset<-combine_columns_for_subject_561features_labels_kind("train")
train_rows<-seq(from=nrow(test_dataset)+1, to=nrow(test_dataset)+nrow(train_dataset), by=1)
train_dataset<-cbind(observation_number=train_rows, train_dataset)




#STEP1: merge test and train datasets
merged_dataset<-merge(test_dataset, train_dataset, all=T)




#STEP4: use descriptive variable names
colnames_for_merged_dataset<-colnames(merged_dataset)
for (i in 3:563) {
    colnames_for_merged_dataset[i]<-features_names_561[i-2]
}
colnames(merged_dataset)<-colnames_for_merged_dataset




#STEP2: extracting only columns with mean() and std() to extracted_mean_std_variables_dataset 
mean_in_colnames<-str_detect(colnames(merged_dataset), "(.+)_mean\\(\\)(.+)")
std_in_colnames<-str_detect(colnames(merged_dataset), "(.+)_std\\(\\)(.+)")
logical_condition<-mean_in_colnames | std_in_colnames
logical_condition[c(1,2,564,565)]<-TRUE #include additional columns with observation number, subject identifier, activity label, kind of observation ("test" or "train")
extracted_mean_std_variables_dataset<-merged_dataset[1:nrow(merged_dataset),][, logical_condition] #data frame with only mean and std variables for observations




#STEP5: create independent data set with the average of each variable for each activity and each subject
calculate_average_by_activity_and_subject<-function(dataset) {
    dataset<-tbl_df(dataset)
    grouped_dataset_with_average_values<-select(dataset, -1)
    grouped_dataset_with_average_values<-select(grouped_dataset_with_average_values, c(50, 1, 51, 2:49))
    grouped_dataset_with_average_values<-group_by(grouped_dataset_with_average_values, activity_label, subject, add=F)
    grouped_dataset_with_average_values<-summarise_each(grouped_dataset_with_average_values, funs(mean), -3)
        
    return(grouped_dataset_with_average_values)
}
result_dataset<-calculate_average_by_activity_and_subject(extracted_mean_std_variables_dataset)
print(result_dataset)
