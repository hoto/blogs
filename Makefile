all: serve

serve:
	cd hugo-generator && hugo serve --verbose --buildDrafts

docs:
	cd hugo-generator && hugo

