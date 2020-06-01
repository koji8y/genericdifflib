include env.mk
include mk/prepare.mk
include local.mk

all: help
	@true

%:
	@$(MAKE) -f mk/util.mk $@
