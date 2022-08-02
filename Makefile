DEST := result
DEST_BIN := $(DEST)/bin
HOOKS := hooks
INSTALL := /etc/pacman.d
INSTALL_HOOKS := $(INSTALL)/hooks
INSTALL_BIN := $(INSTALL)/hooks.bin
BINS := $(shell basename $$(cabal list-bin .))

.PHONY: build
build: $(patsubst %, $(DEST_BIN)/%, $(BINS))

.PHONY: test
test:
	cabal test

$(DEST_BIN)/%: 
	nix build #.$*

$(INSTALL_BIN)/%: $(DEST_BIN)/%
	cp $(DEST_BIN)/$* $@ 

$(INSTALL_HOOKS)/%:
	cp $(HOOKS)/$* $@

.PHONY: install
install: $(patsubst %, $(INSTALL_BIN)/%, $(BINS)) $(patsubst $(HOOKS)/%, $(INSTALL_HOOKS)/%, $(wildcard $(HOOKS)/*.hook)) 

.PHONY: clean
clean:
	-cabal clean
	-rm -r $(DEST)
	-rm -r dist-newstyle

.PHONY: uninstall
uninstall: install
	find $(DEST_BIN) -type f -exec sh -c 'rm "$(INSTALL_BIN)/$$(basename {})"' \;
	find $(HOOKS) -type f -exec sh -c 'rm "$(INSTALL_HOOKS)/$$(basename {})"' \;
