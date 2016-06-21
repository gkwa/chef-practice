#!/bin/sh

repo=${0%.sh}

cat <<EOF
# links to helpful sources
https://github.com/chef/chef-vault/blob/master/THEORY.md
EOF

set +e

chef -v &

rm -rf $repo
chef generate repo $repo >/dev/null
cd $repo

chef generate cookbook --email taylor.monacelli@streambox.com cookbooks/test >/dev/null

knife data bag list | grep mydatabag |
	gxargs -r -n1 knife data bag delete --yes

# Clean out old test runs
knife client list | grep taytestnode | gxargs -r -n1 knife client delete --yes
knife client list
knife vault list | grep credentials | gxargs -r -n1 knife data bag delete --yes
knife vault list --mode client
knife node list | grep taytestnode | gxargs -r -n1 knife node delete --yes

knife node create taytestnode --disable-editing --yes
knife node list
knife client create taytestnode --file taytestnode.key --disable-editing --yes

# https://docs.chef.io/knife_client.html
knife client key show taytestnode default
knife vault list --mode client

pass=$(mkpasswd -m sha-512 mypass)
cat <<__EOT__ >database.json
{
	"db_password": "$pass"
}
__EOT__

knife user list
knife user key list mtm1
knife user key show mtm1 default

knife vault list | grep credentials | gxargs -r -n1 knife data bag delete --yes
knife vault create credentials database --search "name:taytestnode" --json ./database.json
knife upload data_bags

knife data bag show credentials
# fixme: how can we use knife vault instead of knife data bag to show
# which clients/users can decrypt?
knife data bag show credentials database_keys
knife data bag show credentials database_keys --format json
knife vault show credentials database --format json
knife vault show credentials database --format json --mode client

knife data bag show --format json credentials database
knife vault show credentials database --format json
knife vault show credentials database --format json --mode client # requires that you did 'knife upload data_bags'

knife data bag show credentials database

knife data bag show credentials database --secret-file taytestnode.key --verbose --verbose
knife data bag show credentials database --secret-file taytestnode.key
knife data bag show credentials database --secret-file ~/.chef/mtm1.pem
knife data bag show credentials database --verbose
knife data bag show credentials database --verbose --verbose
