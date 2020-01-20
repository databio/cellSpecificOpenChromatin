# Cell type specific open chromatin signal matrix

## How to create:
### 1. Download signal tracks from ENCODE : /dataDownloadAndPreprocess
At ENCODE website apply criteria for file selection - hg19 / DNA accessibility / bigWig. Download *files.txt*. \
The first line contains the link to metadata connected to these files - download *metadata.tsv*.\
\
In RStudio run: \
```/dataDownloadAndPreprocess/filterMetadata.R```
\
The output of *filterMetadata.R* is *metadata_cells.tsv*, and *downloadCells.txt*. \
\
From terminal: \
```mkdir primaryCells ``` \
```mv downloadCells.txt primaryCells``` \
```cd primaryCells ``` \
```xargs -L 1 curl -O -L < downloadCells.txt ```

### 2. Organize bigWig files into cell-specific subdirectories and merge  : /dataDownloadAndPreprocess


