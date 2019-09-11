#!/usr/bin/env bash
# Simple GoPay Sender
# By Versailles / Viloid
# Greets : Cans21 ~ Sec7or Team ~ Surabaya Hacker Link
# *Note : Im not support for this script. if any mistake "gausa bacot jancok, gelem gawenen, ra gelem rausa nyacat"
# Dapat script gratis jangan dijual cok!

App="X-AppVersion: 3.36.1"
Os="X-DeviceOS: Android,6.0"
Model="X-PhoneModel: Xiaomi,Redmi Note 4"

gosex(){	
	if [[ -f data.json ]]; then
		bearer=$(cat data.json | grep -oP '"access_token": "\K[^"]+')
		name=$(cat data.json | grep -oP '"name": "\K[^"]+')
		if [[ ! -z $bearer ]]; then
			echo "[+] Log-in As $name"
			echo "[+] Balance : Rp. $(getBal $bearer)"
			read -p "[?] Send to : " target
			read -p "[?] Amount : " amount
			read -p "[?] Message : " msg
			read -p "[?] Pin : " pin
			transfer $bearer $pin $target $amount $msg
		else
			echo "[-] Error"
		fi
	else
		read -p "[?] Phone Number : " phone
		uniqid=$(echo "X-UniqueId: 4b2897bdd595f$(head /dev/urandom | tr -dc a-z0-9 | head -c 3)")
		tkn=$(curl -s https://api.gojekapi.com/v4/customers/login_with_phone -H "$uniqid" -H "$App" -H "$Os" -H "$Model" -d '{"phone":"+'$phone'"}' | grep -oP '"login_token": "\K[^"]+')
		if [[ ! -z $tkn ]]; then
			read -p "[?] OTP : " otp
			log=$(curl -s https://api.gojekapi.com/v4/customers/login/verify -H "$uniqid" -H "$App" -H "$Os" -H "$Model" -d '{"client_name":"gojek:cons:android","client_secret":"83415d06-ec4e-11e6-a41b-6c40088ab51e","data":{"otp":"'$otp'","otp_token":"'$tkn'"},"grant_type":"otp","scopes":"gojek:customer:transaction gojek:customer:readonly"}' > data.json)			
			if [[ -f data.json ]]; then
				bearer=$(cat data.json | grep -oP '"access_token": "\K[^"]+')
				name=$(cat data.json | grep -oP '"name": "\K[^"]+')
				if [[ ! -z $bearer ]]; then
					echo "[+] Log-in As $name"
					echo "[+] Balance : Rp. $(getBal $bearer)"
					read -p "[?] Send to : " target
					read -p "[?] Amount : " amount
					read -p "[?] Message : " msg
					read -p "[?] Pin : " pin
					transfer $bearer $pin $target $amount $msg
				else
					echo "[-] Error"
				fi
			fi
		else
			echo "[-] Phone number not registered"
		fi
	fi
}

getBal(){
	curl -s -H "Authorization: Bearer $1" -H "$App" -H "$Os" -H "$Model" "https://api.gojekapi.com/wallet/profile" | grep -oP '"balance":\K[^,]+'
}

qr(){
	curl -s -H "Authorization: Bearer $1" -H "$App" -H "$Os" -H "$Model" "https://api.gojekapi.com/wallet/qr-code?phone_number=%2B$2" | grep -oP '"qr_id":"\K[^"]+'
}

transfer(){
	trx=$(curl -s -H "Authorization: Bearer $1" -H "Pin: $2" -H "$App" -H "$Os" -H "$Model" "https://api.gojekapi.com/v2/fund/transfer" -d '{"amount":"'$4'","description":"💰 '$5'","qr_id":"'$(qr $1 $3)'"}' | grep -oP '"transaction_ref":"\K[^"]+')
	if [[ ! -z $trx ]]; then
		echo "[+] Successfully transfered Rp.$4 to $3"
		echo "[+] Transaction_ref : $trx"
		echo "$(date '+%D %H:%M:%S')|$3|Rp.$4|$5" >> transactions.log
	else
		echo "[-] Transfer Failed :("
	fi
}

header(){
cat <<EOF

+------------------------------------------------------------------+
|	Simple GoPay Sender
|	By : Versailles / Viloid
|	Sec7or Team ~ Surabaya Hacker Link
+------------------------------------------------------------------+

EOF
}

header
if [ -f data.json ]; then
	read -p "[?] Remove Current Account (y/n): " curr
	if [ $curr == "y" ];then
		rm data.json
	fi
fi
gosex
