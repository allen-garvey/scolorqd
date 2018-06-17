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


//void matrix3dSet(Matrix3d matrix, int x, int y, int z, vec3 value){
//	matrix.data[y*matrix.width*matrix.depth + x*matrix.depth + z] = value;
//}

vec3 matrix3dGet(Matrix3d matrix, int x, int y, int z){
	return matrix.data[y*matrix.width*matrix.depth + x*matrix.depth + z];
}

Matrix3d randomFilledMatrix3d(int width, int height, int depth){
	auto ret = createMatrix3d(width, height, depth);
	
	for(int i=0;i<ret.data.length;i++){
		ret.data[i] = uniform01();
	}

	return ret;
}