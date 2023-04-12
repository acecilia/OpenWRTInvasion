import socketserver
import threading
import time
import sys
import http.server
import socket

class HttpFileServer:
    def __init__(self, root_dir='.'):
        HOST, PORT = '', 0
        self.server = socketserver.TCPServer((HOST, PORT), http.server.SimpleHTTPRequestHandler)
        self.server.root_dir = root_dir
        self.ip, self.port = self.server.server_address

    def __enter__(self):
        self.run()
        return self

    def run(self):
        self.server_thread = threading.Thread(target=self.server.serve_forever)
        self.server_thread.daemon = True
        self.server_thread.start()
        print("local file server is runing on {}:{}. root='{}'".format(self.ip, self.port, self.server.root_dir))
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("stopping local file server")
        self.server.shutdown()
        self.server.server_close()


if __name__ == "__main__":
    root_dir = '.' if len(sys.argv) <= 1 else sys.argv[1]
    with HttpFileServer(root_dir):
        while True:
            time.sleep(10)
