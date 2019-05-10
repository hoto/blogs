all: serve

update-hugo-themes:
	git submodule update --init

dependencies:
	sudo dnf install hugo
	sudo dnf install asciidoctor

serve:
	cd gh-pages-generator && hugo serve --verbose --buildDrafts

gh-pages-generate:
	rm -rf public/*
	cd gh-pages-generator && hugo

# Docs: https://gohugo.io/hosting-and-deployment/hosting-on-github/
gh-pages-release:
	./publish_to_ghpages.sh

