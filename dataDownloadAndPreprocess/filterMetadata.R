rm(list = ls())
# make a new text file to download only files that follow given criteria
library(tidyverse)

# upload metadata
metadataRaw = read.delim("metadata.tsv")

# select only hg19 samples and read-depth normalized signal
useMetadata = metadataRaw %>% 
  filter(Assembly == "hg19") %>% 
  filter(Output.type == "read-depth normalized signal")  

# look how big would those files be
sum(useMetadata$Size)
# well really big

# separate the metadata into tissue, cell line, and primary cells
cellLines = useMetadata %>% 
  filter(Biosample.type == "cell line")

cells = useMetadata %>% 
  filter(Biosample.type == "primary cell")

tissue = useMetadata %>% 
  filter(Biosample.type == "tissue")

# I think that I won't use tissue - it's not homogeneous

# make file for download - for primary cells and for cell lines
cellLineFiles = as.data.frame(cellLines$File.download.URL)
write.table(cellLineFiles, "downloadCellLines.txt", row.names = F, col.names = F, quote = F)
write.table(cellLines, "metadata_cellLines.tsv", quote = F, row.names = F, sep = "\t")


cellFiles = as.data.frame(cells$File.download.URL)
write.table(cellFiles, "downloadCells.txt", row.names = F, col.names = F, quote = F)
write.table(cells, "metadata_cells.tsv", quote = F, row.names = F, sep = "\t")



tissueFiles = as.data.frame(tissue$File.download.URL)
write.table(tissueFiles, "downloadTissues.txt", row.names = F, col.names = F, quote = F)
write.table(tissue, "metadata_tissues.tsv", quote = F, row.names = F, sep = "\t")


