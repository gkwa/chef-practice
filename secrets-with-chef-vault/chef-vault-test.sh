#!/bin/bash

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
# mkdir -p chef-vault-test
rm -rf $repo

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
chef -v &

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
chef generate repo $repo >/dev/null
cd $repo

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
chef generate cookbook --email taylor.monacelli@streambox.com cookbooks/test >/dev/null

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife data bag list | grep mydatabag | gxargs -r -n1 knife data bag delete --yes
knife client list | grep taytestnode | gxargs -r -n1 knife client delete --yes
knife client list
knife vault list | grep credentials | gxargs -r -n1 knife data bag delete --yes
knife vault list --mode client
knife node list | grep taytestnode | gxargs -r -n1 knife node delete --yes

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife node create taytestnode --disable-editing --yes
knife node list
knife client create taytestnode --file taytestnode.key --disable-editing --yes

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife client key show taytestnode default
knife vault list --mode client

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife user list
knife user key list mtm1
knife user key show mtm1 default

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife vault list | grep credentials | gxargs -r -n1 knife data bag delete --yes

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife vault create credentials database --search "name:taytestnode" --json ./database.json

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
pass=$(mkpasswd -m sha-512 mypass)
cat <<__EOT__ >database.json
{
    "db_password": "$pass"
}
__EOT__

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife upload data_bags

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife data bag show credentials
knife data bag show credentials database_keys
knife data bag show credentials database_keys --format json
knife vault show credentials database --format json
knife vault show credentials database --format json --mode client

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife data bag show --format json credentials database
knife vault show credentials database --format json
knife vault show credentials database --format json --mode client # requires that you did 'knife upload data_bags'

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
knife data bag show credentials database

repo=$(cat <<'BABEL_TABLE'
chef-vault-test
BABEL_TABLE
)
set +e
knife data bag show credentials database --secret-file taytestnode.key --verbose --verbose
knife data bag show credentials database --secret-file taytestnode.key
knife data bag show credentials database --secret-file ~/.chef/mtm1.pem
knife data bag show credentials database --verbose
knife data bag show credentials database --verbose --verbose
set -e
