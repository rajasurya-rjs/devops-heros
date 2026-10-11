"""Bounded CPU load for the local HPA demonstration (no cloud provisioning)."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import time
import urllib.error
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("url", help="Frontend/Ingress URL, e.g. http://127.0.0.1:18083")
parser.add_argument("--seconds", type=int, choices=range(1, 121), default=60)
parser.add_argument("--workers", type=int, choices=range(1, 33), default=16)
args = parser.parse_args()
deadline = time.monotonic() + args.seconds


def worker(_):
    successes, failures = 0, 0
    while time.monotonic() < deadline:
        try:
            with urllib.request.urlopen(args.url.rstrip("/") + "/burn", timeout=5) as response:
                successes += int(response.status == 200)
        except (urllib.error.URLError, TimeoutError):
            failures += 1
    return successes, failures


with ThreadPoolExecutor(max_workers=args.workers) as pool:
    results = list(pool.map(worker, range(args.workers)))
print({"successful_requests": sum(x[0] for x in results),
       "failed_requests": sum(x[1] for x in results), "seconds": args.seconds})
