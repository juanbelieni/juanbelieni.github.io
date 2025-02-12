serve:
	hugo serve --buildDrafts --buildFuture

serve-prod:
	hugo --minify
	miniserve public

post name:
	hugo new posts/{{name}}/index.md

event name: 
	hugo new events/{{name}}/index.md

project name: 
	hugo new projects/{{name}}/index.md

cspell:
	cspell content/posts/**/*.md

update-theme:
	hugo mod get -u
