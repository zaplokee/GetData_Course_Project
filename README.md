#README



##Course Project for [https://www.coursera.org/course/getdata](https://www.coursera.org/course/getdata)
Course project includes the following files:
* README.md: explains the purpose of each file from the Course Project  

* CodeBook.md: provides information about the variables

* run_analysis.R: uses packages "stringr", "dplyr", takes data from URL, which specified in the task, unzip files to the current working directory and performs 5 steps listed in the task.



###Main steps from run_analysis.R
* Download and unzip data for analysis to the current working directory.
* Read data from "features.txt".
* Read data from "activity_labels.txt", create a vector with lower-case names of activities (prepare for STEP3 from task).
* Create function (*combineSubjectXsetActivityKind*) which helps to do the same work for test and training sets:
  + Read "y_test.txt" (or "y_train.txt") and replace numbers with names of activities (STEP3 from the task);
  + Read data from "X_test.txt" (or "X_train.txt");
  + Combine data from "X_test.txt" and "y_test.txt" (or "X_train.txt" and "y_train.txt") by column;
  + Add column with kind of observation ("test" or "train");
  + Read "subject_test.txt" (or "subject_train.txt"), add column with  subject identifier;
* Make two datasets for test and train data using the function *combineSubjectXsetActivityKind*. Merge them together (STEP1 from the task)
* Change column names for columns with variables from "X_test.txt" or "X_train.txt", replace default names with names from features.txt.
* Create new dataset (extractedMeanStdDataset) by extracting only the measurements on the mean and standard deviation (STEP2 from the task).
* Create a function (*makeVariableNamesPretty*) which helps to make descriptive variable names (STEP4 from the task).
* Create function (*calculateAverageByActivityAndSubject*) which takes some dataset, groups data by activity label and subject, then calculate mean() for each variable.
* Create dataset which STEP5 from the task requires (*resultDataset*). Print *resultDataset* to console. Create file (result_dataset.txt).
* Create file "changed_colnames.txt" which shows, how names of variables from "features.txt" and from *extractedMeanStdDataset*, *resultDataset* match.



##Files that appears after executing run_analysis.R
* If directory "UCI HAR Dataset" didn't exist, run_analysis.R will download "data_for_course_project.zip" and unzip it, so the folder "UCI HAR Dataset" will be created.
* "changed_colnames.txt" - this is auxiliary file, that shows how names of variables from "features.txt" and from *extractedMeanStdDataset*, *resultDataset* match.
* "result_dataset.txt" - file with resultDataset which course task requires to submit.



##Information about initial experiments
Additional information about initial experiments can be found in the directory, which is created after run_analysis.R executed: "UCI HAR Dataset", in files "README.txt" and "features_info.txt". 

