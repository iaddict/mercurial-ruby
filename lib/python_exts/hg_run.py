import os
import sys
import re
import shlex
import StringIO

libdir = '@LIBDIR@'

if libdir != '@' 'LIBDIR' '@':
    if not os.path.isabs(libdir):
        libdir = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                              libdir)
        libdir = os.path.abspath(libdir)
    sys.path.insert(0, libdir)

# enable importing on demand to reduce startup time
try:
    from mercurial import demandimport; demandimport.enable()
except ImportError:
    import sys
    sys.stderr.write("abort: couldn't find mercurial libraries in [%s]\n" %
                     ' '.join(sys.path))
    sys.stderr.write("(check your install and PYTHONPATH)\n")

import mercurial.util
import mercurial.dispatch as dispatch
from mercurial.localrepo import localrepository
from mercurial.ui import ui

def run(command):
  fout = StringIO.StringIO()
  ferr = StringIO.StringIO()
  
  match = re.match(r"cd (.*) && (.*)", command)
  request = shlex.split(match.group(2))[1:]
  repo_path = match.group(1)
  request.append('--repository')
  request.append(repo_path)
  
  dispatch.dispatch(dispatch.request(request, None, None, None, fout, ferr))
  
  fout_value = fout.getvalue()
  ferr_value = ferr.getvalue()
  
  fout.close()
  ferr.close()
  
  if ferr_value == '':
    return [False, fout_value]
  else:
    return [True, ferr_value]
