Download Adobe Flex 3.5 SDK:

#. go to http://www.adobe.com/cfusion/entitlement/index.cfm?e=flex3sdk
#. click "Download Now"
#. save it, go the directory with the download flex_sdk_3.5.zip

Then install the flex sdk::

    $ mkdir flex_sdk
    $ cd flex_sdk
    $ unzip ../flex_sdk_3.5.zip
    $ export PATH=$PATH:`pwd`/bin

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

This will generate the file ``MeshEditor.swf``. Test the mesh editor::

    $ firefox MeshEditor.swf
