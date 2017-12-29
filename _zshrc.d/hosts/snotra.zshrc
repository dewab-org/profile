#
# Snotra specific bashrc script
#

alias piup='pssh -h ~/hosts/pis.hosts -t0 -i "sudo apt-get update ; sudo apt-get upgrade -y"'
alias awsup='pssh -h ~/hosts/aws.hosts -t0 -i "sudo yum update -y"'

cdpath=($cdpath /net/bifrost/data/work)

# DNS
alias nslookup='/usr/bin/nslookup -sil'
function nsup() {
echo "
nsup Examples:
	update delete www.example.com cname
	update add www1.example.com 86400 a 172.16.1.1
	update add www.example.com 600 cname www1.example.com.
	update add 1.1.16.172.in-addr.arpa 86400 ptr www1.example.com.

"

nsupdate -y DHCP_UPDATER:pRP5FapFoJ95JEL06sv4PQ==
}
#export -f nsup
