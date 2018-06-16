module scolorqd.quantize;

import std.math;
import std.random;
import scolorqd.vector3;
import scolorqd.matrix2d;


vec3[] initialPalette(int numColors){
	vec3[] palette = new vec3[numColors];

	for(int i=0;i<numColors;i++){
		palette[i] = createVec3(uniform01(), uniform01(), uniform01());
	}

	return palette;
}

Matrix2d initialFilter3Weights(int imageWidth, int imageHeight, int numColors){
	immutable int filterDimensions = 3;
	Matrix2d filter3Weights = createMatrix2d(filterDimensions, filterDimensions);

	double ditheringLevel = 0.09*log(1.0*imageWidth*imageHeight) - 0.04*log(1.0 * numColors) + 0.001;
	
	double stddev = ditheringLevel * ditheringLevel;
    double sum = 0.0;

    for(int i=0; i<filterDimensions; i++) {
		for(int j=0; j<filterDimensions; j++){
		    double value = exp(-sqrt(1.0 * ((i-1)*(i-1) + (j-1)*(j-1)))/stddev);
		    matrix2dSet(filter3Weights, i, j, createVec3(value));
		    sum += value;
		}
    }
    for(int i=0; i<filterDimensions; i++) {
		for(int j=0; j<filterDimensions; j++) {
		    vec3 value = matrix2dGet(filter3Weights, i, j);
		    matrix2dSet(filter3Weights, i, j, value / sum);
		}
    }

	return filter3Weights;
}

vec3[] spatialColorQuant(Matrix2d image, int numColors){
	vec3[] palette = initialPalette(numColors);
	Matrix2d filterWeights = initialFilter3Weights(image.width, image.height, numColors);


	return palette;
}
