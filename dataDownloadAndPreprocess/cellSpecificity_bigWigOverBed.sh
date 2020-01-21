 #!/bin/bash

# Script for getting average + max + min coverage values at certain regions :
# Run from a folder with the bigWig files - the output folders will 
# be created within here
# inputs are: BED file with desired regions and bedGeph files to be plotted onto it
# 1) drag a folder with the bed files to a console
# 2) get the intersections of te bed file and bedGraph with the overlap information

# go through all the BED files within the folder and intersect bedGraph with each one
echo -e What is the folder with your BED files? # drag the folder to the console
read bedFolder

for bedFile in "$bedFolder"/*.bed
 do
 
 # 
  echo "Computation on following BED file: ${bedFile}"
  
  #get the BED file name for creation of new folder - 1) remove path, 2) remove extension
  filename=$(basename -- "$bedFile")
  folder="${filename%.*}"
  
  #create output folder for a given BED file
  folderReference="${folder}_coverage"
  mkdir $folderReference
  
	# go through the bedGraph files and intersect them with the BED file
	# the last column is size of the overlap
	for i in *.bw
	 do 
		# id= everything before "."
		id="$( cut -d '.' -f 1 <<< "$i" )"
		echo "Following bigWig is processed: ${id}"
	
		# define output names
		output="${id}.tab"
		
		# bigWigSummaryOverBed - input: bigWig and BED files + option minMax
		bigWigAverageOverBed $i $bedFile -minMax $output
	
		# move results to designated folder
		mv $output $folderReference
	done
done

