# Cell type specific open chromatin signal matrix

### Prerequisities
Some of UCSC tools https://genome.ucsc.edu/goldenPath/help/bigWig.html:
- bigWigToBedGraph


## How to create open chromatin signal matrix:

## 1.-4. in */dataDownloadAndPreprocess* folder
Set up path to the folder */dataDownloadAndPreprocess* in your *.bash_profile*.
### 1. Download signal tracks from ENCODE 
At ENCODE website apply criteria for file selection - hg19 / DNA accessibility / bigWig. Download *files.txt*. \
The first line in *files.txt* contains the link to metadata connected to these files - download *metadata.tsv*.\
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

### 2. Organize bigWig files into cell-specific subdirectories and merge 

From RStudio run script: 
```organizeFilesIntoCellFolders.R```.
\
The script contains function *moveBigWigs(cellMetadata, mainDir)*, which requires 2 inputs: 
- name of the metadata file containing file name - cell type information (*metadata_cells.tsv*) 
- name of a folder conatining downloaded bigWig files (*/primary cells*)

Within the directory provided to *moveBigWigs* a cell specific subdirectories are created and the bigWig files connected to the given cell type are moved into the subdirectory. 
\
Followin step merges bigWig files coming from the same cell type. The output in form of bedGraph files is moved to a directory specified by used.

``` 
mkdir primaryCells_bedGraph
cd primaryCells
mergeBigWig.sh
cd ..
```
Following question pops out:
```
What is the full path to the folder where outputs should be stored?
path_to_dataDownloadAndProcess/primaryCells_bedGraph
```
If a folder contains a single bigWig file an error is generated In these folders run ```bigWigToBedGraph``` manually and move to a corresponding folder with all the other merged bedGraphs. 
### 3. Remove ENCODE blacklisted sites and other problematic regions
The files contain problematic regions. Some of them were defined by ENCODE - */dataDownloadAndPreprocess/blacklistedSites/ENCODE_blacklisted.bed* and some after visual inspection of bigWig files: */dataDownloadAndPreprocess/blacklistedSites/additional_blackList.bed*. 
These are combined into */dataDownloadAndPreprocess/blacklistedSites/combined_Blacklist.bed* by running following from the terminal:
```
cd blacklistedSites
cat *.bed | sort -k1,1 -k2,2n > combined_Blacklist.bed
cd ..
```
The combined blacklisted sites are then remove from the bedGraph files along with following chromosomes: chrY, chrM, chrUn, random, hap. The output is again a bedGraph file with suffix *_blRemoved*.

```
cd primaryCells_bedGraph
rmBlacklistSitesFrom_bedGraph.sh
```
### 4. Normalize the signal to 0-1 range
From within the folder with cleaned bedGraph files run following script to normalize the signal to fall within 0-1 range. The unnormalized files are removed and the normalized bedGraph files are converted to bigWig files.
```
normalize_bedGraph01.sh
```
When following question pops up, give a full path to the file containing chromosome sizes.
```
What is the full path to the file with chromosome sizes?
path_to_dataDownloadAndProcess/hg19chrom.sizes
```
