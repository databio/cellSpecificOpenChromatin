library(data.table)
library(tidyverse)
library(preprocessCore)

# load raw matrices
rawMatrix = fread("..") # !!! replace .. with file name of the matrix with raw count values

# melt the matrices so they can be easily utilized by other functions
meltMatrix = rawMatrix %>% 
  gather(key = "cellType", value = "signal", colnames(rawMatrix)[-1])


# ------ 0-1 normalization of values falling into a given percentile (0.95) --------------
# calculate percentiles 0.9 - 0.99 (for testing the right value to cap)
percentilesMatrix = meltMatrix %>% 
  group_by(cellType) %>% 
  summarise(percentile = quantile(signal, seq(0.90, 0.99, 0.01))) %>% 
  ungroup() %>% 
  mutate(label = paste0("p_", rep(seq(0.90, 0.99, 0.01), ncol(rawMatrix)-1)))

# select values for 99th percentile and do cutoff - 
# all values above 99th percentile will be set to 1
percentile99 = percentilesMatrix %>% 
  filter(label == "p_0.99") %>% 
  select(cellType, percentile) %>% 
  mutate(percentile = unname(percentile))


# -- find which values are same or largaer like the 99th percentile
zeroOne = meltMatrix %>% 
  right_join(percentile99, by = "cellType") %>% 
  mutate(pLabel = ifelse(signal >= percentile, "higher", "lower"))

# --- and set them to 1
higherMatrix = zeroOne %>% 
  filter(pLabel == "higher") %>% 
  mutate(normalizedSignal = 1)

# define function for 0-1 normalization
norm_zeroOne <- function(x){
  return((x-min(x)) / (max(x)-min(x)))
}

# normalize values below 99th percentile to fall on 0-1 interval
lowerMatrix = zeroOne %>% 
  filter(pLabel == "lower") %>% 
  group_by(cellType) %>% 
  mutate(normalizedSignal = norm_zeroOne(signal)) %>% 
  ungroup()


# merge the two tables - above and below 99th percentile into a final table
normalizedZeroOne = rbind(lowerMatrix, higherMatrix) %>% 
  select(V1, cellType, normalizedSignal)%>% 
  spread(cellType, normalizedSignal)

# -------- quantile normalization  after 0-1 normalization ---------
# do quantile normalization
quantZeroOneNormalized = as.data.frame(normalize.quantiles(as.matrix(normalizedZeroOne[,-1])))
quantZeroOneNormalized = cbind(normalizedZeroOne[,1], quantZeroOneNormalized)
colnames(quantZeroOneNormalized) = colnames(normalizedZeroOne)

# round variables to 4 digits and export
RoundQuantZeroOneNormalized = quantZeroOneNormalized %>% 
  mutate_if(is.numeric, round, 4)

# export
write.table(RoundQuantZeroOneNormalized,
            file = "meanCoverage_percentile99_01_quantNormalized_round4d.txt",
            quote = F,sep = "\t", row.names = F)









