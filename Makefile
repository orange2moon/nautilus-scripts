SCRIPTS_FOLDER_DEST=$(HOME)/.local/share/nautilus/scripts
RSYNC= rsync --info=stats0,misc1,flist0 --out-format="%f%L" -vau
LSP_SETTINGS_DEST=$(HOME)/.local/share/plugins/settings/

pdf:
	@echo "Installing pdf scripts"
	@echo "Destination directories:"
	@echo $(SCRIPTS_FOLDER_DEST)
	@echo ""
	@mkdir -vp $(SCRIPTS_FOLDER_DEST)

	###### PDF #####
	@$(RSYNC) "scripts/01-pdf-merge" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/01-pdf-rotate-90" $(SCRIPTS_FOLDER_DEST)

image:
	@echo "Installing image scripts"
	@echo "Destination directories:"
	@echo $(SCRIPTS_FOLDER_DEST)
	@echo ""
	@mkdir -vp $(SCRIPTS_FOLDER_DEST)

	##### IMAGE ####
	@$(RSYNC) "scripts/02-img-rotate-90" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/02-img-to-png" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/02-img-to-jpg" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/03-img-remove-background-1" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/03-img-remove-background-3" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/03-img-remove-background-6" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/03-img-remove-background-9" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/03-img-remove-background-20" $(SCRIPTS_FOLDER_DEST)

audio:
	@echo "Installing audio scripts"
	@echo "Destination directories:"
	@echo $(SCRIPTS_FOLDER_DEST)
	@echo ""
	@mkdir -vp $(SCRIPTS_FOLDER_DEST)
	@mkdir -vp $(LSP_SETTINGS_DEST)

	#### AUDIO ####
	@$(RSYNC) "scripts/04-audio-clean" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/04-audio-clean-no_ai" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/04-audio-clean-no_ai-crisp" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/04-audio-clean-strong-no_ai" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/04-audio-split_stereo" $(SCRIPTS_FOLDER_DEST)

	@$(RSYNC) "lsp-settings/" $(LSP_SETTINGS_DEST)

