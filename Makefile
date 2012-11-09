# === Makefile ------------------------------------------------------------===
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

ROOT=$(shell pwd)
CACHE_ROOT=${ROOT}/.cache
PKG_ROOT=${ROOT}/.pkg
PACKAGE_NAME=django_pgmp
APP_NAME=django-pgmp

-include Makefile.local

.PHONY: all
all: ${PKG_ROOT}/.stamp-h vmup

.PHONY: check
check: all
	mkdir -p "${ROOT}"/build/report
	"${PKG_ROOT}"/bin/python -Wall "${ROOT}"/manage.py test \
	  --settings=tests.settings \
	  --with-xunit \
	  --xunit-file="${ROOT}"/build/report/xunit.xml \
	  --with-xcoverage \
	  --xcoverage-file="${ROOT}"/build/report/coverage.xml \
	  --cover-package=${PACKAGE_NAME} \
	  --cover-erase \
	  --cover-tests \
	  --cover-inclusive \
	  ${PACKAGE_NAME}

.PHONY: shell
shell: db
	"${PKG_ROOT}"/bin/python "${ROOT}"/manage.py shell_plusplus \
	  --settings=tests.settings \
	  --print-sql \
	  --ipython

.PHONY: mostlyclean
mostlyclean:
	-rm -rf dist
	-rm -rf build
	-rm -rf .coverage

.PHONY: clean
clean: mostlyclean vmdestroy
	-rm -rf "${PKG_ROOT}"

.PHONY: distclean
distclean: clean
	-rm -rf "${CACHE_ROOT}"
	-rm -rf Makefile.local

.PHONY: maintainer-clean
maintainer-clean: distclean
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'

.PHONY: dist
dist:
	"${PKG_ROOT}"/bin/python setup.py sdist

# ===--------------------------------------------------------------------===

.PHONY: db
db: all
	"${PKG_ROOT}"/bin/python "${ROOT}"/manage.py syncdb \
	  --settings=tests.settings

.PHONY: dbshell
dbshell: db
	"${PKG_ROOT}"/bin/python "${ROOT}"/manage.py dbshell \
	  --settings=tests.settings

.PHONY: dbssh
dbssh: db
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant ssh postgres

# ===--------------------------------------------------------------------===

.PHONY: vmup
vmup: ${PKG_ROOT}/.stamp-h
	RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant up
	PGPASSWORD=password psql -h localhost -U django -c "SELECT TRUE;" || \
	RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant reload

.PHONY: vmsuspend
vmsuspend: ${PKG_ROOT}/.stamp-h
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant suspend

.PHONY: vmresume
vmresume: ${PKG_ROOT}/.stamp-h
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant resume

.PHONY: vmreload
vmreload: ${PKG_ROOT}/.stamp-h
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant reload

.PHONY: vmdestroy
vmdestroy:
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec \
	    vagrant destroy --force

# ===--------------------------------------------------------------------===

${CACHE_ROOT}/virtualenv/virtualenv-1.8.2.tar.gz:
	mkdir -p "${CACHE_ROOT}"/virtualenv
	sh -c "cd "${CACHE_ROOT}"/virtualenv && curl -O 'http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.8.2.tar.gz'"

${CACHE_ROOT}/rbenv/rbenv-0.3.0.tar.gz:
	mkdir -p ${CACHE_ROOT}/rbenv
	curl -L 'https://nodeload.github.com/sstephenson/rbenv/tar.gz/v0.3.0' >'$@'

${CACHE_ROOT}/rbenv/ruby-build-20120815.tar.gz:
	mkdir -p ${CACHE_ROOT}/rbenv
	curl -L 'https://nodeload.github.com/sstephenson/ruby-build/tar.gz/v20120815' >'$@'

${PKG_ROOT}/.stamp-h: ${ROOT}/conf/requirements.* ${CACHE_ROOT}/virtualenv/virtualenv-1.8.2.tar.gz ${CACHE_ROOT}/rbenv/rbenv-0.3.0.tar.gz ${CACHE_ROOT}/rbenv/ruby-build-20120815.tar.gz
	# Because build and run-time dependencies are not thoroughly tracked,
	# it is entirely possible that rebuilding the development environment
	# on top of an existing one could result in a broken build. For the
	# sake of consistency and preventing unnecessary, difficult-to-debug
	# problems, the entire development environment is rebuilt from scratch
	# everytime this make target is selected.
	${MAKE} clean
	
	# The ``${PKG_ROOT}`` directory, if it exists, is removed by the
	# ``clean`` target. The PyPI cache is nonexistant if this is a freshly
	# checked-out repository, or if the ``distclean`` target has been run.
	# This might cause problems with build scripts executed later which
	# assume their existence, so they are created now if they don't
	# already exist.
	mkdir -p "${PKG_ROOT}"
	mkdir -p "${CACHE_ROOT}"/pypi
	
	# ``virtualenv`` is used to create a separate Python installation for
	# this project in ``${PKG_ROOT}``.
	tar \
	  -C "${CACHE_ROOT}"/virtualenv --gzip \
	  -xf "${CACHE_ROOT}"/virtualenv/virtualenv-1.8.2.tar.gz
	python "${CACHE_ROOT}"/virtualenv/virtualenv-1.8.2/virtualenv.py \
	  --clear \
	  --distribute \
	  --never-download \
	  --prompt="(${APP_NAME}) " \
	  "${PKG_ROOT}"
	rm -rf "${CACHE_ROOT}"/virtualenv/virtualenv-1.8.2
	
	# readline is installed here to get around a bug on Mac OS X which is
	# causing readline to not build properly if installed from pip.
	"${PKG_ROOT}"/bin/easy_install readline
	
	# pip is used to install Python dependencies for this project.
	for reqfile in "${ROOT}"/conf/requirements*.pip; do \
	  "${PKG_ROOT}"/bin/python "${PKG_ROOT}"/bin/pip install \
	    --download-cache="${CACHE_ROOT}"/pypi \
	    -r "$$reqfile"; \
	done
	
	# rbenv (and its plugins, ruby-build and rbenv-gemset) is used to build,
	# install, and manage ruby environments:
	tar \
	    -C "${PKG_ROOT}" --strip-components 1 --gzip \
	    -xf "${CACHE_ROOT}"/rbenv/rbenv-0.3.0.tar.gz
	mkdir -p "${PKG_ROOT}"/plugins/ruby-build
	tar \
	    -C "${PKG_ROOT}"/plugins/ruby-build --strip-components 1 --gzip \
	    -xf "${CACHE_ROOT}"/rbenv/ruby-build-20120815.tar.gz
	
	# Trigger a build and install of our required ruby version:
	- CONFIGURE_OPTS=--with-openssl-dir=$(shell which openssl | sed -e s:/bin/openssl::) \
	  RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv install 1.9.3-p194
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv rehash
	echo 1.9.3-p194 >.rbenv-version
	
	# Install bundler & gemset dependencies:
	RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec gem install bundler
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv rehash
	RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle install
	- RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv rehash
	
	# Fetch Chef cookbooks
	RBENV_ROOT="${PKG_ROOT}" "${PKG_ROOT}"/bin/rbenv exec bundle exec librarian-chef install
	
	# All done!
	touch "${PKG_ROOT}"/.stamp-h

# ===--------------------------------------------------------------------===
# End of File
# ===--------------------------------------------------------------------===
