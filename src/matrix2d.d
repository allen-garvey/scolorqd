module scolorqd.matrix2d;

import arsd.color;
import scolorqd.vector3;

struct Matrix2d{
	int width;
	int height;
	vec3[] data;
}


Matrix2d createMatrix2d(int width, int height){
	Matrix2d ret;
	ret.width = width;
	ret.height = height;
	ret.data.length = height * width;

	return ret;
}

void matrix2dSet(Matrix2d matrix, int x, int y, vec3 value){
	matrix.data[y*matrix.width + x] = value;
}

vec3 matrix2dGet(Matrix2d matrix, int x, int y){
	return matrix.data[y*matrix.width + x];
}


Matrix2d matrixFromMemoryImage(MemoryImage memoryImage){
	immutable int width = memoryImage.width();
	immutable int height = memoryImage.height();
	auto ret = createMatrix2d(width, height);

	for(int y=0;y<height;y++){
		for(int x=0;x<width;x++){
			immutable Color pixel = memoryImage.getPixel(x, y);
			vec3 pixelVector = createVec3(1.0 * pixel.r / 255.0, 1.0 * pixel.g / 255.0, 1.0 * pixel.b / 255.0);
			ret.matrix2dSet(x, y, pixelVector);
		}
	}
	return ret;
}