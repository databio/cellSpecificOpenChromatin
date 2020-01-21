rm(list = ls())
library(tidyverse)

# script to filter out metadata for hg 19 only and for files that are not archived

metadata = read.delim("BED_files/metadata.tsv")

downloadMetadata = metadata %>% 
  filter(Assembly == "hg19") %>% 
  filter(File.Status != "archived") %>% 
  select(File.download.URL)

write.table(downloadMetadata, "BED_files/downloadBEDfiles.txt", row.names = F, col.names = F, quote = F)
