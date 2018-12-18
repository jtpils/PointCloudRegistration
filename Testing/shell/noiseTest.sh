#!/bin/sh
echo "====================================================================="
echo "noiseTest.sh:"
echo "   Noise test. This will run the program for several amounts and"
echo "   types of noise and display the results."
echo " "

DAT=../../data
FIG=../../figures/NoiseTest
MAT=../../matlab

export INPUT_PATH="dat/"
export OUTPUT_PATH="dat/"
# ==============================================================================
# Generate all the data needed

echo "Input and output paths defined by:                                   "
echo "Input : $INPUT_PATH                                                  "
echo "Output: $OUTPUT_PATH                                                 "
echo "                                                                     "

# Clean model
echo "   Fetching clean models"
mkdir dat
cp $DAT/bunnyPartial1.ply dat/bunnyClean.ply
cp $DAT/bunnyPartial2.ply dat/bunnyTransform.ply

# Test transformation
echo "   Generating transformed model."
# Rotation in degrees: 30, 30, 45 
NOISE_TYPE=none \
	ROTATION="0.52,0.52,0.79" \
	TRANSLATION="0.1,0.0,-0.1" \
	./GenerateData bunnyTransform.ply bunnyTransform.ply


echo "====================================================================="
echo "Commencing tests:                                                    "
echo " "

echo "Clean ---------------------------------------------------------------"
echo " "
OUTPUT_NAME=resultClean  ./Registration bunnyClean.ply bunnyTransform.ply 
echo " "
echo "Gaussian   ----------------------------------------------------------"
echo " "
export NOISE_TYPE=gaussian
export NOISE_STRENGTH=0.01
./GenerateData bunnyClean.ply gaussianBunny1.ply 
./GenerateData bunnyTransform.ply gaussianBunny2.ply 
echo " "

OUTPUT_NAME=resultGauss1 \
	EXPORT_CORRESPONDENCES=true \
	MIN_R=0.01 \
	STP_R=1.1 \
	MAX_R=0.05 \
	ALPHA=1.0 \
	./Registration gaussianBunny1.ply gaussianBunny2.ply 
echo "----------------------------------------------------------"
#echo " "
#export NOISE_TYPE=gaussian
#export NOISE_STRENGTH=1.0
#./GenerateData bunnyClean.ply gaussianBunny3.ply
#./GenerateData bunnyTransform.ply gaussianBunny4.ply
#echo " "

#OUTPUT_NAME=resultGauss2 \
#	./Registration gaussianBunny3.ply gaussianBunny4.ply
#echo "----------------------------------------------------------"

echo " "
echo "Outliers   ----------------------------------------------------------"
echo " "
export NOISE_TYPE=outliers
export OUTLIER_AMOUNT=1.0
./GenerateData bunnyClean.ply outlierBunny1.ply 
./GenerateData bunnyTransform.ply outlierBunny2.ply 
echo " "

OUTPUT_NAME=resultOut1 ./Registration outlierBunny1.ply outlierBunny2.ply 

echo "----------------------------------------------------------"
echo " "
export NOISE_TYPE=outliers
export OUTLIER_AMOUNT=5.0
./GenerateData bunnyClean.ply outlierBunny3.ply 
./GenerateData bunnyTransform.ply outlierBunny4.ply 
echo " "

OUTPUT_NAME=resultOut2 ./Registration outlierBunny3.ply outlierBunny4.ply 

echo "----------------------------------------------------------"
echo " "
export NOISE_TYPE=outliers
export OUTLIER_AMOUNT=10.0
./GenerateData bunnyClean.ply outlierBunny5.ply 
./GenerateData bunnyTransform.ply outlierBunny6.ply 
echo " "

OUTPUT_NAME=resultOut3 ./Registration outlierBunny5.ply outlierBunny6.ply 
echo "----------------------------------------------------------"
wait
if [ -s error.err ] ; then
	echo "Errors have been found. Exiting."
	echo " "
	rm -fr *.ply *.exe *.sh fig
	exit
fi
# ==============================================================================
# Export the figures using matlab
echo " "
echo "====================================================================="
echo "Running matlab to complete visualisation.                            "
mkdir -p fig $FIG
matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
	displayRegistration('bunny','./','fig');
	displayRegistration('resultClean','./','fig');
	displayRegistration('resultGauss1','./','fig');
	%animateCorrespondences('Corr','./','fig');
	%displayRegistration('resultGauss2','./','fig');
	%displayRegistration('resultOut1','./','fig');
	%displayRegistration('resultOut2','./','fig');
	%displayRegistration('resultOut3','./','fig');
	exit;"
mv -ft $FIG fig/*
rm -fr *.ply *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="
