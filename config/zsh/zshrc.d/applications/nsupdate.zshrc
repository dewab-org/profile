is-executable nsupdate || return

function nsup() {
	echo "
	nsup Examples:
		update delete www.example.com cname
		update add www1.example.com 86400 a 172.16.1.1
		update add www.example.com 600 cname www1.example.com.
		update add 1.1.16.172.in-addr.arpa 86400 ptr www1.example.com.

	"

	nsupdate -k ~/.dnskeys/local.key
}
