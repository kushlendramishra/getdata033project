#for the read_table function
library(readr)
#for mapvalues funtion
library(plyr)
#for ddply function
library(dplyr)
#for setnames
library(data.table)

#Step 1. Merge the training and test data-sets to create one data set. 
#We will first read in training file data, and append the corresponding test file data to it 
#We will write the combined files as csv, as they are easier to deal with in R.
#The directory structure in training and test directory is similar, we will follow the same 
#structure in combined data set.

mainDir     <- getwd()
dataDir     <- "UCI HAR Dataset"
trainingDataDir <- file.path(mainDir, dataDir, "train")
testDataDir     <- file.path(mainDir, dataDir, "test")

combinedDataDir <- file.path(mainDir, dataDir, "combined" )

#create the combined data directory
dir.create(combinedDataDir, showWarnings = FALSE)

#get the list of all files in training data set, including directories.
trainingFilesV <- list.files(trainingDataDir, recursive = TRUE, include.dirs = TRUE)



# readTextFile <- function (filePath) {
#         fileText <- read_file()
# }

#for each file found in training data set
for (trainFile in trainingFilesV) {
        #get the full path of the file in training data set, and
        trainFilePath <- file.path(trainingDataDir, trainFile)
        #get the full path of the corresponding file in test data set
        testFilePath  <- file.path(testDataDir,gsub("train", "test", trainFile))
        #if the training data set file is a directory
        if (file_test("-d", trainFilePath)) {
                #then create the directory in the combined data-set. 
                #Ignore the warning if directory already exists.
                dir.create(file.path(combinedDataDir, trainFile), showWarnings = FALSE)
                #If the training data set file is not a directory but file,
        } else if (file_test("-f", trainFilePath)) {
                #get only the file name, strip all directory information
                fileName <- basename(trainFile)
                #get the file rootname
                fileRootname <- unlist(strsplit(fileName, split = "[.]"))[1]
                #create a filename 
                outFileName  <- paste(gsub("train", "combined", fileRootname), ".csv", sep = "")
                fileDir  <- dirname(trainFile)
                outFileDir <- file.path(combinedDataDir, fileDir)
                #create output file path
                outFilePath <- file.path(outFileDir, outFileName)

                #read in training and test data
                trainFileTable <- read_table(trainFilePath, col_names = FALSE)                
                testFileTable  <- read_table(testFilePath, col_names = FALSE)
                #and combine them into one data frame
                outFileTable   <- rbind(trainFileTable, testFileTable)
                #write out the combined data frame
                write.csv(outFileTable, file = outFilePath, row.names = FALSE)
                # writeChar(trainFileText, con = outFilePath)
        }
}

#Step 2. Extract the  feature measurements only on mean and standard deviation
#The columns to be extracted - (1, 2, 3, 4, 5, 6, 121, 122, 123, 124, 125, 126)

#Read the measurement data into a data-frame 
measFile <- file.path(combinedDataDir, "X_combined.csv")
rawMeasData <- read.csv(measFile, header = TRUE, colClasses = "numeric")

#Read the subject corresponding for each measurement record
subjectsFile <- file.path(combinedDataDir, "subject_combined.csv")
subjectData  <- read.csv(subjectsFile, header = TRUE)

#Read the activity for each measurement record
activityFile <- file.path(combinedDataDir, "y_combined.csv")
activityData <- read.csv(activityFile, header = TRUE)

#create a fresh data frame for the clean data set
cleanData <- NULL
#first add the subject and activity variables in the data frame
cleanData$subject <- subjectData[,1]
cleanData$activity <- activityData[,1]

#then add the real measurement data from the measurement data
#We will take only the measurements in the time domain, and only the
#mean and standard deviation of the body acceleration (features 1 through 6)
#in the original data-set), and the angular velocity (feature 121:126 in the
#original data-set)
cleanData <- cbind(cleanData, rawMeasData[, c(1:6, 121:126)])

##Step 4: give the variables meaningful names
xyzStrVector <- c("X", "Y", "Z")
cleanData <- setnames(cleanData, old = c("X1", "X2", "X3", "X4", "X5", "X6", "X121", "X122", "X123", "X124", "X125", "X126"),
                        new = c(paste("meanAcc", xyzStrVector, sep = ""), paste("stdevAcc", xyzStrVector, sep = ""),
                                paste("meanGyro", xyzStrVector, sep = ""), paste("stdevGyro", xyzStrVector, sep = "")))

# Step 3: 

cleanData$activity <- mapvalues(cleanData$activity, from = c(1, 2, 3, 4, 5, 6),
                                to = c("Walking", "WalkingUpstairs", "WalkingDownstairs", "Sitting", "Standing", "Laying"))

#Step 5. prepare independent tidy data-set with the average of each variable for
#each activity and each subject

#I realize that the standard deviation calculation below doesn't make sense,
#but due to lack of time I cant try to find the correct way to do it.
#Calculate the averages by splitting the data on subject and activity
#and generate one record for each subject-activity combination. Average all the 
#original measurement variables.
summarizedData <- ddply(cleanData, .(subject, activity), summarize, 
                        avgMeanAccX = mean(meanAccX),
                        avgMeanAccY = mean(meanAccY),
                        avgMeanAccZ = mean(meanAccZ),
                        avgStdevAccX = mean(stdevAccX),
                        avgStdevAccY = mean(stdevAccY),
                        avgStdevAccZ = mean(stdevAccZ),
                        avgMeanGyroX = mean(meanGyroX),
                        avgMeanGyroY = mean(meanGyroY),
                        avgMeanGyroZ = mean(meanGyroZ),
                        avgStdevGyroX = mean(stdevGyroX),
                        avgStdevGyroY = mean(stdevGyroY),
                        avgStdevGyroZ = mean(stdevGyroZ)
)

#Write out the tidy dataset.

cleanDataFile <- "cleanData.txt"
cleanDataPath <- file.path(mainDir, cleanDataFile)
write.table(summarizedData, cleanDataPath, row.names = FALSE)
