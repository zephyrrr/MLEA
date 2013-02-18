% This make.m is used under Windows

mex -O -largeArrayDims -DPOLY2 -c ..\blas\*.c -outdir ..\blas
mex -O -largeArrayDims -DPOLY2 -c ..\linear.cpp
mex -O -largeArrayDims -DPOLY2 -c ..\tron.cpp
mex -O -largeArrayDims -DPOLY2 -c linear_model_matlab.c -I..\
mex -O -largeArrayDims -DPOLY2 train.c -I..\ tron.obj linear.obj linear_model_matlab.obj ..\blas\*.obj
mex -O -largeArrayDims -DPOLY2 predict.c -I..\ tron.obj linear.obj linear_model_matlab.obj ..\blas\*.obj
mex -O -largeArrayDims -DPOLY2 libsvmread.c
mex -O -largeArrayDims -DPOLY2 libsvmwrite.c
