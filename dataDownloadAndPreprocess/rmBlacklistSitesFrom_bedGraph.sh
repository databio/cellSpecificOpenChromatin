#!/bin/bash

# remove blacklisted sites and unwanted chromosomes from bedGraph

for i in *.bedGraph
do 
	# get the file name without suffix
	cell="${i%.bedGraph}"
	echo $cell
	
	# define file name for file with unwanted chromosomes removed
	cleanBg=$cell"_clean.bedGraph"
	
	# remove unwanted chromosomes
	echo "Removing unwanted chromosomes"
	sed '/chrM/d;/random/d;/chrUn/d;/hap/d;/chrY/d' < $i > $cleanBg
	
	# define file names - add suffix _blRemoved to both bedGraph and bigWig
	bgFile=$cell"_blRemoved.bedGraph"

	# remove the blacklisted sites
	echo "remove blaclisted sites"
	bedtools subtract -a $cleanBg -b /blacklistedSites/combined_Blacklist.bed -A > $bgFile
	
	mv $bgFile bedGraph_blacklisted_sites_removed
	
	# remove the original file 
	# remove the file with just unwanted chromosomes removed prior to blacklisting
	rm $i
	rm $cleanBg
	
done
