module scolorqd.quantize;

import std.math;
import std.random;
import scolorqd.vector3;
import scolorqd.matrix2d;
import scolorqd.matrix3d;


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

int computeMaxCoarseLeve(int width, int height) {
    // We want the coarsest layer to have at most MAX_PIXELS pixels
    immutable int MAX_PIXELS = 4000;
    int result = 0;
    while (width * height > MAX_PIXELS) {
        width  >>= 1;
        height >>= 1;
        result++;
    }
    return result;
}

void initializeB0(Matrix2d filterWeights, Matrix2d b0){
    // Assume that the pixel i is always located at the center of b,
    // and vary pixel j's location through each location in b.
    immutable int radiusWidth = (filterWeights.width - 1)/2;
    immutable int radiusHeight = (filterWeights.height- 1)/2;
    immutable int offsetX = (b0.width - 1)/2 - radiusWidth;
    immutable int offsetY = (b0.height - 1)/2 - radiusHeight;
    
    for(int j_y = 0; j_y < b0.height; j_y++){
		for(int j_x = 0; j_x < b0.width; j_x++){
	    	for(int k_y = 0; k_y < filterWeights.height; k_y++){
				for(int k_x = 0; k_x < filterWeights.width; k_x++) {
		    		if (k_x+offsetX >= j_x - radiusWidth &&
						k_x+offsetX <= j_x + radiusWidth &&
		        		k_y+offsetY >= j_y - radiusWidth &&
						k_y+offsetY <= j_y + radiusWidth){
		    				vec3 value1 = matrix2dGet(filterWeights, k_x, k_y);
		    				vec3 value2 = matrix2dGet(filterWeights, k_x+offsetX-j_x+radiusWidth,k_y+offsetY-j_y+radiusHeight);
		    				vec3 product = value1 * value2;
		    				vec3 bValue = matrix2dGet(b0, j_x, j_y);
		    				matrix2dSet(b0, j_x, j_y, bValue + product);
		    		}
				}
	    	}	    
		}
    }
}


vec3 bValue(Matrix2d b, int i_x, int i_y, int j_x, int j_y){
    immutable int radiusWidth = (b.width - 1) / 2;
    immutable int radiusHeight = (b.height - 1) / 2;
    immutable int k_x = j_x - i_x + radiusWidth;
    immutable int k_y = j_y - i_y + radiusHeight;
    if (k_x >= 0 && k_y >= 0 && k_x < b.width && k_y < b.height){
    	return matrix2dGet(b, k_x, k_y);
    }
    return createVec3(0.0);
}

void initializeA0(Matrix2d image, Matrix2d b0, Matrix2d a0){
    immutable int radiusWidth = (b0.width - 1) / 2;
    immutable int radiusHeight = (b0.height - 1) / 2;
    
    for(int i_y = 0; i_y < a0.height; i_y++) {
		for(int i_x = 0; i_x < a0.width; i_x++){
	    	for(int j_y = i_y - radiusHeight; j_y <= i_y + radiusHeight; j_y++){
				if (j_y < 0){
					j_y = 0;
				}
				if (j_y >= a0.height){
					break;
				}

				for(int j_x = i_x - radiusWidth; j_x <= i_x + radiusWidth; j_x++){
		    		if (j_x < 0){
		    			j_x = 0;
		    		}
		    		if (j_x >= a0.width){
		    			break;
		    		}
		    		vec3 bValue1 = bValue(b0, i_x, i_y, j_x, j_y);
		    		vec3 imageValue = matrix2dGet(image, j_x, j_y);
		    		vec3 aValue = matrix2dGet(a0, i_x, i_y);
		    		vec3 sum = (bValue1 * imageValue) + aValue;
		    		matrix2dSet(a0, i_x, i_y, sum);
				}
	    	}
	    	vec3 temp = matrix2dGet(a0, i_x, i_y) * -2.0;
	    	matrix2dSet(a0, i_x, i_y, temp);
		}
    }
}

Matrix2d[] initialBArray(Matrix2d filterWeights){
	// Compute a_i, b_{ij} according to (11)
    immutable int extendedNeighborhoodWidth = filterWeights.width*2 - 1;
    immutable int extendedNeighborhoodHeight = filterWeights.height*2 - 1;
    Matrix2d b0 = createMatrix2d(extendedNeighborhoodWidth, extendedNeighborhoodHeight);
    //initialize b0
    initializeB0(filterWeights, b0);

    Matrix2d[] ret;
    ret ~= b0;
    return ret;
}

Matrix2d[] initialAArray(Matrix2d image, Matrix2d b0){
	Matrix2d a0 = createMatrix2d(image.width, image.height);
	initializeA0(image, b0, a0);
	Matrix2d[] ret;
    ret ~= a0;
    return ret;
}


vec3[] spatialColorQuant(Matrix2d image, int numColors){
	//constants (function arguments)
	immutable int tempsPerLevel = 3;
	immutable int repeatsPerTemp = 1;
	immutable int maxCoarseLevel = computeMaxCoarseLeve(image.width, image.height);
	immutable double initialTemperature = 1.0;
	immutable double finalTemperature = 0.001;

	//variables
	auto temperature = initialTemperature;
	//initialize data structures
	vec3[] palette = initialPalette(numColors);
	Matrix2d filterWeights = initialFilter3Weights(image.width, image.height, numColors);
	Matrix3d coarseVariables = randomFilledMatrix3d(image.width >> maxCoarseLevel, image.height >> maxCoarseLevel, numColors);

	Matrix2d[] bArray = initialBArray(filterWeights);
	Matrix2d[] aArray = initialAArray(image, bArray[0]);

	return palette;
}
