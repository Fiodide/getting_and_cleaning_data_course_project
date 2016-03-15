
#============================================================================== 
# step 0 : download data
#==============================================================================

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, mode='wb')
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


#============================================================================== 
# step 1 : read data
#==============================================================================

library(data.table)
library(dplyr)
library(tidyr)

X_train <- fread("./UCI HAR Dataset/train/X_train.txt")
y_train <- fread("./UCI HAR Dataset/train/y_train.txt",col.names = "activity")
subject_train <- fread("./UCI HAR Dataset/train/subject_train.txt",col.names = "subject")
x_test <- fread("./UCI HAR Dataset/test/x_test.txt")
y_test <- fread("./UCI HAR Dataset/test/y_test.txt",col.names = "activity")
subject_test <- fread("./UCI HAR Dataset/test/subject_test.txt",col.names = "subject")
features <- fread("./UCI HAR Dataset/features.txt")
activity_labels <- fread("./UCI HAR Dataset/activity_labels.txt")

#==============================================================================
# step2 : merge data
#==============================================================================

train <- cbind(X_train,subject_train,y_train)
test <- cbind(x_test,subject_test,y_test)
merged_data <- rbind(train,test)

#==============================================================================
# step3 : Extract measurement on the mean, standard variation for
#         each measurement
#==============================================================================
#==============================================================================
# step4 : Uses descriptive activity names to name the activities in the data set
#         & Appropriately labels the data set with descriptive variable names.
#==============================================================================

names(merged_data)[-(562:563)] <- features$V2
n_list <-  c(as.numeric(grep("[M|m]ean|std",features$V2)),562:563)
merged_data <- select(merged_data,n_list)
merged_data$activity <- factor(merged_data$activity,level=activity_labels$V1,labels=activity_labels$V2)
#==============================================================================
# step 5 : From the data set in step 4, creates a second, independent tidy data 
# set with the average of each variable for each activity and each subject.
#==============================================================================

tidy_data <- gather(merged_data,key=features,"mean_value",-subject,-activity)
tidy_data <- dcast(tidy_data,subject + activity ~ features,mean)

write.table(tidy_data,"./data/tidy_data.txt",row.names = FALSE,quote=FALSE)