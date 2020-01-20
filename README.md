# Cell type specific open chromatin signal matrix

### Prerequisities
Some of UCSC tools https://genome.ucsc.edu/goldenPath/help/bigWig.html :
    -primaryCells_bedGraph

## How to create:
### 1. Download signal tracks from ENCODE : /dataDownloadAndPreprocess
At ENCODE website apply criteria for file selection - hg19 / DNA accessibility / bigWig. Download *files.txt*. \
The first line contains the link to metadata connected to these files - download *metadata.tsv*.\
\
In RStudio run:
```filterMetadata.R```.
\
The output of *filterMetadata.R* is *metadata_cells.tsv*, and *downloadCells.txt*. \
\
From terminal: 
```
mkdir primaryCells
mv downloadCells.txt primaryCells
cd primaryCells
xargs -L 1 curl -O -L < downloadCells.txt
cd ..
```

### 2. Organize bigWig files into cell-specific subdirectories and merge  : /dataDownloadAndPreprocess

From RStudio run script: 
```organizeFilesIntoCellFolders.R```.
\
The script contains function *moveBigWigs(cellMetadata, mainDir)*, which requires 2 inputs: 
- name of the metadata file containing file name - cell type information (*metadata_cells.tsv*) 
- name of a folder conatining downloaded bigWig files (*/primary cells*)

Within the directory provided to *moveBigWigs* a cell specific subdirectories are created and the bigWig files connected to the given cell type are moved into the subdirectory. 
\
Followin step merges bigWig files coming from the same cell type. The output in form of bedGraph files is moved to a user specified directory.

``` 
mkdir primaryCells_bedGraph
cd primaryCells
mergeBigWig.sh
```
Following question pops out:
```
What is the full path to the folder where outputs should be stored?
path_to_dataDownloadAndProcess/primaryCells_bedGraph
```
If a folder contains a single bigWig file an error is generated In these folders run ```bigWigToBedGraph``` manually
