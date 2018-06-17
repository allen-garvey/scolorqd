module scolorqd.vector3;

import core.simd;


alias vec3 = float4;


vec3 createVec3(float f){
	vec3 ret = f;
	return ret;
}

vec3 createVec3(float a, float b, float c){
	vec3 ret;
	ret.array[0] = a;
	ret.array[1] = b;
	ret.array[2] = c;

	return ret;
}

float dotProduct(vec3 a, vec3 b){
	vec3 product = a * b;
	return product.array[0] + product.array[1] + product.array[2];
}