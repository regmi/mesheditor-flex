How to Use FEMhub Online Lab
============================
FEMhub online lab can be used on your local machine, after you install the FEMhub package. Alternatively, if you do not want to download and install anything you can use FEMhub online lab hosted in the `server of hp-FEM group at University of Nevada, Reno <http://nb.femhub.org/>`_.

FEMhub Online Lab in the Server at UNR 
---------------------------------------------------------------
If you want to use FEMhub online lab hosted at the server of hp-FEM group, University of Nevada Reno,
please follow the follwing instructions:

Step 1: `Sign up <http://nb.femhub.org/register>`_ for a new FEMhub online lab account
This is automatic and fast. Report any problems to femhub@googlegroups.com.

Step 2: Log into the `online lab <http://nb.femhub.org/>`_. Click on "published worksheets". Then click on
any link starting with "Num Methods", the simplest one being "Num Methods:
Taylor Polynomial".

Step 3: Click on "Edit a Copy" in the upper left corner and wait for the
browser response. Scroll down below the first input window and click
"Evaluate"(the "Evaluate" link appears once you click into the input window).
This will load the program. Then there are two input windows with two different
ways to plot a Taylor polynomial that are self-explanatory.

Step 4: There are multiple other worksheets whose title begins with "Num
Methods:". Try them out and give us your feedback!

Step 5: You can try out worksheets starting with "Hermes2D:" that allow you to
solve finite element problems via the internet. Feel free to adjust the
existing worksheets to fit your own needs. We are working on expanding the
possibilities.


FEMhub Online Lab on Your Local Machine
---------------------------------------

First download and Install FEMhub following the instructions elsewhere on the documentation.
Then go to the femhub top directory, and just execute **./femhub** from the command line, 
and after that type **lab()**.
::
    $ ./femhub
    ----------------------------------------------------------------------
    | Femhub (FEM Distribution), Version 0.9.8, Release Date: 2009-11-20 |
    | Type lab() for the GUI.                                            |
    ----------------------------------------------------------------------
    In [1]: lab()

and a browser will start with the online lab. If the browser does not 
start automatically, just type this in your browser: http://localhost:8000/

.. image:: img/femhub_lab.png
   :align: center
   :width: 600
   :height: 400
   :alt: Screenshot of FEMhub Online Lab

Click "New Worksheet" to open a new worksheet, and in the text input window of the worksheet copy-paste the following:
::
    # Hermes2D: Example 01 (mesh)
    # This example shows how to create a mesh.

    from hermes2d import Mesh, MeshView

    mesh = Mesh()

    # Creates a mesh from a list of nodes, elements, boundary and nurbs.
    mesh.create([
            [0, -1],
            [1, -1],
            [-1, 0],
            [0, 0],
            [1, 0],
            [-1, 1],
            [0, 1],
            [0.707106781, 0.707106781]
        ], [
            [0, 1, 4, 3, 0],
            [3, 4, 7, 0],
            [3, 7, 6, 0],
            [2, 3, 6, 5, 0]
        ], [
            [0, 1, 1],
            [1, 4, 2],
            [3, 0, 4],
            [4, 7, 2],
            [7, 6, 2],
            [2, 3, 4],
            [6, 5, 2],
            [5, 2, 3]
        ], [
            [4, 7, 45],
            [7, 6, 45]
        ])

    # Display the Mesh
    mview = MeshView()
    mview.show(mesh, lib="mpl", method="orders", notebook=True)

Click "Evaluate" button and you should see the following output:

.. image:: img/meshonlab.png
   :align: center
   :width: 662
   :height: 742
   :alt: Screenshot of running an example on FEMhub online lab
