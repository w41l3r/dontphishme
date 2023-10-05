#!/bin/bash
#
# Dontphishme! - v0.2
#
# w41l3r
#
# bash script based on the really-nice article by Nicholas Anastasi:
# https://www.sprocketsecurity.com/resources/never-had-a-bad-day-phishing-how-to-set-up-gophish-to-evade-security-controls

echo
echo "╔╦╗┌─┐┌┐┌┌┬┐┌─┐┬ ┬┬┌─┐┬ ┬┌┬┐┌─┐"
echo " ║║│ ││││ │ ├─┘├─┤│└─┐├─┤│││├┤"
echo "═╩╝└─┘┘└┘ ┴ ┴  ┴ ┴┴└─┘┴ ┴┴ ┴└─┘"
echo "v0.1"
echo

CUSTOMDIR="gophish-custom-`date +%d%m%y%H%M%S`"

function printErrorExit() {
        echo "Error modifying gophish file... bye!"
        exit 1
}

if [ $# -ne 1 ];then
	echo "Syntax: $0 gophish_folder"
	exit 9
fi

GOPHISHDIR=$1

if [ ! -s "${GOPHISHDIR}/gophish.go" ];then
	echo "The informed gophish directory doesn't look like Gophish..."
	exit 1
fi

echo "Creating custom gophish directory on $PWD ..."
sudo cp -rp $GOPHISHDIR $CUSTOMDIR
if [ $? -ne 0 ];then
	echo "Error creating custom gophish dir... bye!"
	exit 1
fi

###Removing gophish stuff from codes
cd $CUSTOMDIR
sudo sed -i.bkp 's/X-Gophish-Contact/X-TotallyRealSMTPD-Contact/g' models/email_request.go || printErrorExit
sudo sed -i.bkp 's/X-Gophish-Contact/X-TotallyRealSMTPD-Contact/g' models/email_request_test.go || printErrorExit
sudo sed -i.bkp 's/X-Gophish-Contact/X-TotallyRealSMTPD-Contact/g' models/maillog.go || printErrorExit
sudo sed -i.bkp 's/X-Gophish-Contact/X-TotallyRealSMTPD-Contact/g' models/maillog_test.go || printErrorExit
sudo sed -i.bkp 's/X-Gophish-Signature/X-TotallyRealSMTPD-Signature/g' webhook/webhook.go || printErrorExit
sudo sed -i.bkp 's/ServerName = "gophish"/ServerName = "IGNORE"/g' config/config.go || printErrorExit
sudo sed -i.bkp 's/const RecipientParameter = "rid"/const RecipientParameter = "keyname"/g' models/campaign.go || printErrorExit

###creating a "not a Gophish server" 404 page
sudo mv controllers/phish.go controllers/phish.go.bkp
sudo wget --quiet -P controllers/ https://github.com/puzzlepeaches/sneaky_gophish/raw/main/files/phish.go
if [ $? -ne 0 ];then
	echo "Error downloading phish.go - This is not critical but you should consider solving that.."
	echo "Try manually downloading https://github.com/puzzlepeaches/sneaky_gophish/raw/main/files/phish.go into controllers dir."
	sudo mv controllers/phish.go.bkp controllers/phish.go
	echo "Continue..."
fi
#echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/strict.dtd">' > /tmp/404.html
#echo '<HTML><HEAD><TITLE>Not Found</TITLE>' >> /tmp/404.html
#echo '<META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD>' >> /tmp/404.html
#echo '<BODY><h2>Not Found</h2>' >> /tmp/404.html
#echo '<hr><p>HTTP Error 404. The requested resource is not found.</p>' >> /tmp/404.html
#echo '</BODY></HTML>' >> /tmp/404.html
#sudo mv /tmp/404.html templates/404.html 
sudo wget --quiet -P templates/ https://github.com/puzzlepeaches/sneaky_gophish/raw/main/files/404.html

echo
echo "#############################################"
echo "Everything Ready! You should now:"
echo "---------------------------------"
echo "sudo apt update"
echo "sudo apt install golang"
echo "cd $PWD"
echo "go build"
echo "./gophish"
echo "#############################################"
echo
echo "have a nice day!"
echo
exit 0
