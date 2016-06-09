ubuntu1:
	# just to generate Vagrantfile:
	./run.sh && (cd aar/cookbooks/motd_rhel && kitchen converge -p ubuntu-1404)
	find . -iname vagrantfile | grep \.kitchen | xargs -I{} cp -v {} ./aar/cookbooks/motd_rhel/
	(cd ./aar/cookbooks/motd_rhel && \
		kitchen destroy all && \
		vagrant up)
# vagrant ssh --command 'sudo chef-client -c /tmp/vagrant-chef/client.rb -o motd_rhel'
# https://manage.chef.io/organizations/streambox/cookbooks

ubuntu:
	./run.sh && (cd aar/cookbooks/motd_rhel && kitchen converge -p ubuntu-1404)

fedora:
	./run.sh && (cd aar && kitchen converge -p fedora-23)

freebsd:
	./run.sh && (cd aar && kitchen converge -p freebsd-9)

all:
	./run.sh && (cd aar && kitchen converge -p)

clean:
	rm -rf aar

t: template
template:
	./run.sh

readme: README.md
README.md: README.org
	docker run -v `pwd`:/source jagregory/pandoc --from=org --to=markdown --output=$@ $<
	doctoc --gitlab --title '' $@
