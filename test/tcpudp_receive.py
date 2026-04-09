import asyncio
import time

# 配置参数
HOST = '0.0.0.0'
TCP_PORT = 8888
UDP_PORT = 8889
REPORT_INTERVAL = 1.0  # 统计报告间隔（秒）

class Stats:
    def __init__(self):
        self.tcp_bytes = 0
        self.udp_bytes = 0
        self.start_time = time.time()

    def report(self):
        curr_time = time.time()
        elapsed = curr_time - self.start_time
        if elapsed >= REPORT_INTERVAL:
            tcp_mbps = (self.tcp_bytes * 8) / (elapsed * 1024 * 1024)
            udp_mbps = (self.udp_bytes * 8) / (elapsed * 1024 * 1024)
            print(f"[{time.strftime('%H:%M:%S')}] "
                  f"TCP: {tcp_mbps:.2f} Mbps | "
                  f"UDP: {udp_mbps:.2f} Mbps")
            self.tcp_bytes = 0
            self.udp_bytes = 0
            self.start_time = curr_time

stats = Stats()

# --- TCP 处理逻辑 ---
async def handle_tcp_client(reader, writer):
    addr = writer.get_extra_info('peername')
    print(f"TCP 连接已建立: {addr}")
    try:
        while True:
            data = await reader.read(65536) # 64KB 缓冲区
            if not data:
                break
            stats.tcp_bytes += len(data)
    except Exception as e:
        print(f"TCP 错误: {e}")
    finally:
        writer.close()
        await writer.wait_closed()
        print(f"TCP 连接已断开: {addr}")

# --- UDP 处理逻辑 ---
class UDPProtocol(asyncio.DatagramProtocol):
    def datagram_received(self, data, addr):
        stats.udp_bytes += len(data)

# --- 报告定时器 ---
async def stats_reporter():
    while True:
        stats.report()
        await asyncio.sleep(REPORT_INTERVAL)

# --- 主程序 ---
async def main():
    loop = asyncio.get_running_loop()

    # 启动 TCP Server
    tcp_server = await asyncio.start_server(handle_tcp_client, HOST, TCP_PORT)
    print(f"TCP 监听中: {HOST}:{TCP_PORT}")

    # 启动 UDP Server
    udp_transport, _ = await loop.create_datagram_endpoint(
        lambda: UDPProtocol(),
        local_addr=(HOST, UDP_PORT)
    )
    print(f"UDP 监听中: {HOST}:{UDP_PORT}")

    # 启动统计报告
    reporter_task = asyncio.create_task(stats_reporter())

    async with tcp_server:
        await tcp_server.serve_forever()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n服务器已停止。")