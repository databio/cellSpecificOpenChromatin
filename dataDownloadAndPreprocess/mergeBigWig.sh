#!/bin/bash

# script goes through subdirectories - merges bigWigs within the directory to 
# a bigWig named according to the directory - this produces bedGraph
# move the files to directory provided
echo -e What is the full path to the folder where outputs should be stored?
read bigWigFolder

echo -e What is the full path to the file with chromosome sizes?
read chromSize


for f in *; do
    if [ -d "$f" ]; then
        # $f is a directory
        echo $f
        
        cd $f
        
        #merge the bigWig files
        bigWigMerge *.bigWig $f.bedGraph
        
        # convert bedGraph to bigWig
        bedGraphToBigWig $f.bedGraph $chromSize $f.bw
        
        # move the merged bigWig to designated folder and remove bedGraph file
        mv $f.bw $bigWigFolder
        rm $f.bedGraph
        
        cd ..
    fi
done


