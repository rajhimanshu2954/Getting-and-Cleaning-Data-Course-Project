#install.packages("dplyr")
#install.packages("reshape2")

setwd("C:/Users/XXXXXXXX/Desktop/Coursera/Coursera/UCI HAR Dataset")
if(!file.exists("./data")){dir.create("./data")}
url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,"data/zipfile.zip")
unzip(zipfile = "data/zipfile.zip", exdir = "./data")

## Merges the training and the test sets to create one data set and Uses descriptive activity names to name the activities in the data set

activityLabels <- read.table("data/UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

featurenames<- read.table(file="data/UCI HAR Dataset/features.txt", header = F)
featurenames<- t(featurenames)
testdata <-    read.table(file = "data/UCI HAR Dataset/test/X_test.txt", header = F, stringsAsFactors = F)
testactivity<- read.table(file = "data/UCI HAR Dataset/test/y_test.txt", header = F, stringsAsFactors = F)
testsubject<-  read.table(file = "data/UCI HAR Dataset/test/subject_test.txt", header = F, stringsAsFactors = F)
library(dplyr)
testactivity<- inner_join(testactivity, activityLabels, by="V1")
newtestdata<- cbind(testsubject, testactivity[,2],testdata)
colnames(newtestdata)<- c("subject","activity",featurenames[2,])

traindata<- read.table(file = "data/UCI HAR Dataset/train/X_train.txt", header = F, stringsAsFactors = F)
trainactivity<- read.table(file = "data/UCI HAR Dataset/train/y_train.txt", header = F, stringsAsFactors = F)
trainsubject<-  read.table(file = "data/UCI HAR Dataset/train/subject_train.txt", header = F, stringsAsFactors = F)
trainactivity<- inner_join(trainactivity, activityLabels, by="V1")
newtraindata<- cbind(trainsubject, trainactivity[,2],traindata)
colnames(newtraindata)<- c("subject","activity",featurenames[2,])

##Merging Data
completedata<- rbind(newtraindata, newtestdata)
head(completedata)
nrow(completedata)
#10299
ncol(completedata)
#563

## Extracts only the measurements on the mean and standard deviation for each measurement
selectedfeature<- grep(".*mean.*|.*std.*", featurenames[2,])
selectedfeaturenames<- featurenames[2,selectedfeature]
featureswanted<- completedata[,selectedfeaturenames]
head(featureswanted)
nrow(featureswanted)
#10299
ncol(featureswanted)
#79

##From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each 
##activity and each subject

##converting subject and activity in factors
completedata$subject<- as.factor(completedata$subject)
completedata$activity<- as.factor(completedata$activity)
library(reshape2)
completdata_melt<- melt(completedata, id = c("subject", "activity"))
completdata_mean<- dcast(completdata_melt, subject+activity ~ variable, mean)

## Writing Data in tidy.txt file
write.table(completdata_mean, "tidy.txt", row.names = FALSE, quote = FALSE)
head(completdata_mean)
