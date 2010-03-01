CC = mxmlc
DEBUG = -debug=true
CFLAGS = -use-network=false

all: 
	$(CC) $(CFLAGS) Main.mxml

clean:
	rm *.swf 

