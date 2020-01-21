#!/bin/bash

# script goes through subdirectories - merges bigWigs within the directory to 
# a bigWig named according to the directory - this produces bedGraph
# move the files to directory provided
echo -e What is the full path to the folder where outputs should be stored?
read bedGraphFolder

for f in *; do
    if [ -d "$f" ]; then
        # $f is a directory
        echo $f
        
        cd $f
        
        bigWigMerge *.bigWig $f.bedGraph
        
        mv $f.bedGraph $bedGraphFolder
        
        cd ..
    fi
done


