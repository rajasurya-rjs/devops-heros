"""Exercise every backend endpoint through the frontend gateway."""
import json
import os
import sys
import urllib.request

BASE = sys.argv[1] if len(sys.argv) > 1 else 'http://127.0.0.1:18082'


def request(path, method='GET', body=None, expected=200):
    payload = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(BASE + path, data=payload, method=method,
                                 headers={'Content-Type': 'application/json', **({'Host': os.environ['OPS_HOST']} if os.getenv('OPS_HOST') else {})})
    with urllib.request.urlopen(req, timeout=15) as response:
        text = response.read().decode()
        assert response.status == expected, (path, response.status)
        print(f'{method} {path} -> HTTP {response.status}')
        print(text if path != '/' else 'Operations Notes frontend loaded')
        if path == '/':
            assert 'Operations Notes' in text
            return
        return json.loads(text) if path != '/metrics' else text


request('/')
request('/health')
request('/ready')
config = request('/api/config')
assert config['database'] == 'PostgreSQL', config
request('/api/notes')
note = request('/api/notes', 'POST', {'text': 'Release check from the three-tier API'}, 201)
assert any(n['id'] == note['id'] for n in request('/api/notes'))
request(f"/api/notes/{note['id']}", 'PUT', {'text': 'API update checked'})
request(f"/api/notes/{note['id']}", 'DELETE')
assert not any(n['id'] == note['id'] for n in request('/api/notes'))
assert 'ops_requests_total' in request('/metrics')
request('/burn')
request('/api/notes', 'POST', {'text': 'Rajasurya: frontend, backend and PostgreSQL are connected.'}, 201)
print('All API endpoints passed through the frontend; database: PostgreSQL')
