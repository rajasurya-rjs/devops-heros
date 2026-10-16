"""Exercise real local subprocess recovery without touching AWS or Kubernetes."""
import importlib.util
from pathlib import Path
import socket
import sys
import tempfile
import threading
import time
import unittest

spec = importlib.util.spec_from_file_location(
    "recording_forwards", Path(__file__).parents[1] / "recording-forwards.py")
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module
spec.loader.exec_module(module)


def unused_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def wait_for(predicate, timeout=6):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.05)
    raise AssertionError("Timed out waiting for the local recovery test")


class ForwardRecoveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.fake = self.root / "fake-kubectl.py"
        self.fake.write_text('''
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import sys
port = int(sys.argv[-1].split(':')[0])
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(503 if Path(__file__).with_name(str(port)+'.unhealthy').exists() else 200)
        self.end_headers()
        self.wfile.write(b'health')
    def log_message(self, *args): pass
class Server(HTTPServer): allow_reuse_address = True
Server(('127.0.0.1', port), Handler).serve_forever()
''')
        self.stopped = threading.Event()
        self.errors = []
        self.thread = None

    def tearDown(self):
        self.stopped.set()
        if self.thread:
            self.thread.join(timeout=8)
            self.assertFalse(self.thread.is_alive(), "Supervisor did not stop")
        self.temp.cleanup()

    def forward(self, name):
        return module.Forward(name, "test", "svc/test", f"{unused_port()}:80", "/health")

    def start(self, forwards, timeout=6):
        def run():
            try:
                module.supervise([sys.executable, str(self.fake)], self.root / "runtime",
                                 forwards, self.stopped, interval=0.1,
                                 startup_timeout=timeout)
            except BaseException as error:
                self.errors.append(error)
        self.thread = threading.Thread(target=run)
        self.thread.start()

    def test_recovers_dead_and_unresponsive_tunnels_without_stopping_peer(self):
        first, peer = self.forward("first"), self.forward("peer")
        self.start([first, peer])
        wait_for(lambda: first.healthy and peer.healthy)
        peer_process = peer.process
        first_process = first.process
        first_process.terminate()
        wait_for(lambda: first.process is not None and first.process is not first_process
                 and first.healthy)
        self.assertIs(peer.process, peer_process)
        self.assertTrue(peer.probe())
        replacement = first.process
        flag = self.root / f"{first.port}.unhealthy"
        flag.touch()
        wait_for(lambda: replacement.poll() is not None)
        flag.unlink()
        wait_for(lambda: first.process is not None and first.process is not replacement
                 and first.healthy)
        self.assertIs(peer.process, peer_process)
        self.assertTrue(peer.probe())
        current = [first.process, peer.process]
        self.stopped.set()
        self.thread.join(timeout=8)
        self.assertFalse(self.errors, self.errors)
        self.assertTrue(all(process.poll() is not None for process in current))

    def test_occupied_port_fails_before_starting_any_child(self):
        first, occupied = self.forward("first"), self.forward("occupied")
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", occupied.port))
            listener.listen()
            with self.assertRaisesRegex(SystemExit, "occupied"):
                module.supervise([sys.executable, str(self.fake)], self.root / "runtime",
                                 [first, occupied], self.stopped)
            self.assertIsNone(first.process)
            self.assertIsNone(occupied.process)
            # The existing listener is still bound and was not terminated.
            self.assertEqual(listener.getsockname()[1], occupied.port)

    def test_unhealthy_startup_never_reports_ready_and_cleans_up(self):
        first = self.forward("first")
        (self.root / f"{first.port}.unhealthy").touch()
        self.start([first], timeout=0.5)
        self.thread.join(timeout=8)
        self.assertFalse(self.thread.is_alive())
        self.assertEqual(len(self.errors), 1)
        self.assertIn("not ready", str(self.errors[0]))
        self.assertIsNone(first.process)


if __name__ == "__main__":
    unittest.main()
