#!/bin/bash

# Makes programs, downloads sample data, trains a GloVe model, and then evaluates it.
# One optional argument can specify the language used for eval script: matlab, octave or [default] python

# make
# if [ ! -e text8 ]; then
#   if hash wget 2>/dev/null; then
#     wget http://mattmahoney.net/dc/text8.zip
#   else
#     curl -O http://mattmahoney.net/dc/text8.zip
#   fi
#   unzip text8.zip
#   rm text8.zip
# fi
year=2013
#DIR=/home/sonata/Downloads/Embedding/data/twitter_s3/$year
DIR=/mnt/HDD/$year
CORPUS=$DIR/tweets.$year.txt
VOCAB_FILE=$DIR/vocab_$year.txt
COOCCURRENCE_FILE=$DIR/cooccurrence_$year.bin
COOCCURRENCE_SHUF_FILE=$DIR/cooccurrence_$year.shuf.bin
BUILDDIR=build
#SAVE_FILE=../../embedding/Twitter_Glove/twitter_vectors_$year
SAVE_FILE=/mnt/HDD/embedding/twitter_vectors_$year
VERBOSE=2
MEMORY=50.0
VOCAB_MIN_COUNT=40
VECTOR_SIZE=300
MAX_ITER=15
WINDOW_SIZE=8
BINARY=2
NUM_THREADS=32
X_MAX=10
echo *********vocabcount_$(date +%m%d_%T)
if [ ! -f "$VOCAB_FILE" ]; then 
echo "build new vocabulary"
$BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $CORPUS > $VOCAB_FILE
else
echo "existed vocabulary"
fi
if [[ $? -eq 0 ]]
  then
  echo *********coocur$(date +%m%d_%T)
  $BUILDDIR/cooccur -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $CORPUS > $COOCCURRENCE_FILE
  if [[ $? -eq 0 ]]
  then
    echo *********shuffle_$(date +%m%d_%T)
    $BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE
    if [[ $? -eq 0 ]]
    then
       echo *********glovetrain_$(date +%m%d_%T)
       $BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE
       if [[ $? -eq 0 ]]
       then
           if [ "$1" = 'matlab' ]; then
               matlab -nodisplay -nodesktop -nojvm -nosplash < ./eval/matlab/read_and_evaluate.m 1>&2 
           elif [ "$1" = 'octave' ]; then
               octave < ./eval/octave/read_and_evaluate_octave.m 1>&2 
           else
               echo *********evaluate_$(date +%m%d_%T)
               python eval/python/evaluate.py --vectors_file $SAVE_FILE.txt --vocab_file $VOCAB_FILE
           fi
       fi
    fi
  fi
fi
