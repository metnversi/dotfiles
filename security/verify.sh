#!/bin/env bash
source ../install.sh
aidedb=/var/lib/aide/aide.db.gz
aidedb_out=/var/lib/aide/aide.db.new.gz
audit1="-a always,exit -S all -F exe=/usr/bin/sudo -F key=sudo-used"
audit2="-w /etc/aide/aide.conf -p rwa -k aide-change"
auditfile="/etc/audit/rules.d/audit.rules"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

for i in /etc/*; do
  dpkg-query -S $i >/root/lmao
done

sed -i '/no path found/d' /root/lmao
cut -d: -f1 /root/lmao | sort | uniq >/root/lmao_2

for i in $(cat /root/lmao_2); do
  debsums -s $i >/root/changed
done

sort /root/changed | uniq

if ! grep -Fxq "$audit1" $auditfile; then
  echo "$audit1" >>$auditfile
fi

if ! grep -Fxq "$audit2" $auditfile; then
  echo "$audit2" >>$auditfile
fi

check=$(grep -v ^# /etc/nftables.conf | grep my_input)
if [[ -z $check ]]; then
  sudo cp $(pwd)/security/nftables.conf /etc/nftables.conf
  installed "nftables"
else
  skip "nftables"
fi
echo -e "\e[31m[WARNING]\e[0m Please run aide with idle state, turn off all process now!"
sudo aideinit
if [ ! -f "$aidedb" ]; then
  echo "$aidedb not found" >&2
  exit 1
fi
aide -u || true
mv $aidedb $aidedb.back
mv $aidedb_out $aidedb
