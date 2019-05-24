all: serve

update-hugo-themes:
	git submodule update --init

dependencies: update-hugo-themes
	sudo dnf install hugo
	sudo dnf install asciidoctor

serve:
	cd gh-pages-generator && hugo serve --verbose --buildDrafts

# Github pages and hugo compiler treat asciidoc 'imagesdir' differently
gh-pages-fix-urls:
	find ./public/posts -type f -name "*.html" -print0 | xargs -0 sed -i 's src="./images/ src="/blog/images/ g '

gh-pages-generate:
	rm -rf public/*
	cd gh-pages-generator && hugo

gh-pages-dry-run: gh-pages-generate gh-pages-fix-urls

# Docs: https://gohugo.io/hosting-and-deployment/hosting-on-github/
gh-pages-publish:
	./publish_to_ghpages.sh


