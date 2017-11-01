#
# Snotra specific bashrc script
#

alias piup='pssh -h ~/hosts/pis.hosts -t0 -i "sudo apt-get update ; sudo apt-get upgrade -y"'
alias awsup='pssh -h ~/hosts/aws.hosts -t0 -i "sudo yum update -y"'

