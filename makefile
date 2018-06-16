SRC=$(shell find ./src -type f -name '*.d')
ARSD=lib/arsd/color.d lib/arsd/png.d lib/arsd/jpeg.d

APP_BINARY=./bin/scolorqd

all: dev

dev:
	dmd $(SRC) $(ARSD) -of$(APP_BINARY) -od./bin -unittest

release:
	dmd $(SRC) $(ARSD) -of$(APP_BINARY) -od./bin -O -inline