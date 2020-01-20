# Cell type specific open chromatin signal matrix

## How to create:
### 1. Download signal tracks from ENCODE : /dataDownloadAndPreprocess
At ENCODE website apply criteria for file selection - hg19 / DNA accessibility / bigWig. Download *files.txt*. \
The first line contains the link to metadata connected to these files - download *metadata.tsv*.\
Run /dataDownloadAndPreprocess/filterMetadata.R \
The output of *filterMetadata.R* is *metadata_cells.tsv*, and *downloadCells.txt*. \
\
From terminal: \
``` xargs -L 1 curl -O -L < downloadCells.txt ```

