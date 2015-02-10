blog:
	hugo

push: blog
	git add -A
	git commit -a -m 'rebuilding site'
	git push origin master
	git subtree push --prefix=public git@github.com:steinnes/steinnes.github.io.git gh-pages


server:
	hugo server --buildDrafts --watch

.phony: blog
