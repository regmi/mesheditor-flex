CC = mxmlc
DEBUG = -debug=false
CFLAGS = -use-network=false
 
all: 
	$(CC) $(DEBUG) $(CFLAGS) MeshEditor.mxml
 
clean:
	rm *.swf

