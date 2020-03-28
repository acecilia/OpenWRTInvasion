#!/usr/bin/python

##############################
# Language files located in: /usr/lib/lua/luci/i18n
# Config to change the language located in: /etc/config/luci
# See: https://forum.openwrt.org/t/how-to-translate-openwrt-luci-to-arabic/28752/10
##############################

import os
import ftplib

router_ip_address = input("Router IP address: ")
# router_ip_address = '192.168.0.21'

session = ftplib.FTP(router_ip_address,'root','')

# Uploading a lenguage file will not succeed as the filesystem is ro
# languageFile = open('extras/language/i18n/base.en.lmo','rb')
# session.storbinary('STOR /usr/lib/lua/luci/i18n/base.en.lmo', languageFile)
# languageFile.close()

configFile = open('extras/language/luci','rb')
session.storbinary('STOR /etc/config/luci', configFile)
configFile.close()

session.quit()