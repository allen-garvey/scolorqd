module scolorqd.image;

import std.string;
import arsd.png;
import arsd.jpeg;
import arsd.color;

struct PixelImage{
	string path;
	ImageFileType fileType;
	MemoryImage memoryImage;
}

enum ImageFileType{
	Unsupported = 0,
	Jpeg,
	Png
}

MemoryImage loadMemoryImage(PixelImage pixelImage)
in{
	assert(pixelImage.fileType == ImageFileType.Jpeg || pixelImage.fileType == ImageFileType.Png);
	assert(!pixelImage.path.empty);
}
body{
	if(pixelImage.fileType == ImageFileType.Png){
		return readPng(pixelImage.path);
	}
	return readJpeg(pixelImage.path);
}

//only have functionality to save pngs to file for now
void saveToFile(PixelImage pixelImage, string path)
in{
	assert(pixelImage.memoryImage !is null);
	assert(!path.empty);
}
body{
	writePng(path, pixelImage.memoryImage);
}