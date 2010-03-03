CC = mxmlc
DEBUG = -debug=false
CFLAGS = -use-network=false

all: 
	$(CC) $(DEBUG) $(CFLAGS) Main.mxml

clean:
	rm *.swf 

