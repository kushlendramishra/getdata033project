# getdata033project
Project submission for Coursera course "Getting and Cleaning Data" 


This submission has one R script (run_analysis.R) that analyzes and summarizes the UCI Human Activity recognition project data. The script was tested on R version 3.2.2 on a Windows 7 x86_64 mingw32 system. 

The script expects the UCI Human Activity recognition data directory (directory name 'UCI HAR Dataset') to be present in the same directory the script is in. When run, the script first creates a new directory 'combined' in the 'UCI HAR Dataset' directory, and writes the merged data from the traing and test directory. The directory structure in the 'combined' directory is the same as in the 'training and test directories. The original training and test files are in txt format, but the 'combined' data files are written in the csv format as they are easier to work with.

The combined data files are then read in again and the data is cleaned up. The script analyzes the time domain body acceleration variables and angular velocity variables. The twelve columns representing these variables are selected from the original data-set and given meaningful names. Then, the activity labels are changed from the original numerical to more discriptive text labels. Finally, all the variables are averaged for each subject-activity combination and the results are written out in the 'cleanData.txt' file. The file is written out in the script directory itself.

To run the 'run_analysis.R' script, set the working directory to the directory where the script is, and ensure the that the 'UCI HAR Dataset' data directory is available in the directory. Once the data directory is available, the script can be directly sourced in the R session.

For a complete description of the variables in the cleanData.txt file, refer to the CodeBook.md file.
