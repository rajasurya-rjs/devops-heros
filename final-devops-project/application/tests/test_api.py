import importlib.util
import json
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from pathlib import Path
from http.server import ThreadingHTTPServer

spec = importlib.util.spec_from_file_location("app", Path(__file__).parents[1] / "app.py")
app = importlib.util.module_from_spec(spec)
spec.loader.exec_module(app)

class APITests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.directory = tempfile.TemporaryDirectory()
        app.DB_PATH = str(Path(cls.directory.name) / "test.db")
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), app.Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = f"http://127.0.0.1:{cls.server.server_port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.directory.cleanup()

    def request(self, path, method="GET", body=None):
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(self.url + path, data=data, method=method)
        try:
            with urllib.request.urlopen(req) as response:
                return response.status, response.read().decode()
        except urllib.error.HTTPError as error:
            return error.code, error.read().decode()

    def test_health(self):
        code, body = self.request("/health")
        self.assertEqual(code, 200)
        self.assertEqual(json.loads(body)["status"], "ok")

    def test_crud(self):
        code, body = self.request("/api/notes", "POST", {"text": "verify release"})
        self.assertEqual(code, 201)
        ident = json.loads(body)["id"]
        self.assertIn("verify release", self.request("/api/notes")[1])
        self.assertEqual(self.request(f"/api/notes/{ident}", "PUT", {"text": "verified"})[0], 200)
        self.assertIn("verified", self.request("/api/notes")[1])
        self.assertEqual(self.request(f"/api/notes/{ident}", "DELETE")[0], 200)
        self.assertEqual(self.request(f"/api/notes/{ident}", "DELETE")[0], 404)

    def test_empty_note_rejected(self):
        self.assertEqual(self.request("/api/notes", "POST", {"text": ""})[0], 400)

    def test_long_note_rejected(self):
        self.assertEqual(self.request("/api/notes", "POST", {"text": "a" * 501})[0], 400)

    def test_sql_is_data(self):
        note = "Robert'); DROP TABLE notes;--"
        self.assertEqual(self.request("/api/notes", "POST", {"text": note})[0], 201)
        self.assertIn(note, self.request("/api/notes")[1])

    def test_update_missing(self):
        self.assertEqual(self.request("/api/notes/99999", "PUT", {"text": "missing"})[0], 404)

    def test_metrics(self):
        code, body = self.request("/metrics")
        self.assertEqual(code, 200)
        self.assertIn("ops_requests_total", body)

    def test_unknown_route(self):
        self.assertEqual(self.request("/does-not-exist")[0], 404)

    def test_home_page(self):
        self.assertIn("Operations Notes", self.request("/")[1])

if __name__ == "__main__":
    unittest.main()
