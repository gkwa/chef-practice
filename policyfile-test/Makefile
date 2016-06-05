ubuntu:
	sh -x run.sh && (cd aar && kitchen converge -p ubuntu-1404)

fedora:
	sh -x run.sh && (cd aar && kitchen converge -p fedora-23)

freebsd:
	sh -x run.sh && (cd aar && kitchen converge -p freebsd-9)

all:
	sh -x run.sh && (cd aar && kitchen converge -p)

template:
	sh -x run.sh

readme: README.md
README.md: README.org
	docker run -v `pwd`:/source jagregory/pandoc --from=org --to=markdown --output=$@ $<
	doctoc --gitlab --title '' $@
