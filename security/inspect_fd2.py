#!/bin/env python3

import os, re, socket, struct

TCP_STATES = {
    "01": "ESTABLISHED",
    "02": "SYN_SENT",
    "03": "SYN_RECV",
    "04": "FIN_WAIT1",
    "05": "FIN_WAIT2",
    "06": "TIME_WAIT",
    "07": "CLOSE",
    "08": "CLOSE_WAIT",
    "09": "LAST_ACK",
    "0A": "LISTEN",
    "0B": "CLOSING"
}

NETLINK_PROTOS = {
    "0":  "[0]  RTNETLINK (Routing)",
    "4":  "[4]  NETLINK_AUDIT",
    "12": "[12] NETLINK_XFRM (IPsec)",
    "15": "[15] NETLINK_SCSITRANSPORT",
    "16": "[16] NETLINK_NETFILTER (OVS/Conntrack)",
    "18": "[18] NETLINK_DNRTMSG",
    "19": "[19] NETLINK_KOBJECT_UEVENT"
}

def hex_to_ip(hex_str):
    try:
        ip_hex = hex_str.split(':')[0]
        if len(ip_hex) == 8: # IPv4
            return socket.inet_ntoa(struct.pack("<L", int(ip_hex, 16)))
        elif len(ip_hex) == 32: # IPv6
            parts = struct.unpack("<LLLL", bytes.fromhex(ip_hex))
            return socket.inet_ntop(socket.AF_INET6, struct.pack(">LLLL", *parts))
    except: return "0.0.0.0"

def get_net_cache():
    cache = {}
    for family in ['tcp', 'udp', 'tcp6', 'udp6', 'unix', 'netlink']:
        path = f"/proc/net/{family}"
        if not os.path.exists(path): continue
        with open(path, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if not parts or parts[0] in ["sl", "sk"]: continue

                # Inode is column 9 for TCP/UDP, 6 for UNIX, 9 for Netlink
                inode = parts[-1] if family == 'netlink' else (parts[6] if family == 'unix' else parts[9])

                if family in ['tcp', 'udp', 'tcp6', 'udp6']:
                    state = TCP_STATES.get(parts[3], "UNKNOWN") if "tcp" in family else "N/A"
                    ip_port = f"{hex_to_ip(parts[1])}:{int(parts[1].split(':')[1], 16)}"
                    cache[inode] = (family.upper(), f"[{state}] {ip_port}")
                elif family == 'unix':
                    path_str = parts[-1] if len(parts) > 7 else "Anonymous"
                    cache[inode] = ("UNIX", path_str)
                elif family == 'netlink':
                    proto = parts[1]
                    desc = NETLINK_PROTOS.get(proto, f"Protocol: {proto}")
                    cache[inode] = ("NETLINK", desc)
    return cache

def get_inotify_details(pid, fd):
    try:
        with open(f"/proc/{pid}/fdinfo/{fd}", 'r') as f:
            for line in f:
                if "inotify wd:" in line:
                    m = re.search(r'wd:(\d+) ino:([a-f0-9]+) sdev:([a-f0-9]+)', line)
                    if m: return f"WatchID:{m.group(1)} TargetIno:0x{m.group(2)} Dev:0x{m.group(3)}"
    except: pass
    return "No active watch"

def run_inspector(pid):
    fd_path = f"/proc/{pid}/fd"
    if not os.path.exists(f"/proc/{pid}"):
        print(f"Error: Process with PID {pid} does not exist.")
        return

    if not os.access(fd_path, os.R_OK):
        print("You lack of permission to inspect process. Escalated permission required.")
        return

    net_cache = get_net_cache()
    print(f"{'FD':<4} {'INODE':<10} {'Type':<10} {'Details'}")
    print("-" * 90)

    for fd in sorted(os.listdir(fd_path), key=int):
        try:
            target = os.readlink(os.path.join(fd_path, fd))
            inode_match = re.search(r'\[(\d+)\]', target)
            real_inode = inode_match.group(1) if inode_match else str(os.stat(os.path.join(fd_path, fd)).st_ino)

            std_map = {"0": "stdin", "1": "stdout", "2": "stderr"}
            fd_label = std_map.get(fd, "")

            if target.startswith("socket:"):
                t, d = net_cache.get(real_inode, ("SOCKET", f"Inode: {real_inode}"))
                print(f"{fd:<4} {real_inode:<10} {t:<10} {d}")
            elif "inotify" in target:
                print(f"{fd:<4} {real_inode:<10} {'INOTIFY':<10} {get_inotify_details(pid, fd)}")
            elif "pipe" in target:
                print(f"{fd:<4} {real_inode:<10} {'PIPE':<10} {target}")
            elif fd_label:
                print(f"{fd:<4} {real_inode:<10} {fd_label:<10} {target}")
            else:
                print(f"{fd:<4} {real_inode:<10} {'FILE':<10} {target}")
        except: continue

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        run_inspector(sys.argv[1])
    else:
        print("Usage: python3 inspect_fd.py <PID>")
