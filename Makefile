all: serve

serve:
	cd hugo-generator && hugo serve -D -v

docs:
	cd hugo-generator && hugo generate -o docs

