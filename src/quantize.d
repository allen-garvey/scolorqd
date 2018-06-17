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

void computeBArray(Matrix2d filterWeights, Matrix2d b){
    // Assume that the pixel i is always located at the center of b,
    // and vary pixel j's location through each location in b.
    immutable int radiusWidth = (filterWeights.width - 1)/2;
    immutable int radiusHeight = (filterWeights.height- 1)/2;
    immutable int offsetX = (b.width - 1)/2 - radiusWidth;
    immutable int offsetY = (b.height - 1)/2 - radiusHeight;
    
    for(int j_y = 0; j_y < b.height; j_y++){
		for(int j_x = 0; j_x < b.width; j_x++){
	    	for(int k_y = 0; k_y < filterWeights.height; k_y++){
				for(int k_x = 0; k_x < filterWeights.width; k_x++) {
		    		if (k_x+offsetX >= j_x - radiusWidth &&
						k_x+offsetX <= j_x + radiusWidth &&
		        		k_y+offsetY >= j_y - radiusWidth &&
						k_y+offsetY <= j_y + radiusWidth){
		    				vec3 value1 = matrix2dGet(filterWeights, k_x, k_y);
		    				vec3 value2 = matrix2dGet(filterWeights, k_x+offsetX-j_x+radiusWidth,k_y+offsetY-j_y+radiusHeight);
		    				vec3 product = value1 * value2;
		    				vec3 bValue = matrix2dGet(b, j_x, j_y);
		    				matrix2dSet(b, j_x, j_y, bValue + product);
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

void computeAImage(Matrix2d image, Matrix2d b, Matrix2d a){
    immutable int radiusWidth = (b.width - 1) / 2;
    immutable int radiusHeight = (b.height - 1) / 2;
    
    for(int i_y = 0; i_y < a.height; i_y++) {
		for(int i_x = 0; i_x < a.width; i_x++){
	    	for(int j_y = i_y - radiusHeight; j_y <= i_y + radiusHeight; j_y++){
				if (j_y < 0){
					j_y = 0;
				}
				if (j_y >= a.height){
					break;
				}

				for(int j_x = i_x - radiusWidth; j_x <= i_x + radiusWidth; j_x++){
		    		if (j_x < 0){
		    			j_x = 0;
		    		}
		    		if (j_x >= a.width){
		    			break;
		    		}
		    		vec3 bValue1 = bValue(b, i_x, i_y, j_x, j_y);
		    		vec3 imageValue = matrix2dGet(image, j_x, j_y);
		    		vec3 aValue = matrix2dGet(a, i_x, i_y);
		    		vec3 sum = (bValue1 * imageValue) + aValue;
		    		matrix2dSet(a, i_x, i_y, sum);
				}
	    	}
	    	vec3 temp = matrix2dGet(a, i_x, i_y) * -2.0;
	    	matrix2dSet(a, i_x, i_y, temp);
		}
    }
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

	// Compute a_i, b_{ij} according to (11)
    immutable int extendedNeighborhoodWidth = filterWeights.width*2 - 1;
    immutable int extendedNeighborhoodHeight = filterWeights.height*2 - 1;
    Matrix2d b0 = createMatrix2d(extendedNeighborhoodWidth, extendedNeighborhoodHeight);

	return palette;
}
