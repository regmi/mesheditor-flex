class Domain:
    
    def __init__(self, *args):
        if len(args) == 0:
            nodes, elements, boundaries, curves = [], [], [], []
        else:
            nodes, elements, boundaries, curves = args
        self._nodes = nodes
        self._elements = elements
        self._boundaries = boundaries
        self._curves = curves

        import sagenb.notebook.interact
        self._cell_id = sagenb.notebook.interact.SAGE_CELL_ID
        
    def convert_nodes(self, a):
        s = ""
        for n2 in a:
            s += "%s %s," % tuple(n2)
        return s
    
    def convert_elements(self, a):
        s = ""
        for e in a:
            if len(e) == 4:
                s += "%s %s %s %s," % tuple(e)
            elif len(e) == 5:
                s += "%s %s %s %s %s," % tuple(e)
        return s

    def convert_boundaries(self, a):
        s = ""
        for b in a:
            s += ("%s %s %s,") % tuple(b)
        return s
        
    def convert_curves(self, a):
        s = ""
        for c in a:
            s += ("%s %s %s,") % tuple(c)
        return s

    def get_html(self):
        path = "/javascript/mesh_editor"
        return """
            <html>
                <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="830" height="600">
                    <param name="movie" value="%(path)s/MeshEditor.swf">
                    <param name="flashvars" value="output_cell=%(cn)s&nodes=%(nodes)s&elements=%(elements)s&
                    boundaries=%(boundaries)s&curves=%(curves)s" />
                    <!--[if !IE]>-->
                    <object type="application/x-shockwave-flash" data="%(path)s/MeshEditor.swf" width="830" 
                    height="600">
                    <!--<![endif]-->
                        <param name="flashvars" value="output_cell=%(cn)s&nodes=%(nodes)s&elements=%(elements)s&
                        boundaries=%(boundaries)s&curves=%(curves)s" />
                        <p>Alternative Content</p>
                    <!--[if !IE]>-->
                    </object>
                    <!--<![endif]-->
                </object>
        </html>
        """ % {"path":path, "cn":self._cell_id, "nodes":self.convert_nodes(self._nodes),
        "elements":self.convert_elements(self._elements),
        "boundaries":self.convert_boundaries(self._boundaries),
        "curves":self.convert_curves(self._curves)}
    
    def get_mesh(self):
        from hermes2d import Mesh
        m = Mesh()
        m.create(self._nodes, self._elements, self._boundaries, self._curves)
        return m
                 
    def edit(self):
        s = self.get_html()
        #print s[s.find("html"):]
        return s
