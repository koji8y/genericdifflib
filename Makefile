FLAKE_OPT=--ignore=E101,E111,E121,E123,E126,E127,E128,E129,E201,E202,E203,E211,E214,E221,E222,E225,E226,E231,E241,E251,E261,E262,E265,E266,E271,E272,E301,E302,E303,E305,E306,E501,E701,E704,E722,E741,F401,F841,H101,H306,H403,H405,W191,W291,W293,W391,W503,W504
ENV=.env

ifndef python3
python3=python3
endif
pip3=${python3} -m pip $${http_proxy:+--proxy $${http_proxy}}

all: help
help:
	@echo "Tragets:"
	@cat Makefile | awk -F: '/^[A-Za-z][^=:]*:/ {print $$1}' | sed -e 's/^/- /'

env:
	@case "${VIRTUAL_ENV}" in \
	  */${ENV}) \
		;; \
	  "") \
		if ! test -d ${ENV}; then \
			python3 -m venv --prompt genericdiff ${ENV}; \
		fi; \
		echo "Do 'source ${ENV}/bin/activate'"; \
		;; \
	  *) \
		echo "Do 'deactivate' first"; \
		;; \
	esac

_check_env:
	@case "${VIRTUAL_ENV}" in \
	  */${ENV}) \
		if ! python3 -m pip list --format columns | grep mypy > /dev/null; then \
			make _prepare_pkg_wo_check_env; \
		fi; \
		;; \
	  *) \
		make env; \
		false; \
		;; \
	esac

update_env:
	@case "${VIRTUAL_ENV}" in \
	  */${ENV}) \
		echo "Do 'deactivate' first."; \
		exit 1 \
		;; \
	  "") \
		;; \
	  *) \
		echo "You are in any other venv environment."; \
		exit 1 \
		;; \
	esac
	${python3} -m venv ${ENV} --upgrade

prepare_pkg: _check_env _prepare_pkg_wo_check_env

_prepare_pkg_wo_check_env:
	@${pip3} install --upgrade pip
	@${pip3} install -r requirements.txt

check_wellformed: flake_core typecheck

check_quality: check_wellformed lint flake

flake_core: _check_env
	@flake8 ${FLAKE_OPT} $$(make -s _find_py)

flake: _check_env
	@flake8 $$(make -s _find_py)

typecheck: _check_env
	@env MYPYPATH=$$PYTHONPATH mypy $$(make -s _find_py)

lint: _check_env
	@pylint $$(make -s _find_py)

_find_py:
	@find . \
	  -name ${ENV} -prune -o \
	  -type d -name build -prune -o \
	  -type d -name dist -prune -o \
	  -name "*.py" \
	  -print

_find_src:
	@find . \
	  -name ${ENV} -prune -o \
	  -name .ipynb_checkpoints -prune -o \
	  \( \
	    -name "*.py" \
	    -o \
	    -name "*.ipynb" \
	  \) \
	  -exec echo "'{}'" \;

test: _check_env
	@python3 -m testcmd --locals

notebook: _check_env
	@env PYTHONPATH="$$PYTHONPATH:$$PWD:$${VIRTUAL_ENV+$$(echo $${VIRTUAL_ENV}/lib/*/site-packages/):}" jupyter-notebook --ip=0.0.0.0 > ${ENV}/jupyter-notebook.log --no-browser 2>&1 &
	@(sleep 2; tail ${ENV}/jupyter-notebook.log; echo See ${ENV}/jupyter-notebook for more logs) &

set_password_for_notebook:
	@mkdir -p ${HOME}/.jupyter
	jupyter-notebook password

open_notebook: notebook

close_notebook:
	@if test -n "$$(jupyter-notebook list | fgrep $$(pwd -P))"; then \
		proc_num=$$(ps x | grep -v awk | awk '/jupyter-notebook/ {print $$1}'); \
		if test -n "$$proc_num"; then \
			kill $$proc_num; \
		fi \
	else \
		echo "No server for notebook runs"; \
	fi

wait_until_notebook_closed:
	@while test -n "$$(jupyter-notebook list | fgrep $$(pwd -P))"; do \
		echo "waiting notebook is closed..."; \
		sleep 1; \
	done
	@while test -n "$$(netstat -an | fgrep -i listen | grep '[.:]8888\>')"; do \
		echo "waiting port 8888 is closed..."; \
		sleep 1; \
	done

restart_notebook: close_notebook wait_until_notebook_closed open_notebook

reopen_notebook: restart_notebook

list_notebook:
	jupyter-notebook list

mkpkg: _check_env
	@python3 -m setup bdist_wheel

stub: _check_env
	@stubgen -o . gdifflib
