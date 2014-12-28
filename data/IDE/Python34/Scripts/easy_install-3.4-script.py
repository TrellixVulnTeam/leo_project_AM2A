#!v:\IDE\Python34\python.exe
# EASY-INSTALL-ENTRY-SCRIPT: 'setuptools==6.0.2','console_scripts','easy_install-3.4'
__requires__ = 'setuptools==6.0.2'
import sys
from pkg_resources import load_entry_point

if __name__ == '__main__':
    sys.exit(
        load_entry_point('setuptools==6.0.2', 'console_scripts', 'easy_install-3.4')()
    )
