# http://stackoverflow.com/a/34060720/1495086

set +e

repo=${0%%.sh}

chef -v

rm -rf $repo
chef generate repo $repo >/dev/null
cd $repo

chef generate cookbook --email taylor.monacelli@streambox.com cookbooks/test >/dev/null

knife data bag list | grep mydatabag |
	gxargs -r -n1 knife data bag delete --yes

openssl rand -base64 512 | tr -d '\r\n' >/tmp/encrypted_data_bag_secret

mkdir -p data_bags
knife data bag create mydatabag secretstuff \
	  --secret-file /tmp/encrypted_data_bag_secret --disable-editing --local-mode

mkdir -p data_bags/mydatabag

cat <<__EOT__ >data_bags/mydatabag/secretstuff.json
{
  "id": "secretstuff",
  "firstsecret": "must remain secret",
  "secondsecret": "also very secret"
}
__EOT__

knife data bag from file mydatabag data_bags/mydatabag/secretstuff.json \
	  --secret-file /tmp/encrypted_data_bag_secret --local-mode
knife data bag show mydatabag secretstuff --local-mode

cat <<__EOT__ >cookbooks/test/recipes/test.rb
decrypted = data_bag_item('mydatabag', 'secretstuff', IO.read('/tmp/encrypted_data_bag_secret'))
log "firstsecret: #{decrypted['firstsecret']}"
log "secondsecret: #{decrypted['secondsecret']}"
__EOT__

# fails without --disable-config since ~/.chef/knife.rb has
# cookbook_path pointing elsewhere
# chef-client --local-mode --override-runlist 'recipe[test::test]'
chef-client --disable-config --local-mode --override-runlist 'recipe[test::test]'
