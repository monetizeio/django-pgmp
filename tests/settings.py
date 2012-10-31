#!/usr/bin/env python
# -*- coding: utf-8 -*-

# === tests.settings ------------------------------------------------------===
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

# Import the default test settings provided by django_patterns.
from django_patterns.test.project.settings import *

import dj_database_url
DATABASES = {
    'default': dj_database_url.config(
        default='postgres://django:password@localhost:5432/django')
}

# Use django_patterns to detect embedded Django test applications, and add
# them to our INSTALLED_APPS.
from django_patterns.test.discover import discover_test_apps
apps = discover_test_apps('django_pgmp')
if apps:
    for app in apps:
        INSTALLED_APPS += (app,)

# ===----------------------------------------------------------------------===
# End of File
# ===----------------------------------------------------------------------===
