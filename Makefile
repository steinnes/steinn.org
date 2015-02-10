blog:
	hugo

push: blog
	cd public && git add -A
	cd public && git commit -a -m 'rebuilding site'
	cd public && git push origin master

server:
	hugo server --buildDrafts --watch

.phony: blog
