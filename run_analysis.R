#install.packages("dplyr")
#install.packages("reshape2")

setwd("C:/Users/XXXXXXX/Desktop/Coursera/Coursera/UCI HAR Dataset")
if(!file.exists("./data")){dir.create("./data")}
url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,"data/zipfile.zip")
unzip(zipfile = "data/zipfile.zip", exdir = "./data")

##Reading activity and feature info
activityLabels <- read.table("data/UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
featurenames<- read.table(file="data/UCI HAR Dataset/features.txt", header = F)
featurenames<- t(featurenames)

## Extracts only the measurements on the mean and standard deviation for each measurement
selectedfeature<- grep(".*mean.*|.*std.*", featurenames[2,])
selectedfeaturenames<- featurenames[2,selectedfeature]
selectedfeaturenames = gsub('-mean', 'Mean', selectedfeaturenames)
selectedfeaturenames = gsub('-std', 'Std', selectedfeaturenames)
selectedfeaturenames <- gsub('[-()]', '', selectedfeaturenames)

## Merges the training and the test sets to create one data set and Uses descriptive activity names to name the activities in the data set
library(dplyr)
testdata <-    read.table(file = "data/UCI HAR Dataset/test/X_test.txt", header = F, stringsAsFactors = F)[selectedfeature]
testactivity<- read.table(file = "data/UCI HAR Dataset/test/y_test.txt", header = F, stringsAsFactors = F)
testsubject<-  read.table(file = "data/UCI HAR Dataset/test/subject_test.txt", header = F, stringsAsFactors = F)
testactivity<- inner_join(testactivity, activityLabels, by="V1")
newtestdata<- cbind(testsubject, testactivity[,2],testdata)
colnames(newtestdata)<- c("subject","activity",selectedfeaturenames)

traindata<- read.table(file = "data/UCI HAR Dataset/train/X_train.txt", header = F, stringsAsFactors = F)[selectedfeature]
trainactivity<- read.table(file = "data/UCI HAR Dataset/train/y_train.txt", header = F, stringsAsFactors = F)
trainsubject<-  read.table(file = "data/UCI HAR Dataset/train/subject_train.txt", header = F, stringsAsFactors = F)
trainactivity<- inner_join(trainactivity, activityLabels, by="V1")
newtraindata<- cbind(trainsubject, trainactivity[,2],traindata)
colnames(newtraindata)<- c("subject","activity",selectedfeaturenames)

##Merging Data
completedata<- rbind(newtraindata, newtestdata)
head(completedata)
nrow(completedata)
#10299
ncol(completedata)

##converting subject and activity in factors
completedata$subject<- as.factor(completedata$subject)
completedata$activity<- as.factor(completedata$activity)

##From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each 
##activity and each subject

library(reshape2)
completdata_melt<- melt(completedata, id = c("subject", "activity"))
completdata_mean<- dcast(completdata_melt, subject + activity ~ variable, mean)

## Writing Data in tidy.txt file
write.table(completdata_mean, "tidy.txt", row.names = FALSE, quote = FALSE)
