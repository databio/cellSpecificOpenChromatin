rm(list = ls())

library(tidyverse)
library(preprocessCore)

# upload openness matrix
matrix_hg19 = read.delim("..")

colnames(matrix_hg19) = gsub('\\.', '-', colnames(matrix_hg19))

# ------ do quantile normalization -------
quantNormalized_hg19 = as.data.frame(normalize.quantiles(as.matrix(matrix_hg19)))

colnames(quantNormalized_hg19) = colnames(matrix_hg19)

rownames(quantNormalized_hg19) = rownames(matrix_hg19)


# round the values to 4 decimal places and write the final document
round_quantNormalized_hg19 = round(quantNormalized_hg19, digits = 4)
write.table(round_quantNormalized_hg19, "openSignalMatrix_hg19_quantileNormalized_round4.txt",
            quote = F, sep = "\t")
