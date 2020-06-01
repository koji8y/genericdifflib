post_stub:
	@for d in ${STUB_TARGET}; do for p in $${d}/*.pyi.patch; do if test -f "$$p"; then \
		patch -p1 < $$p; \
	fi; done; done
