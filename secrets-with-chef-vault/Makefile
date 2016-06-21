all: chef-vault-test chef-vault-test2

chef-vault-test:
	sh -x $@.sh 2>&1 | tee $@.out

chef-vault-test2:
	sh -x $@.sh 2>&1 | tee $@.out

clean:
	rm -rf chef-vault-test
	rm -rf chef-vault-test2
	rm -f *.out
