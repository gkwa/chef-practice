repo=userstest
cookbook=my_users

setup:
	sh -x run.sh $(repo) $(cookbook)

converge:
	cd userstest/cookbooks/my_users && kitchen converge ubuntu

login:
	cd userstest/cookbooks/my_users && kitchen login ubuntu

clean:
	rm -rf userstest

readme: README.md
README.md: README.org
	docker run -v `pwd`:/source jagregory/pandoc --from=org --to=markdown --output=$@ $<
	doctoc --title '' $@
