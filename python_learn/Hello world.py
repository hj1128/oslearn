import gi

gi.require_version('Gtk','3.0')
from gi.repository import Gtk

class Application(Gtk.Window):
    def _init_(self):
        Gtk.Window._init_(self,title="Hello world")
        
app = Application()
app.show_all()
Gtk.main()