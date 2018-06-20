module scolorqd.matrix3d;

import std.random;
import scolorqd.vector3;


struct Matrix3d{
	int width;
	int height;
	int depth;
	vec3[] data;
}


Matrix3d createMatrix3d(int width, int height, int depth){
	Matrix3d ret;
	ret.width = width;
	ret.height = height;
	ret.depth = depth;
	ret.data.length = height * width * depth;

	return ret;
}


//void matrix3dSet(Matrix3d matrix, int x, int y, int z, vec3 value)
//in{
//	assert(x >= 0 && x < matrix.width);
//	assert(y >= 0 && y < matrix.height);
//	assert(z >= 0 && z < matrix.depth);
//}
//do{
//	matrix.data[y*matrix.width*matrix.depth + x*matrix.depth + z] = value;
//}

vec3 matrix3dGet(Matrix3d matrix, int x, int y, int z)
in{
	assert(x >= 0 && x < matrix.width);
	assert(y >= 0 && y < matrix.height);
	assert(z >= 0 && z < matrix.depth);
}
do{
	//Not sure if this calculation to get the index is correct, but that is what is in the original
	return matrix.data[y*matrix.width*matrix.depth + x*matrix.depth + z];
}

Matrix3d randomFilledMatrix3d(int width, int height, int depth){
	auto ret = createMatrix3d(width, height, depth);
	
	for(int i=0;i<ret.data.length;i++){
		ret.data[i] = uniform01();
	}

	return ret;
}