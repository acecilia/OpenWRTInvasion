#!/usr/bin/python

##############################
# Language files located in: /usr/lib/lua/luci/i18n
# Config to change the language located in: /etc/config/luci
# See: https://forum.openwrt.org/t/how-to-translate-openwrt-luci-to-arabic/28752/10
##############################

import os
import ftplib

router_ip_address = input("Router IP address: ")

session = ftplib.FTP(router_ip_address,'root','')

configFile = open(os.path.join('extras', 'language', 'luci'), 'rb')
session.storbinary('STOR /etc/config/luci', configFile)
configFile.close()

session.quit()