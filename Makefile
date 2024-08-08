SCRIPTS_FOLDER_DEST=$(HOME)/.local/share/nautilus/scripts
RSYNC= rsync --info=stats0,misc1,flist0 --out-format="%f%L" -vau

notice:
	@echo "Installing nautilus scripts"
	@echo "Destination directorie:"
	@echo $(SCRIPTS_FOLDER_DEST)
	@echo ""

image: notice
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

pdf: notice
	@mkdir -vp $(SCRIPTS_FOLDER_DEST)

	###### PDF #####
	@$(RSYNC) "scripts/01-pdf-merge" $(SCRIPTS_FOLDER_DEST)
	@$(RSYNC) "scripts/01-pdf-rotate-90" $(SCRIPTS_FOLDER_DEST)


