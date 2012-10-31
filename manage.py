#!/usr/bin/env python
# -*- coding: utf-8 -*-

# === manage.py -----------------------------------------------------------===
# This file is part of django-pgpm. django-pgpm is copyright © 2012, RokuSigma
# Inc. and contributors. See AUTHORS and LICENSE for more details.
#
# django-pgpm is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# django-pgpm is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with django-pgpm. If not, see <http://www.gnu.org/licenses/>.
# ===----------------------------------------------------------------------===

import os
import sys

try:
    from django.core.management import execute_from_command_line
except ImportError:
    sys.stderr.write(
        # The following is not transalated because in this particular error
        # condition `sys.path` is probably not setup correctly, and so we
        # cannot be sure that we'd import the translation machinery correctly.
        # It'd be better to print the correct error in English than to trigger
        # another not-so-helpful ImportError.
        u"Error: Can't find the module 'django.core.management' in the "
        u"Python path. Please execute this script from within the virtual "
        u"environment containing your project.\n")
    sys.exit(1)

if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'tests.settings')
    execute_from_command_line(sys.argv)

# ===----------------------------------------------------------------------===
# End of File
# ===----------------------------------------------------------------------===
