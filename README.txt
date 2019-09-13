# Newcastle PSG+Accelerometer study 2015

release: January 2018 version 1.0

This data set contains 55 .bin files, 28 .txt files, and one .csv file,
which were collected in Newcastle upon Tyne (UK) to evaluate an 
accelerometer-based algorithm for sleep classification.
The data come form a a single night polysomnography recording in 
28 sleep clinic patients. A description of the experimental 
protocol can be found in this open access PLoSONE paper from 2015: 
https://doi.org/10.1371/journal.pone.0142533. 

## Polysomnography

Sleep scores derived from polysomnography are stored in the .txt files. 
Each file represents a time series (one night) of one participant.
The resolution of the scoring is 
30 seconds. Participants are numbered. The participant number is 
included in the file names as “mecsleep01_...”. pariticpants_info.csv is a
dictionary of participant number, diagnosis, age, and sex.

## Accelerometer data

Accelerometer data from brand GENEActiv (https://www.activinsights.com) are 
stored in .bin files. Per participant two accelerometers were used: 
One accelerometer on each wrist (left and right). The right wrist from 
participant 10 is missing, hence the total number of 55 bin files. 
The tri-axial (three axis) accelerometers were configured to record 
at 85.7 Hertz. The accelerometer data can be read with R package 
GENEAread https://cran.r-project.org/web/packages/GENEAread/index.html. 
Additional information on the accelerometer can be found on the 
manufacturers product website: 
https://www.activinsights.com/resources-support/geneactiv/downloads-software/, 
including a description of the binary file structure on page 27 of 
this (pdf) file: https://49wvycy00mv416l561vrj345-wpengine.netdna-ssl.com/wp-content/uploads/2014/03/geneactiv_instruction_manual_v1.2.pdf.
The participant number and the body side on which the accelerometer 
is worn are included in the file names as “MECSLEEP01_left wrist...”.

## Participant information

The .csv file as included in this dataset contains a dictionary 
of the participant numbers, sleep disorder diagnosis, 
participant age at the time of measurement, and sex.

## Example processing

The code we used ourselves to process this data can be found in this 
GitHub repository: https://github.com/wadpac/psg-ncl-acc-spt-detection-eval.
Note that we use R package GGIR: https://cran.r-project.org/web/packages/GGIR/, 
which calls R package GENEAread for reading the binary data.

## Questions and citation

For questions about this data set please contact v.vanhees@esciencecenter.nl. 
Please cite this dataset with the doi as provided on the zenodo page where 
you downloaded this dataset.