CC = /home/ondrej/ext/flex/bin/mxmlc
DEBUG = -debug=false
CFLAGS = -use-network=true -target-player=10.0.0
 
all: 
	$(CC) $(DEBUG) $(CFLAGS) MeshEditor.mxml
	cp MeshEditor.swf ../femhub-lab/src/sagenb/data/mesh_editor/
clean:
	rm *.swf
