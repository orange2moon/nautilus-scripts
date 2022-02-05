SCRIPTS_FOLDER_DEST=$(HOME)/.local/share/nautilus/scripts
PREFIX=$(HOME)/.local
install:
	mkdir -p $(SCRIPTS_FOLDER_DEST)
	mkdir -p $(PREFIX)/share/plugins/settings
	mkdir -p $(PREFIX)/bin
	install scripts-folder/* $(SCRIPTS_FOLDER_DEST)
	install local/bin/* $(PREFIX)/bin/
	install -m 0644 local/share/plugins/settings/* $(PREFIX)/share/plugins/settings/
