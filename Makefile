SCRIPTS_FOLDER_DEST=$(HOME)/.local/share/nautilus/scripts
PREFIX=$(HOME)/.local
install:
	@echo "Destination directories:"
	@echo $(SCRIPTS_FOLDER_DEST)
	@echo $(PREFIX)
	@echo ""
	@echo "Installing the following files into the destination directories:"
	@mkdir -vp $(SCRIPTS_FOLDER_DEST)
	@mkdir -vp $(PREFIX)/share/plugins/settings
	@mkdir -vp $(PREFIX)/bin
	@rsync --info=stats0,misc1,flist0 --out-format="%f%L" -vau scripts-folder/ $(SCRIPTS_FOLDER_DEST)
	@rsync --info=stats0,misc1,flist0 --out-format="%f%L" -vau local/bin/ $(PREFIX)/bin/
	@rsync --info=stats0,misc1,flist0 --out-format="%f%L" -vau local/share/plugins/settings/ $(PREFIX)/share/plugins/settings/
