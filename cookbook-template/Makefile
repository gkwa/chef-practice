repo=chef-repo
cookbook=mycookbok

generate:
	sh -x generate.sh $(repo) $(cookbook)

converge: $(repo)/cookbooks/$(cookbook)
	cd $< && kitchen converge ubuntu

destroy: $(repo)/cookbooks/$(cookbook)
	cd $< && kitchen destroy all

$(repo)/cookbooks/$(cookbook):
	$(MAKE) generate $(repo) $(cookbook)

readme: README.md
README.md: README.org
	docker run -v `pwd`:/source jagregory/pandoc --from=org --to=markdown --output=$@ $<
	doctoc --gitlab --title '' $@

clean:
	rm -rf $(repo)
