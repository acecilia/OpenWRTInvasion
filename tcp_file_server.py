import socketserver
import threading
import time
import sys

class RequestHandler(socketserver.StreamRequestHandler):
    def handle(self):
        filename = self.rfile.readline().strip().decode('UTF-8')
        print("local file server is getting '{}' for {}.".format(filename, self.client_address[0]))
        with open("{}/{}".format(self.server.root_dir, filename), "rb") as f:
            self.wfile.write(f.read())
        self.wfile.close()

class TcpFileServer:
    def __init__(self, root_dir='.'):
        HOST, PORT = '', 0
        self.server = socketserver.TCPServer((HOST, PORT), RequestHandler)
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
        self.server.shutdown()
        self.server.server_close()


if __name__ == "__main__":
    root_dir = '.' if len(sys.argv) <= 1 else sys.argv[1]
    with TcpFileServer(root_dir):
        while True:
            time.sleep(10)
