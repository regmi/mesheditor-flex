First install the flex sdk::

    $ mkdir flex_sdk
    $ cd flex_sdk
    $ wget http://hpfem.org/downloads/flex_sdk_3.5.zip
    $ unzip ../flex_sdk_3.5.zip

To add flex_sdk.3.5/bin directory to your system path:
change the following script according to your need and to your bashrc::

    export PATH=$PATH:path_to/flex_sdk.3.5/bin

This PATH export is a temporary solution (valid only in your 
current terminal session). To make it permanent, you need to 
add the following line into your .bashrc file::

    export PATH=$PATH:/home/pavel/tmp/flex_sdk/bin

Adapt the path to the one you chose for your installation.

Now clone the mesh editor git repository (if you have not already done so)::

    $ git clone git://github.com/hpfem/mesheditor-flex.git

Compile the mesh editor::

    $ cd mesheditor-flex
    $ make

Install mesh editor in femhub:
    $ make install
    This will compile & install messeditor in your local femhub


To test mesh editor:

    After compilation ``MeshEditor.swf`` fill will be generated.

    i) open it in a browser
       $ firefox MeshEditor.swf

       this way you can test some of the mesh editing features but
       triangulation feature will not work

    ii) run local femhub, run online lab and launch mesh editor

