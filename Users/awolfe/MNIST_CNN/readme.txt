The Training folder has the python scripts for making the training data.

getting pytorch:
https://pytorch.org/get-started/locally/

train.py gives 1,432KB of weights, for 98.62% accuracy
train2.py gives 8KB of weights, for 96.52% accuracy
train3.py gives 4,691KB of weights, for 98.92% accuracy

I went with train2 which isn't the most accurate, but it is the smallest by far, which means it will also be the fastest.

The MLP version of this demo that I put up previously uses 94KB of weights, and has 95% accuracy, so train2 is much smaller and more accurate as well.
