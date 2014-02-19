
PREFIX ?= /usr/local
BIN = pipe-logger


install: $(BIN)
	@cp $^ $(PREFIX)/bin

uninstall:
	rm $(PREFIX)/bin/$(BIN)


.PHONY: install uninstall

