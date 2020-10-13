rm(list = ls())
library(tidyverse)

# list the file names in the folder
folderName = "" #!!!!!! give path to the folder with bigWig coverage values over MasterPeaks
fileNames = list.files(folderName)

# go through the files in a folder and put the mean and max columns
# into a table:
# 1st column is a peak name , columns = cell types, rows = individual sites
# meanTable  = table with mean0 values in the region
for (myFile in fileNames){
  myTable = read.delim(paste0(folderName,"/", myFile), header = F, as.is = T)
  
  # select columns with peak name and mean0
  myMean = myTable %>% 
    select(V1, V5) %>% 
    rename("peak" = V1)
  
  if (myFile == fileNames[1]){
    # extract the cell type from the file name
    cellName = substr(myFile, start = 1, stop = (str_length(myFile) - 4))
    
    # rename the average  columns by the cell type
    meanTable = myMean %>% 
      rename(!!cellName := V5)
    
  } else {
    # extract the cell type from the file name
    cellName = substr(myFile, start = 1, stop = (str_length(myFile) - 4))
    
    # rename the average columns by the cell type
    meanTable = meanTable %>% 
      left_join(myMean, by = "peak") %>% 
      rename(!!cellName := V5)
  }
}

# name the rows with the peak column a remove the peak column
finalMeanTable = meanTable
rownames(finalMeanTable) = meanTable$peak  
finalMeanTable = finalMeanTable[,-1]

write.table(finalMeanTable, "meanCoverageMatrix.txt",
            quote = F, sep = "\t")



