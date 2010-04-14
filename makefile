CC = mxmlc
DEBUG = -debug=false
CFLAGS = -use-network=true -target-player=10.0.0
 
all: 
	$(CC) $(DEBUG) $(CFLAGS) MeshEditor.mxml
	cp MeshEditor.swf server/django/server/static/
	cp MeshEditor.swf ~/Documents/hpfem/femhub_notebook_repo/src/sagenb/data/mesh_editor/
	cp MeshEditor.swf ~/Downloads/femhub-0.9.8-ubuntu64/local/lib/python2.6/site-packages/sagenb-0.7.5-py2.6.egg/sagenb/data/mesh_editor/
clean:
	rm *.swf
