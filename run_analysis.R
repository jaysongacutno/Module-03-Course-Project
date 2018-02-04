setwd("C:/Users/jayson/Desktop/Module 3")

library(data.table)
library(dplyr)

fpath <- getwd()
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
file <- 'Dataset.zip'
if(!file.exists(file)) {download.file(url, file)}

dset <- 'UCI HAR Dataset'
if(!file.exists(dset)) {unzip(file)}
 
SubjectTrain <- data.table(read.table(file.path(fpath, dset, 'train', 'subject_train.txt')))
SubjectTest <- data.table(read.table(file.path(fpath, dset, 'test', 'subject_test.txt')))
tableSubject <- rbind(SubjectTrain, SubjectTest)
names(tableSubject) <- c('Subject')
remove(SubjectTrain,SubjectTest)
 
ActivTrain <- data.table(read.table(file.path(fpath, dset, 'train','Y_train.txt')))
ActivTest <- data.table(read.table(file.path(fpath,dset,'test','Y_test.txt')))
tableActiv <- rbind(ActivTrain,ActivTest)
names(tableActiv) <- c('Activity')
remove(ActivTrain,ActivTest)

tableSubject <- cbind(tableSubject, tableActiv)
remove(tableActiv)
 
tableTrain <- data.table(read.table(file.path(fpath,dset,'train','X_train.txt')))
tableTest <- data.table(read.table(file.path(fpath,dset,'test','X_test.txt')))
dTable <- rbind(tableTrain,tableTest)
remove(tableTrain, tableTest)
 
dTable <- cbind(tableSubject,dTable)
setkey(dTable,Subject,Activity)
remove(tableSubject)
 
tFeature <- data.table(read.table(file.path(fpath,dset,'features.txt')))
names(tFeature) <- c('fNum','fName')
tFeature <- tFeature[grepl("mean\\(\\)|std\\(\\)",fName)]
tFeature$ftCode <- paste('V', tFeature$fNum, sep = "")
 
dTable <- dTable[,c(key(dTable), tFeature$ftCode),with=FALSE]
 
setnames(dTable, old=tFeature$ftCode, new=as.character(tFeature$fName))
 
ActiveNames <- data.table(read.table(file.path(fpath, dset, 'activity_labels.txt')))
names(ActiveNames) <- c('Activity','ActivityName')
dTable <- merge(dTable,ActiveNames,by='Activity')
remove(ActiveNames)
 
TidyData <- dTable %>% group_by(Subject, ActivityName) %>% summarise_all(funs(mean))
 
TidyData$Activity <- NULL
 
names(TidyData) <- gsub('^t', 'time', names(TidyData))
names(TidyData) <- gsub('^f', 'frequency', names(TidyData))
names(TidyData) <- gsub('Acc', 'Accelerometer', names(TidyData))
names(TidyData) <- gsub('Gyro','Gyroscope', names(TidyData))
names(TidyData) <- gsub('mean[(][)]','Mean',names(TidyData))
names(TidyData) <- gsub('std[(][)]','Std',names(TidyData))
names(TidyData) <- gsub('-','',names(TidyData))
 
write.table(TidyData, file.path(fpath, 'tidy.txt'), row.names=FALSE)
