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

def get_hosting_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # doesn't even have to be reachable
        s.connect(('192.168.31.1', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

hosting_ip = get_hosting_ip()
print ("ip: {}".format(hosting_ip))

from http_file_server import HttpFileServer
file_server = HttpFileServer("build")

with file_server:
    url = "http://{}:8000/build/payload.tar.gz".format(hosting_ip)
    print("url: {}".format(url))
    r = requests.get(url)
    print(r.text)
file_server.__exit__
