t3:
	sh -x run.sh && (cd aar && kitchen converge -p freebsd-9)

t2:
	sh -x run.sh && (cd aar && kitchen converge -p ubuntu-14.04)

t1:
	sh -x run.sh

readme: README.md
README.md: README.org
	docker run -v `pwd`:/source jagregory/pandoc --from=org --to=markdown --output=$@ $<
	doctoc --gitlab --title '' $@
