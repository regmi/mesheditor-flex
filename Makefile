CC = mxmlc

DEBUG = -debug=false
CFLAGS = -use-network=true -target-player=10.1.0

all: compile 

compile:
	$(CC) $(DEBUG) $(CFLAGS) MeshEditor.mxml

#Compile & install Mesheditor in femhub
install: compile
	femhub -s spkg-install

clean:
	rm *.swf
