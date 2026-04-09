#!/usr/bin/env python3
"""
Network tools TCP/UDP performance test harness.

This script is designed for the Flutter module:
  lib/modules/network_tools/pages/tabs/perf_test_tab.dart

It covers all TCP/UDP send/receive paths used by the module:
1. TCP client mode in the app:
   - Run this script as a TCP echo server.
   - The app sends data to this script.
   - This script echoes data back so the app can verify both send and receive.
2. UDP client mode in the app:
   - Run this script as a UDP echo server.
   - The app sends datagrams to this script.
   - This script echoes datagrams back so the app can verify both send and receive.
3. TCP server mode in the app:
   - Run this script as a TCP push client.
   - This script connects to the app server and continuously sends payloads.
   - The app should report receive metrics.
4. UDP server mode in the app:
   - Run this script as a UDP push client.
   - This script continuously sends datagrams to the app server.
   - The app should report receive metrics.

Usage examples:
  python test/perf_test_harness.py tcp-echo-server --host 127.0.0.1 --port 8088
  python test/perf_test_harness.py udp-echo-server --host 127.0.0.1 --port 8088
  python test/perf_test_harness.py tcp-push-client --host 127.0.0.1 --port 8088
  python test/perf_test_harness.py udp-push-client --host 127.0.0.1 --port 8088
  python test/perf_test_harness.py self-test
"""

from __future__ import annotations

import argparse
import queue
import signal
import socket
import sys
import threading
import time
from dataclasses import dataclass
from typing import Optional


DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8088
DEFAULT_CONNECTIONS = 4
DEFAULT_INTERVAL_MS = 50
DEFAULT_PAYLOAD_SIZE = 1024
DEFAULT_DURATION_SECONDS = 6
SOCKET_TIMEOUT_SECONDS = 1.0


@dataclass
class TrafficStats:
    sent_packets: int = 0
    sent_bytes: int = 0
    received_packets: int = 0
    received_bytes: int = 0
    accepted_connections: int = 0

    def snapshot(self) -> "TrafficStats":
        return TrafficStats(
            sent_packets=self.sent_packets,
            sent_bytes=self.sent_bytes,
            received_packets=self.received_packets,
            received_bytes=self.received_bytes,
            accepted_connections=self.accepted_connections,
        )


class AtomicStats:
    def __init__(self) -> None:
        self._stats = TrafficStats()
        self._lock = threading.Lock()

    def add_sent(self, size: int) -> None:
        with self._lock:
            self._stats.sent_packets += 1
            self._stats.sent_bytes += size

    def add_received(self, size: int) -> None:
        with self._lock:
            self._stats.received_packets += 1
            self._stats.received_bytes += size

    def add_accept(self) -> None:
        with self._lock:
            self._stats.accepted_connections += 1

    def snapshot(self) -> TrafficStats:
        with self._lock:
            return self._stats.snapshot()


def make_payload(size: int) -> bytes:
    base = b"owo-tool-box-perf-test|"
    if size <= len(base):
        return base[:size]
    repeat = (size // len(base)) + 1
    return (base * repeat)[:size]


def print_metrics_loop(
    label: str,
    stats: AtomicStats,
    stop_event: threading.Event,
    interval: float = 1.0,
) -> None:
    previous = stats.snapshot()
    while not stop_event.wait(interval):
        current = stats.snapshot()
        sent_packets = current.sent_packets - previous.sent_packets
        sent_bytes = current.sent_bytes - previous.sent_bytes
        received_packets = current.received_packets - previous.received_packets
        received_bytes = current.received_bytes - previous.received_bytes
        accepted_connections = current.accepted_connections
        print(
            f"[{label}] +1s "
            f"sent={sent_packets} pkt/{sent_bytes} B, "
            f"recv={received_packets} pkt/{received_bytes} B, "
            f"accepted={accepted_connections}",
            flush=True,
        )
        previous = current


def tcp_echo_server(
    host: str,
    port: int,
    duration: Optional[int],
    payload_size: int,
) -> int:
    del payload_size
    stop_event = threading.Event()
    stats = AtomicStats()
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((host, port))
    server.listen()
    server.settimeout(SOCKET_TIMEOUT_SECONDS)

    def handle_client(conn: socket.socket, address: tuple[str, int]) -> None:
        print(f"[tcp-echo-server] client connected: {address[0]}:{address[1]}")
        with conn:
            conn.settimeout(SOCKET_TIMEOUT_SECONDS)
            while not stop_event.is_set():
                try:
                    chunk = conn.recv(65535)
                except socket.timeout:
                    continue
                except OSError:
                    break
                if not chunk:
                    break
                stats.add_received(len(chunk))
                try:
                    conn.sendall(chunk)
                    stats.add_sent(len(chunk))
                except OSError:
                    break
        print(f"[tcp-echo-server] client disconnected: {address[0]}:{address[1]}")

    threads: list[threading.Thread] = []
    metrics_thread = threading.Thread(
        target=print_metrics_loop,
        args=("tcp-echo-server", stats, stop_event),
        daemon=True,
    )
    metrics_thread.start()

    deadline = time.time() + duration if duration else None
    print(f"[tcp-echo-server] listening on {host}:{port}", flush=True)
    try:
        while not stop_event.is_set():
            if deadline and time.time() >= deadline:
                break
            try:
                conn, address = server.accept()
            except socket.timeout:
                continue
            stats.add_accept()
            thread = threading.Thread(
                target=handle_client,
                args=(conn, address),
                daemon=True,
            )
            thread.start()
            threads.append(thread)
    except KeyboardInterrupt:
        print("[tcp-echo-server] interrupted, stopping...", flush=True)
    finally:
        stop_event.set()
        server.close()
        for thread in threads:
            thread.join(timeout=1.0)
        metrics_thread.join(timeout=1.0)

    summary = stats.snapshot()
    print(
        "[tcp-echo-server] summary: "
        f"accepted={summary.accepted_connections}, "
        f"sent={summary.sent_packets} pkt/{summary.sent_bytes} B, "
        f"recv={summary.received_packets} pkt/{summary.received_bytes} B",
        flush=True,
    )
    return 0


def udp_echo_server(
    host: str,
    port: int,
    duration: Optional[int],
    payload_size: int,
) -> int:
    del payload_size
    stop_event = threading.Event()
    stats = AtomicStats()
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((host, port))
    sock.settimeout(SOCKET_TIMEOUT_SECONDS)

    metrics_thread = threading.Thread(
        target=print_metrics_loop,
        args=("udp-echo-server", stats, stop_event),
        daemon=True,
    )
    metrics_thread.start()

    deadline = time.time() + duration if duration else None
    print(f"[udp-echo-server] listening on {host}:{port}", flush=True)
    try:
        while not stop_event.is_set():
            if deadline and time.time() >= deadline:
                break
            try:
                data, address = sock.recvfrom(65535)
            except socket.timeout:
                continue
            except KeyboardInterrupt:
                break
            stats.add_received(len(data))
            sock.sendto(data, address)
            stats.add_sent(len(data))
    finally:
        stop_event.set()
        sock.close()
        metrics_thread.join(timeout=1.0)

    summary = stats.snapshot()
    print(
        "[udp-echo-server] summary: "
        f"sent={summary.sent_packets} pkt/{summary.sent_bytes} B, "
        f"recv={summary.received_packets} pkt/{summary.received_bytes} B",
        flush=True,
    )
    return 0


def _push_sender_loop(
    protocol: str,
    host: str,
    port: int,
    payload: bytes,
    interval_seconds: float,
    stop_event: threading.Event,
    stats: AtomicStats,
    errors: "queue.Queue[str]",
) -> None:
    try:
        if protocol == "tcp":
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5.0)
            sock.connect((host, port))
        else:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(SOCKET_TIMEOUT_SECONDS)
        with sock:
            while not stop_event.is_set():
                if protocol == "tcp":
                    sock.sendall(payload)
                    stats.add_sent(len(payload))
                else:
                    written = sock.sendto(payload, (host, port))
                    if written > 0:
                        stats.add_sent(written)
                if stop_event.wait(interval_seconds):
                    break
    except Exception as exc:  # pragma: no cover - defensive logging path
        errors.put(f"{protocol} sender failed: {exc}")
        stop_event.set()


def push_client(
    protocol: str,
    host: str,
    port: int,
    connections: int,
    interval_ms: int,
    payload_size: int,
    duration: int,
) -> int:
    stop_event = threading.Event()
    stats = AtomicStats()
    errors: "queue.Queue[str]" = queue.Queue()
    payload = make_payload(payload_size)
    interval_seconds = interval_ms / 1000.0

    metrics_thread = threading.Thread(
        target=print_metrics_loop,
        args=(f"{protocol}-push-client", stats, stop_event),
        daemon=True,
    )
    metrics_thread.start()

    workers = [
        threading.Thread(
            target=_push_sender_loop,
            args=(
                protocol,
                host,
                port,
                payload,
                interval_seconds,
                stop_event,
                stats,
                errors,
            ),
            daemon=True,
        )
        for _ in range(connections)
    ]
    for worker in workers:
        worker.start()

    print(
        f"[{protocol}-push-client] sending to {host}:{port}, "
        f"connections={connections}, interval_ms={interval_ms}, payload={payload_size}B",
        flush=True,
    )

    try:
        stop_event.wait(duration)
    except KeyboardInterrupt:
        print(f"[{protocol}-push-client] interrupted, stopping...", flush=True)
    finally:
        stop_event.set()
        for worker in workers:
            worker.join(timeout=1.0)
        metrics_thread.join(timeout=1.0)

    while not errors.empty():
        print(f"[{protocol}-push-client] error: {errors.get_nowait()}", file=sys.stderr)
        return 1

    summary = stats.snapshot()
    print(
        f"[{protocol}-push-client] summary: "
        f"sent={summary.sent_packets} pkt/{summary.sent_bytes} B",
        flush=True,
    )
    return 0


def _tcp_sink_server(host: str, port: int, duration: int) -> None:
    stop_event = threading.Event()
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((host, port))
    server.listen()
    server.settimeout(SOCKET_TIMEOUT_SECONDS)
    threads: list[threading.Thread] = []
    deadline = time.time() + duration

    def handle_client(conn: socket.socket) -> None:
        with conn:
            conn.settimeout(SOCKET_TIMEOUT_SECONDS)
            while not stop_event.is_set():
                try:
                    chunk = conn.recv(65535)
                except socket.timeout:
                    continue
                except OSError:
                    break
                if not chunk:
                    break

    try:
        while time.time() < deadline:
            try:
                conn, _ = server.accept()
            except socket.timeout:
                continue
            thread = threading.Thread(target=handle_client, args=(conn,), daemon=True)
            thread.start()
            threads.append(thread)
    finally:
        stop_event.set()
        server.close()
        for thread in threads:
            thread.join(timeout=1.0)


def _udp_sink_server(host: str, port: int, duration: int) -> None:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((host, port))
    sock.settimeout(SOCKET_TIMEOUT_SECONDS)
    deadline = time.time() + duration
    try:
        while time.time() < deadline:
            try:
                sock.recvfrom(65535)
            except socket.timeout:
                continue
    finally:
        sock.close()


def self_test(duration: int, payload_size: int, interval_ms: int) -> int:
    print("[self-test] running local TCP/UDP harness tests...", flush=True)

    tcp_port = 18088
    udp_port = 18089
    tcp_sink_port = 18090
    udp_sink_port = 18091
    server_duration = max(duration, 2) * 2 + 4
    tcp_thread = threading.Thread(
        target=tcp_echo_server,
        args=("127.0.0.1", tcp_port, server_duration, payload_size),
        daemon=True,
    )
    udp_thread = threading.Thread(
        target=udp_echo_server,
        args=("127.0.0.1", udp_port, server_duration, payload_size),
        daemon=True,
    )
    tcp_thread.start()
    udp_thread.start()
    time.sleep(0.5)

    tcp_result = _probe_tcp_echo("127.0.0.1", tcp_port, payload_size)
    udp_result = _probe_udp_echo("127.0.0.1", udp_port, payload_size)

    if not tcp_result:
        print("[self-test] TCP echo probe failed", file=sys.stderr)
        return 1
    if not udp_result:
        print("[self-test] UDP echo probe failed", file=sys.stderr)
        return 1

    tcp_sink_thread = threading.Thread(
        target=_tcp_sink_server,
        args=("127.0.0.1", tcp_sink_port, 4),
        daemon=True,
    )
    udp_sink_thread = threading.Thread(
        target=_udp_sink_server,
        args=("127.0.0.1", udp_sink_port, 4),
        daemon=True,
    )
    tcp_sink_thread.start()
    udp_sink_thread.start()
    time.sleep(0.3)

    push_tcp = push_client(
        protocol="tcp",
        host="127.0.0.1",
        port=tcp_sink_port,
        connections=2,
        interval_ms=interval_ms,
        payload_size=payload_size,
        duration=2,
    )
    if push_tcp != 0:
        return push_tcp

    push_udp = push_client(
        protocol="udp",
        host="127.0.0.1",
        port=udp_sink_port,
        connections=2,
        interval_ms=interval_ms,
        payload_size=payload_size,
        duration=2,
    )
    if push_udp != 0:
        return push_udp

    tcp_sink_thread.join(timeout=5)
    udp_sink_thread.join(timeout=5)
    tcp_thread.join(timeout=server_duration + 2)
    udp_thread.join(timeout=server_duration + 2)

    print("[self-test] all checks passed", flush=True)
    return 0


def _probe_tcp_echo(host: str, port: int, payload_size: int) -> bool:
    payload = make_payload(payload_size)
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5.0)
    try:
        sock.connect((host, port))
        sock.sendall(payload)
        received = b""
        while len(received) < len(payload):
            chunk = sock.recv(65535)
            if not chunk:
                break
            received += chunk
        return received == payload
    except OSError:
        return False
    finally:
        sock.close()


def _probe_udp_echo(host: str, port: int, payload_size: int) -> bool:
    payload = make_payload(payload_size)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(5.0)
    try:
        sock.sendto(payload, (host, port))
        data, _ = sock.recvfrom(65535)
        return data == payload
    except OSError:
        return False
    finally:
        sock.close()


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="TCP/UDP harness for network_tools perf test module.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_common_args(subparser: argparse.ArgumentParser) -> None:
        subparser.add_argument("--host", default=DEFAULT_HOST)
        subparser.add_argument("--port", type=int, default=DEFAULT_PORT)
        subparser.add_argument(
            "--duration",
            type=int,
            default=DEFAULT_DURATION_SECONDS,
            help="Run time in seconds. Use 0 for no auto-stop where supported.",
        )
        subparser.add_argument(
            "--payload-size",
            type=int,
            default=DEFAULT_PAYLOAD_SIZE,
        )

    tcp_echo = subparsers.add_parser(
        "tcp-echo-server",
        help="Echo server for testing app TCP client mode send/receive.",
    )
    add_common_args(tcp_echo)

    udp_echo = subparsers.add_parser(
        "udp-echo-server",
        help="Echo server for testing app UDP client mode send/receive.",
    )
    add_common_args(udp_echo)

    tcp_push = subparsers.add_parser(
        "tcp-push-client",
        help="Push client for testing app TCP server mode receive.",
    )
    add_common_args(tcp_push)
    tcp_push.add_argument("--connections", type=int, default=DEFAULT_CONNECTIONS)
    tcp_push.add_argument("--interval-ms", type=int, default=DEFAULT_INTERVAL_MS)

    udp_push = subparsers.add_parser(
        "udp-push-client",
        help="Push client for testing app UDP server mode receive.",
    )
    add_common_args(udp_push)
    udp_push.add_argument("--connections", type=int, default=DEFAULT_CONNECTIONS)
    udp_push.add_argument("--interval-ms", type=int, default=DEFAULT_INTERVAL_MS)

    selftest = subparsers.add_parser(
        "self-test",
        help="Run local harness self-test without the Flutter app.",
    )
    selftest.add_argument(
        "--duration",
        type=int,
        default=3,
    )
    selftest.add_argument(
        "--payload-size",
        type=int,
        default=DEFAULT_PAYLOAD_SIZE,
    )
    selftest.add_argument(
        "--interval-ms",
        type=int,
        default=DEFAULT_INTERVAL_MS,
    )

    return parser


def validate_args(args: argparse.Namespace) -> Optional[str]:
    if hasattr(args, "port") and not (1 <= args.port <= 65535):
        return "port must be between 1 and 65535"
    if hasattr(args, "payload_size") and args.payload_size <= 0:
        return "payload-size must be greater than 0"
    if hasattr(args, "duration") and args.duration < 0:
        return "duration must be >= 0"
    if hasattr(args, "connections") and args.connections <= 0:
        return "connections must be greater than 0"
    if hasattr(args, "interval_ms") and args.interval_ms <= 0:
        return "interval-ms must be greater than 0"
    return None


def install_signal_handler(stop_message: str) -> None:
    def _handler(signum: int, frame: object) -> None:
        del signum, frame
        print(stop_message, flush=True)
        raise KeyboardInterrupt

    signal.signal(signal.SIGINT, _handler)


def main(argv: list[str]) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    error = validate_args(args)
    if error:
        print(f"argument error: {error}", file=sys.stderr)
        return 2

    install_signal_handler("received interrupt signal")
    duration = None if getattr(args, "duration", 0) == 0 else args.duration

    if args.command == "tcp-echo-server":
        return tcp_echo_server(args.host, args.port, duration, args.payload_size)
    if args.command == "udp-echo-server":
        return udp_echo_server(args.host, args.port, duration, args.payload_size)
    if args.command == "tcp-push-client":
        return push_client(
            protocol="tcp",
            host=args.host,
            port=args.port,
            connections=args.connections,
            interval_ms=args.interval_ms,
            payload_size=args.payload_size,
            duration=args.duration,
        )
    if args.command == "udp-push-client":
        return push_client(
            protocol="udp",
            host=args.host,
            port=args.port,
            connections=args.connections,
            interval_ms=args.interval_ms,
            payload_size=args.payload_size,
            duration=args.duration,
        )
    if args.command == "self-test":
        return self_test(
            duration=args.duration,
            payload_size=args.payload_size,
            interval_ms=args.interval_ms,
        )

    parser.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
