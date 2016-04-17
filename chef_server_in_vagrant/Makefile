test:
	sh run.sh

clean:
	find tmp -name Vagrantfile | xargs -n1 dirname | while read dir; do (cd $$dir && vagrant destroy --force); done;
	rm -rf tmp

veryclean:
	rm -f chef-server-*_*_*.deb

readme: README.md
README.md: README.org
	docker run -v `pwd`:/source jagregory/pandoc --from=org --to=markdown --output=$@ $<
	doctoc --title '**Topic branches**' $@
