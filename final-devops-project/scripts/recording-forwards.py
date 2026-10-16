#!/usr/bin/env python3
"""Supervise only our own port-forwards; recover each connection independently."""
import argparse
from dataclasses import dataclass, field
import fcntl
import os
from pathlib import Path
import signal
import socket
import subprocess
import threading
import time
import urllib.request


@dataclass
class Forward:
    name: str
    namespace: str
    service: str
    ports: str
    path: str
    headers: dict = field(default_factory=dict)
    process: object = None
    logfile: object = None
    retry_at: float = 0
    failures: int = 0
    healthy: bool = False
    started_at: float = 0
    connected_once: bool = False
    outage_reported: bool = False

    @property
    def port(self):
        return int(self.ports.split(":")[0])

    def probe(self):
        try:
            request = urllib.request.Request(
                f"http://127.0.0.1:{self.port}{self.path}", headers=self.headers)
            with urllib.request.urlopen(request, timeout=5) as response:
                return response.status == 200
        except (OSError, ValueError):
            return False


def stop_child(forward):
    if forward.process is not None:
        # kubectl may be waiting on its AWS credential child. Stop the owned group too.
        try:
            os.killpg(forward.process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        if forward.process.poll() is None:
            try:
                forward.process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(forward.process.pid, signal.SIGKILL)
                forward.process.wait()
        forward.process = None


def supervise(kube, runtime_dir, forwards, stopped, interval=3, startup_timeout=90,
              connection_grace=75):
    runtime_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    lock_path = runtime_dir / "supervisor.lock"
    lock_path.touch(mode=0o600, exist_ok=True)
    with lock_path.open("r+") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise SystemExit("The capstone recording helper is already running.")
        # Check all ports before starting any process. Never replace another listener.
        for forward in forwards:
            with socket.socket() as check:
                check.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                try:
                    check.bind(("127.0.0.1", forward.port))
                except OSError:
                    raise SystemExit(f"Port {forward.port} is occupied; no forwards started.")
        deadline = time.monotonic() + startup_timeout
        ready = False
        try:
            for forward in forwards:
                path = runtime_dir / f"{forward.name}.log"
                path.touch(mode=0o600, exist_ok=True)
                forward.logfile = path.open("a", buffering=1)
            while not stopped.is_set():
                for forward in forwards:
                    now = time.monotonic()
                    if forward.process is not None and forward.process.poll() is not None:
                        print(f"{forward.name}: connection stopped; reconnecting automatically.", flush=True)
                        stop_child(forward)
                        forward.healthy = False
                        forward.outage_reported = True
                        forward.failures = 0
                        forward.retry_at = now + interval
                    if forward.process is None and now >= forward.retry_at:
                        forward.logfile.write(f"\nStarting connection at {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                        forward.process = subprocess.Popen(
                            kube + ["port-forward", "--address=127.0.0.1", "-n",
                                    forward.namespace, forward.service, forward.ports],
                            stdin=subprocess.DEVNULL, stdout=forward.logfile,
                            stderr=subprocess.STDOUT, start_new_session=True)
                        forward.started_at = time.monotonic()
                        forward.connected_once = False
                    if forward.process is not None:
                        healthy = forward.probe()
                        if healthy:
                            if forward.outage_reported and ready:
                                print(f"{forward.name}: HTTP 200; connection recovered.", flush=True)
                            forward.healthy = True
                            forward.connected_once = True
                            forward.outage_reported = False
                            forward.failures = 0
                        else:
                            forward.failures += 1
                            forward.healthy = False
                            # Allow slow credential loading/API negotiation to finish.
                            # A refused localhost socket during startup is not a hung tunnel.
                            grace_elapsed = time.monotonic() - forward.started_at >= connection_grace
                            if forward.failures >= 3 and (forward.connected_once or grace_elapsed):
                                if not forward.outage_reported:
                                    print(f"{forward.name}: three failed checks; reconnecting only this connection. If all pages fail, check your network and EKS IP access.", flush=True)
                                forward.outage_reported = True
                                stop_child(forward)
                                forward.failures = 0
                                forward.retry_at = time.monotonic() + interval
                if not ready and all(forward.healthy for forward in forwards):
                    ready = True
                    print("All four recording endpoints returned HTTP 200.", flush=True)
                    print("Ready: Ingress 28080, Prometheus 49091, Grafana 43001, Argo CD 48080.", flush=True)
                    print("Connections recover independently after a drop. A brief service outage can still be visible.", flush=True)
                    print("Run python3 scripts/recording-browser.py to open the recording browser.", flush=True)
                    print("Keep this terminal running. Ctrl-C stops only this helper's forwards.", flush=True)
                if not ready and time.monotonic() >= deadline:
                    missing = ", ".join(f.name for f in forwards if not f.healthy)
                    raise SystemExit(f"Recording is not ready: {missing}. Check the private forwarding logs.")
                stopped.wait(interval)
        finally:
            for forward in forwards:
                stop_child(forward)
                if forward.logfile is not None:
                    forward.logfile.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kubeconfig")
    parser.add_argument("runtime_dir", type=Path)
    args = parser.parse_args()
    stopped = threading.Event()
    for signum in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(signum, lambda *_: stopped.set())
    kube = ["kubectl", "--kubeconfig", args.kubeconfig, "--context", "devops-homework-eks"]
    forwards = [
        Forward("ingress", "ingress-nginx", "svc/aws-ingress-nginx-ingress-controller",
                "28080:80", "/api/config", {"Host": "notes.aws.project.local"}),
        Forward("prometheus", "project-monitoring", "svc/prometheus", "49091:9090", "/-/ready"),
        Forward("grafana", "project-monitoring", "svc/grafana", "43001:3000", "/api/health"),
        Forward("argocd", "argocd", "svc/argocd-server", "48080:80", "/api/version"),
    ]
    supervise(kube, args.runtime_dir, forwards, stopped)


if __name__ == "__main__":
    main()
