CC = mxmlc
DEBUG = -debug=false
CFLAGS = -use-network=true -target-player=10.0.0
 
all: 
	$(CC) $(DEBUG) $(CFLAGS) MeshEditor.mxml
clean:
	rm *.swf
