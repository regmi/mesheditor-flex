Download, Install and Run FEMhub
================================
You can run download and install FEMhub easily on your local desktop. 
Please follow the instructions below. If you do not want to download or 
install anything you can use our `FEMhub Online Lab <http://nb.femhub.org/>`_.

Binary
------

You can view a list of the binaries of all versions`here <htt://femhub.org/pub/`_. From there you can download the
version you want.

If you downloaded a binary, you do not need to do anything, just extract it and you are reday to go. Follow
the instructions on running FEMhub below. 

Building from Sources
---------------------

You can get the tarball of sources here `here <htt://femhub.org/pub/>`_. 
The most recent stable version is femhub-0.9.8. You can also try 0.9.9.beta6.

If you download the sources, please read below on how to build FEMhub and work around common issues:

1. Make sure you have the dependencies and 2GB free disk space.
::
 LINUX (install these using your package manager):
      gcc, g++, make, m4, perl, ranlib, and tar.

 OSX: XCode.  WARNING: If "gcc -v" outputs 4.0.0, you 
      *must* upgrade XCode (free from Apple), since that
      version of GCC is very broken. 

 Microsoft Windows: install cygwin using the setup.exe and in that choose to install the following packages:

     gcc4, gfortran, make, m4, perl, openssl-devel, cmake, libX11-devel,
     xextproto, libXext-devel, libXt-devel, libXt, libXext

NOTE: On some operating systems it might be necessary to install
gas/as, gld/ld, gnm/nm, but on most these are automatically
installed when you install the programs listed above.  Only OS X
>= 10.4.x and certain Linux distributions are 100% supported.
See below for a complete list.

2. Extract the tarball:
::
      \$ tar xf femhub-0.9.8-*.tar

3. cd into the  femhub directory and type make:
::
      \$ cd femhub-0.9.8
      \$ make

You can take advantage of several cores on your computer by executing
::
      \$ export MAKE="make -j9"
before typing make to compile in parallel on 9 cores.
 
Depending on the speed of your computer, wait between 37 minutes to 1.5 hour. That's it. Everything is automatic and non-interactive.

If you encounter problems, let us know through the FEMhub mailing list: http://groups.google.com/group/femhub

If you want, you can also download a binary from `here <htt://femhub.org/pub/>`_, however, if it doesn't work for you, compile from source, that should always work.

NOTE:  On Linux if you get this error message:
:: 
  " restore segment prot after reloc: Permission denied "
the problem is probably related to SE Linux: http://www.ittvis.com/services/techtip.asp?ttid=3092

Git Repository
--------------

If you use git, you can download FEMhub and compile by following these instructions:
::
    \$ git clone http://hpfem.org/git/femhub.git
    \$ cd femhub
    \$ cd spkg/standard
    \$ ./download_packages     # downloads the required packages
    \$ cd ../..
    \$ export MAKE="make -j9"  # optional
    \$ make

Running FEMhub
---------------

Go the femhub top directory, and just execute
:: 

 ./femhub 

from the command line, and type lab() after that. 
::
    \$ ./femhub
    ----------------------------------------------------------------------
    | Femhub (FEM Distribution), Version 0.9.8, Release Date: 2009-11-20 |
    | Type lab() for the GUI.                                            |
    ----------------------------------------------------------------------
    In [1]: lab()

and a browser will start with the web notebook. If the browser does not 
start automatically, just type this in your browser: http://localhost:8000/

.. image:: img/femhub_lab.png
   :align: center
   :width: 600
   :height: 400
   :alt: Screenshot of FEMhub Online Lab
