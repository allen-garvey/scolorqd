module scolorqd.file;

import std.path;
import std.string;
import std.file;
import std.conv;
import scolorqd.image;

ImageFileType imageFileTypeFor(string path){
	auto pathExtension = extension(path);
	if(pathExtension.empty){
		return ImageFileType.Unsupported;
	}
	pathExtension = toLower(pathExtension);

	if(pathExtension == ".png"){
		return ImageFileType.Png;
	}
	if(pathExtension == ".jpg" || pathExtension == ".jpeg"){
		return ImageFileType.Jpeg;
	}

	return ImageFileType.Unsupported;
}

bool isValidFilename(string path){
	return exists(path) && isFile(path);
}

//only .png as extension, since we can only save png files
//for now
string defaultModifiedFilePath(string path){
	//string pathExtension = extension(path);
	string modifiedPathName = stripExtension(path) ~ "_modified" ~ ".png";
	int i = 1;
	while(exists(modifiedPathName)){
		modifiedPathName = stripExtension(path) ~ "_modified" ~ to!string(i) ~ ".png";
		i++;
	}

	return modifiedPathName;
}