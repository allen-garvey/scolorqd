module scolorqd.main;

import std.stdio;
import std.string;
import std.conv;
import scolorqd.file;
import scolorqd.image;
import scolorqd.matrix2d;
import scolorqd.quantize;


int printUsage(string programName){
	stderr.writef("usage: %s image_filename number_of_colors\n", programName);
	return 1;
}

int main(string[] args){
	immutable string programName = args[0];
	//check for image filename argument
	if(args.length != 3){
		return printUsage(programName);
	}

	string numColorsString = args[2];
	if(!isNumeric(numColorsString)){
		return printUsage(programName);
	}
	int numColors = to!int(numColorsString);

	PixelImage image;
	image.path = args[1];

	if(!isValidFilename(image.path)){
		stderr.writef("%s doesn't exist or is a directory\n", image.path);
		return 1;
	}

	image.fileType = imageFileTypeFor(image.path);

	if(image.fileType == ImageFileType.Unsupported){
		stderr.writef("%s is not a jpeg or png file\n", image.path);
		return 1;
	}

	image.memoryImage = loadMemoryImage(image);
	Matrix2d imageVector = matrixFromMemoryImage(image.memoryImage);

	spatialColorQuant(imageVector, numColors);

	//has to save to png for now
	//saveToFile(image, defaultModifiedFilePath(image.path));

	return 0;
}