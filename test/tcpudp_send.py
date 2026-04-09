import asyncio
import socket
import time
import argparse

# --- 配置参数 ---
CHUNK_SIZE = 1400  # 单个数据包大小 (字节)，避开 MTU 分片
REPORT_INTERVAL = 1.0

class SenderStats:
    def __init__(self):
        self.total_bytes = 0
        self.start_time = time.time()

    def report(self, mode):
        elapsed = time.time() - self.start_time
        mbps = (self.total_bytes * 8) / (elapsed * 1024 * 1024)
        print(f"[{mode}] 已发送: {self.total_bytes / (1024*1024):.2f} MB | 当前速率: {mbps:.2f} Mbps")
        self.total_bytes = 0
        self.start_time = time.time()

# --- TCP 发送逻辑 ---
async def tcp_sender(host, port, duration):
    stats = SenderStats()
    data = b'X' * CHUNK_SIZE
    try:
        reader, writer = await asyncio.open_connection(host, port)
        print(f"连接到 TCP 服务器 {host}:{port}")

        end_time = time.time() + duration
        last_report = time.time()

        while time.time() < end_time:
            writer.write(data)
            await writer.drain() # 确保数据送入缓冲区
            stats.total_bytes += len(data)

            if time.time() - last_report >= REPORT_INTERVAL:
                stats.report("TCP")
                last_report = time.time()

        writer.close()
        await writer.wait_closed()
    except Exception as e:
        print(f"TCP 错误: {e}")

# --- UDP 发送逻辑 ---
async def udp_sender(host, port, duration):
    stats = SenderStats()
    data = b'X' * CHUNK_SIZE
    # 使用原始 socket 提升 UDP 效率
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    print(f"向 UDP 服务器 {host}:{port} 发送数据...")
    end_time = time.time() + duration
    last_report = time.time()

    try:
        while time.time() < end_time:
            sock.sendto(data, (host, port))
            stats.total_bytes += len(data)

            # UDP 没阻塞，手动加个微小的 sleep 防止完全挤死 CPU
            await asyncio.sleep(0)

            if time.time() - last_report >= REPORT_INTERVAL:
                stats.report("UDP")
                last_report = time.time()
    except Exception as e:
        print(f"UDP 错误: {e}")
    finally:
        sock.close()

# --- 主程序 ---
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="网络性能测试发送端")
    parser.add_argument("host", help="服务器 IP 地址")
    parser.add_argument("mode", choices=["tcp", "udp"], help="发送模式")
    parser.add_argument("-p", "--port", type=int, help="端口 (TCP默认8888, UDP默认8889)")
    parser.add_argument("-t", "--time", type=int, default=10, help="测试持续时间 (秒)")

    args = parser.parse_args()

    # 自动选择端口
    if not args.port:
        target_port = 8888 if args.mode == "tcp" else 8889
    else:
        target_port = args.port

    try:
        if args.mode == "tcp":
            asyncio.run(tcp_sender(args.host, target_port, args.time))
        else:
            asyncio.run(udp_sender(args.host, target_port, args.time))
    except KeyboardInterrupt:
        print("\n发送已停止。")