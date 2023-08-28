.PHONY: lint
lint:
	@printf "\nRunning luacheck\n"
	luacheck .
	@printf "\nRunning stylua\n"
	stylua --check .
