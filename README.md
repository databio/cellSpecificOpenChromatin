# Cell type specific open chromatin signal matrix

### Prerequisities
Some of UCSC tools https://genome.ucsc.edu/goldenPath/help/bigWig.html:
- bedGraphToBigWig
- bigWigMerge
- bigWigToBedGraph

- bedtools (http://quinlanlab.org/tutorials/bedtools/bedtools.html)\
R packages:
- tidyverse
- preprocessCore
- data.table


## How to create open chromatin signal matrix:

## 1.-7. in */dataDownloadAndPreprocess* folder
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
Following questions pop out:
```
What is the full path to the folder where outputs should be stored?
path_to_dataDownloadAndProcess/primaryCells_mergedBigWig

What is the full path to the file with chromosome sizes?
path_to_dataDownloadAndProcess/hg19chrom.sizes
```
If a folder contains a single bigWig file an error is generated In these folders run ```bigWigToBedGraph``` manually and move to a corresponding folder with all the other merged bedGraphs. 

### 3. Download cell specific open chromatin BED files 
At ENCODE website apply filtering criteia - DNA accessibility / hg19 / primary cell / bed narrowPeak. \
Same as with the bigWig files, download the text document with links for BED file download (*dataDownloadAndProcess/BED_files/files.txt*) and diwnload the metadata from the first line (*dataDownloadAndProcess/BED_files/metadata.tsv*). \
Run following script to select only trully hg19 BED files and have status *released*.
```
filterMetadata_BEDfiles.R
```
This script creates a new text file with filtered links: (*dataDownloadAndProcess/BED_files/downloadBEDfiles.txt*) \
To get the BEd files run following from terminal:
```
cd BED_files
xargs -L 1 curl -O -L < downloadBEDfiles.txt
```
### 4. Create a set of all possible open chromatin regions across cell types
To create a universe of oll possible chromatin accessible regions run following command from the directory with all the downloaded BED files:
```
cat *.bed | sort -k1,1 -k2,2n | bedtools merge -i stdin > MasterPeaks.bed
```
You can now remove all the downloaded BEd files and keep only the *MasterPeaks.bed*.
Create a 4th column in *MasterPeaks.bed* with names for individual peaks (e.g. chr_start_end) - otherwise and error will be generated in following step.
### 5. Assign cell specific signal values to the genomic regions defined in step 4
Place the *MasterPeaks.bed* file into a directory, where it will be the only BED file. \
From the folder with final normalised bigWig files run following script:
```
cellSpecificity_bigWigOverBed.sh
```
Following question pops out. Give the full path to the *folder* containing *MasterPeaks.bed* - example bellow.
```
What is the folder with your BED files?
dataDownloadAndProcess/BED_files
```
A new directory will be created within a folder with bigWig files - */MasterPeaks_coverage*. It contains coverage files for individual cell types in the predefined regions. The columns in the TAB files are following:
- *name* - name field from bed, which should be unique (the 4th column in BED file)
- *size* - size of bed (sum of exon sizes
- *covered* - # bases within exons covered by bigWig
- *sum* - sum of values over all bases covered
- *mean0* - average over bases with non-covered bases counting as zeroes
- *mean* - average over just covered bases
- *min*  - minimum observed in the area
- *max*  - maximum observed in the area

### 6. Merge individual signal tracks into matrix
Run following script, where you must first set a path to the folder with coverage files (the TAB files generated by running ```cellSpecificity_bigWigOverBed.sh```) - line 5 (variable *folderName*).
```
createOpenMatrix.R
```
The script creates two matrices - one with maximum coverage value over the given region and one with mean0 value over the given region. Rows are individual genomic regions, columns are individual cell types. 
### 7. Normalize matrix
Final step of creating the cell specific open chromatin matrix is normalization. This is done by running ```normalizeOpenMatrix.R``` , where previously created matrix is passed to the variable *rawMatrix*. The script creates the open chromatin cell specific matrix in its final form, which is called *meanCoverage_percentile99_01_quantNormalized_round4d.txt*.\
The normalization steps are following: 
1) Set all values above 99th percentile for a given cell type to 1.
2) Normalize the rest of the values to range from 0 to 1.
3) Perform quantile normalization for cell types to be comparable.
