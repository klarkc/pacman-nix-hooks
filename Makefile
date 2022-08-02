HOOKS := hooks
BIN := bin
INSTALL := /etc/pacman.d
INSTALL_HOOKS := $(INSTALL)/hooks
INSTALL_BIN := $(INSTALL)/hooks.bin

.PHONY: all
all: test build

.PHONY: test
test:
	cabal test

.PHONY: cabal-build
cabal-build: 
	cabal build
	-mkdir -p $$(basename $(BIN))
	cabal install --installdir $(BIN) --overwrite-policy=always

.PHONY: build
build: cabal-build

$(INSTALL_HOOKS)/%:
	-mkdir -p $(shell dirname $@)
	cp $(HOOKS)/$* $@

$(INSTALL_BIN)/%: build
	-mkdir -p $(shell dirname $@)
	cp -L $(BIN)/$* $@

.PHONY: install
install: $(patsubst $(BIN)/%, $(INSTALL_BIN)/%, $(wildcard $(BIN)/*)) $(patsubst $(HOOKS)/%, $(INSTALL_HOOKS)/%, $(wildcard $(HOOKS)/*.hook))

.PHONY: clean
clean:
	-cabal clean
	-rm -r dist-newstyle
	-rm -r $(BIN)

.PHONY: uninstall
uninstall:
	find $(HOOKS) -type f -exec sh -c 'rm "$(INSTALL_HOOKS)/$$(basename {})"' \;
	find -L $(BIN) -type f -exec sh -c 'rm "$(INSTALL_BIN)/$$(basename {})"' \;
