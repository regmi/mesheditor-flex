CC = mxmlc
DEBUG = -debug=true
CFLAGS = -use-network=false

all: 
	$(CC) $(DEBUG) $(CFLAGS) Main.mxml

clean:
	rm *.swf 

