#!v:\IDE\Python34\pythonw.exe
# EASY-INSTALL-ENTRY-SCRIPT: 'leo==4.11-final','gui_scripts','leo'
__requires__ = 'leo==4.11-final'
import sys
from pkg_resources import load_entry_point

if __name__ == '__main__':
    sys.exit(
        load_entry_point('leo==4.11-final', 'gui_scripts', 'leo')()
    )
