#!/usr/bin/python3
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import subprocess
import urllib.parse
import os
import sys

class FileManager(dbus.service.Object):
    def __init__(self, bus, path):
        super().__init__(bus, path)

    @dbus.service.method("org.freedesktop.FileManager1", in_signature="ass", out_signature="")
    def ShowItems(self, uris, startup_id):
        self._open_uris(uris)

    @dbus.service.method("org.freedesktop.FileManager1", in_signature="ass", out_signature="")
    def ShowFolders(self, uris, startup_id):
        self._open_uris(uris)

    @dbus.service.method("org.freedesktop.FileManager1", in_signature="ass", out_signature="")
    def ShowItemProperties(self, uris, startup_id):
        pass

    def _open_uris(self, uris):
        if not uris:
            return
        
        # We process the first URI
        uri = uris[0]
        if uri.startswith("file://"):
            # Unquote the URL to handle spaces and special characters
            path = urllib.parse.unquote(uri[7:])
            
            # Launch Yazi in Kitty. Yazi natively handles focusing the file if a file path is passed!
            subprocess.Popen(["kitty", "--class", "yazi-folder", "-e", "yazi", path])

if __name__ == "__main__":
    DBusGMainLoop(set_as_default=True)
    
    try:
        bus = dbus.SessionBus()
        # Request the name. If Nautilus holds it, it might fail, but we'll try to replace it or just own it.
        name = dbus.service.BusName("org.freedesktop.FileManager1", bus)
        manager = FileManager(bus, "/org/freedesktop/FileManager1")
        
        loop = GLib.MainLoop()
        loop.run()
    except Exception as e:
        print(f"Failed to start D-Bus service: {e}", file=sys.stderr)
