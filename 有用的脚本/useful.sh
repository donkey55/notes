
# 申请证书的域名
domain=example.com
# acme 申请证书
acme.sh --issue -d ${domain} --standalone -k ec-256 --server letsencrypt

acme.sh --installcert -d ${domain} --fullchainpath /xx/xx/${domain}.crt --keypath /xx/xx/${domain}.key --ecc >/dev/null


lsof 