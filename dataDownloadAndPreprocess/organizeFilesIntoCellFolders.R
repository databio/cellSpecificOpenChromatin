rm(list = ls())
library(tidyverse)
library(filesstrings)
## the function takes as an input:
#   -cellMetadata : metadata containing file name-cell type information (the one generated
#                   from ENCODE and filtered by filterMetadata.R)
#   -mainDir : path to a directory, where new subdirectiries will be created (one for each cell type),
#              into which individual bigWig files are moved

# set up a pathway, where cell specific subdirectories will be 
# created and into which the cell specific bigWig files will be moved
moveToDir = "/ENCODE_bigWigs/primaryCells"

# upload the metadata associated to primary cells
cellMetadata = read.delim("metadata_cells.tsv")

moveBigWigs = function(cellMetadata, mainDir){
  # select the columns with file ID and rename the cell column so it can be used as a folder name
  groupedMetadata = cellMetadata %>% 
    select(File.accession, Biosample.term.name) %>% 
    rename(ID = File.accession) %>% 
    mutate_if(is.factor, as.character) %>% 
    rename(cellTypeOrig = Biosample.term.name) %>% 
    mutate(cellType = str_replace_all(cellTypeOrig, pattern = " ", replacement = "_")) %>% 
    mutate(cellType = str_replace_all(cellType, pattern =  ",", replacement = "_xx")) 
  
  # get the cellType names 
  allCellTypes = levels(factor(groupedMetadata$cellType))
  
  # navigate to the directory, where files are currently and where folders should be made
  for(subDir in allCellTypes){
    
    # if a folder doesn't exist, create it
    ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
    
    # filter out the file IDs belonging to a given cell type and give it extension
    filesToMove = groupedMetadata %>% 
      filter(cellType == subDir)
    IDs = paste0(filesToMove$ID, ".bigWig")
    
    # move the files from the current directory to a cell subdirectory
    for(fileName in IDs){
      
      fullName = paste(mainDir, fileName, sep = "/")
      destination = paste(mainDir, subDir, sep = "/")
      
      file.move(fullName, destination)
    }
  }
}

# run function with the meatada containing cell type - 
moveBigWigs(cellMetadata, mainDir = moveToDir)

