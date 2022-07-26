DEST := result
DEST_BIN := $(DEST)/bin
INSTALL_BIN := /etc/pacman.d/hooks.bin

.PHONY: build
build:
	nix build

$(DEST_BIN)/%: 
	nix build \#.$*

$(INSTALL_BIN)/%: $(DEST_BIN)/%
	cp $@ $(INSTALL_BIN)

.PHONY: install
install: $(patsubst %, $(INSTALL_BIN)/%, $(shell basename $$(cabal list-bin .)))

.PHONY: clean
clean:
	rm -rf $(DEST)
	rm -rf dist-newstyle

.PHONY: uninstall
uninstall: install
	find $(DEST_BIN) -type f -exec sh -c 'rm "$(INSTALL_BIN)/$$(basename {})"' \;
