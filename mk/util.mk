include env.mk
include mk/prepare.mk

# The following environment can be set in env.mk:
# ENV: str - Relative directory for virtual env.
ifndef ENV
ENV=.env
endif
# IPYNB_PORT: int - Port number for jupyter notebook.
ifndef IPYNB_PORT
IPYNB_PORT=8888
endif
# ENV_PROMPT: str - Prompt to display while in virtual env.
ifndef ENV_PROMPT
ENV_PROMPT=${ENV}
endif
# NO_TYPECHECK: str - Regular expression of files not to check types.
ifndef NO_TYPECHECK
NO_TYPECHECK='setup.py'
endif
# ADDITIONAL_TOP_TO_FIND_SRC: str - Space separated directories
#                                   from where to find code.
ifndef ADDITIONAL_TOP_TO_FIND_SRC
ADDITIONAL_TOP_TO_FIND_SRC=
endif
# STUB_TARGET: str - Space separated directories of *.py files
#                    for which  to generate stub (*.pyi).
ifndef STUB_TARGET
STUB_TARGET=
endif
# POST_STUB: str - The name of make target to be invoked after mksing stub.
ifndef POST_STUB
POST_STUB=
endif

FLAKE_OPT=--ignore=E101,E111,E121,E123,E126,E127,E128,E129,E201,E202,E203,E211,E214,E221,E222,E225,E226,E231,E241,E251,E261,E262,E265,E266,E271,E272,E301,E302,E303,E305,E306,E501,E701,E704,E722,E741,F401,F841,H101,H306,H403,H405,W191,W291,W293,W391,W503,W504

env_test:
	@echo "IPYNB_PORT=${IPYNB_PORT}"

help_core:
	@echo "Tragets:"
	@cat Makefile mk/util.mk | awk -F: '/^[A-Za-z][^=:]*:/ {print $$1}' | sed -e 's/^/ - /'

help: help_core
	@true

env:
	@case "${VIRTUAL_ENV}" in \
	  */${ENV}) \
		;; \
	  "") \
		if ! test -d ${ENV}; then \
			python3 -m venv --prompt ${ENV_PROMPT} ${ENV}; \
		fi; \
		echo "Do 'source ${ENV}/bin/activate'"; \
		;; \
	  *) \
		echo "Do 'deactivate' first for env ${ENV}"; \
		;; \
	esac

_check_env:
	@case "${VIRTUAL_ENV}" in \
	  */${ENV}) \
		if ! python3 -m pip list --format columns | grep pip-autoremove > /dev/null; then \
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
		echo "Do 'deactivate' first for env ${ENV}."; \
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

_prepare_pkg_wo_check_env: prepare_specific
	@$(pip3) install --upgrade pip setuptools wheel pip-autoremove
	@$(pip3) install --upgrade \
		mypy \
		flake8 \
		pylint \
		debtcollector
	@${pip3} install --upgrade -r requirements.txt

prepare_specific:
	@if test -n "${PREPARE_SPECIFIC}"; then \
		$(MAKE) -f Makefile ${PREPARE_SPECIFIC}; \
	fi

check_wellformed: flake_core typecheck

check_quality: check_wellformed lint flake

flake_core: _check_env
	@flake8 ${FLAKE_OPT} $$(make -s _find_py | grep -v setup.py)

flake: _check_env
	@flake8 $$(make -s _find_py | grep -v setup.py)

typecheck: _check_env
	@env MYPYPATH=$$PYTHONPATH mypy $$(make -s _find_py | grep -v ${NO_TYPECHECK})

lint: _check_env
	@pylint $$(make -s _find_py | grep -v setup.py)

_find_py:
	@find . ${ADDITIONAL_TOP_TO_FIND_SRC} \
	  -name ${ENV} -prune -o \
	  -name "tmp" -prune -o \
	  -name "petstore_client" -prune -o \
	  -name "gitlab_client" -prune -o \
	  -name "build" -prune -o \
	  -name "*.py" \
	  -print

_find_src:
	@find . ${ADDITIONAL_TOP_TO_FIND_SRC} \
	  -name ${ENV} -prune -o \
	  -name "tmp" -prune -o \
	  -name "petstore_client" -prune -o \
	  -name "gitlab_client" -prune -o \
	  -name "build" -prune -o \
	  -name .ipynb_checkpoints -prune -o \
	  -name "tmp*" -prune -o \
	  \( \
	    -name "*.py" \
	    -o \
	    -name "*.ipynb" \
	  \) \
	  -exec echo "'{}'" \;

test: _check_env
	@python3 -m testcmd --locals

notebook: _check_env
	@env PYTHONPATH="$$PYTHONPATH:$$PWD:$${VIRTUAL_ENV+$$(echo $${VIRTUAL_ENV}/lib/*/site-packages/):}" jupyter-notebook --ip=0.0.0.0 --port=${IPYNB_PORT} > ${ENV}/jupyter-notebook.log --no-browser 2>&1 &
	@(sleep 2; tail ${ENV}/jupyter-notebook.log; echo See ${ENV}/jupyter-notebook for more logs) &

set_password_for_notebook:
	@mkdir -p ${HOME}/.jupyter
	jupyter-notebook password

open_notebook: notebook

close_notebook: _check_env
	@if test -n "$$(jupyter-notebook list | fgrep $$(pwd -P))"; then \
		proc_num=$$(ps x | grep -v awk | awk '/jupyter-notebook/ {print $$1}'); \
		if test -n "$$proc_num"; then \
			kill $$proc_num; \
		fi \
	else \
		echo "No server for notebook runs"; \
	fi

wait_until_notebook_closed: _check_env
	@while test -n "$$(jupyter-notebook list | fgrep $$(pwd -P))"; do \
		echo "waiting notebook is closed..."; \
		sleep 1; \
	done
	@while test -n "$$(netstat -an | fgrep -i listen | grep '[.:]${IPYNB_PORT}\>')"; do \
		echo "waiting port ${IPYNB_PORT} is closed..."; \
		sleep 1; \
	done

restart_notebook: close_notebook wait_until_notebook_closed open_notebook

reopen_notebook: restart_notebook

list_notebook: _check_env
	jupyter-notebook list

mkpkg: _check_env clean_pkg stub
	@python3 -m setup bdist_wheel

clean_pkg: _check_env
	@rm -rf *.egg-info build

stub: _check_env
	@if test -z "${STUB_TARGET}"; then \
		echo "No STUB_TARGET folder is specified."; \
		exit 1; \
	fi
	@for d in ${STUB_TARGET}; do if ! test -d "$${d}"; then \
		echo "No such directory $$d"; \
		exit 1; \
	fi; done
	@find ${STUB_TARGET} -name "*.pyi" -exec rm -f {} \;
	@rm -f *.pyi
	@stubgen -o . ${STUB_TARGET}
	@if test -n "${POST_STUB}"; then \
		$(MAKE) -f Makefile ${POST_STUB}; \
	fi
