#!/usr/bin/env python3

import argparse
import sys, os, struct, code, binascii
import serial, time, re, math

GLITCH_DEFAULT_UART_TRIGGER_EXP_BYTE = b'\xD9'

RPC_MAGIC = b'@'
RPC_WATERMARK = b'!PC_'
RPC_COMMANDS = {
    "ping" : 0x0,
    "read32" : 0x1,
    "write32" : 0x2,
    "memset" : 0x3,
    "memcpy" : 0x4,
    "delay" : 0x5, # arg0 : check delay
    "stop" : 0x6,
    "hexdump" : 0x7,
    "memset32" : 0x8,
    "glitch_prep_ll" : 0x9,
    "glitch_arm" : 0xa,
    "glitch_prep_custom" : 0xb,
    "glitch_prep_uart" : 0xc,
    "set_clk" : 0xd
}

def send_rpc_cmd(uart, id, argv):
    data = bytearray()
    for arg in argv:
        data.extend(struct.pack('<I', arg))
    uart.write(bytearray([int.from_bytes(RPC_MAGIC, "little"), RPC_COMMANDS[id], len(data), (RPC_COMMANDS[id] + len(data))]))
    cont = uart.readline()
    while not RPC_WATERMARK in cont:
        cont = uart.readline()
    if cont == RPC_WATERMARK + b'G1\r\n':
        uart.write(data)
        cont = uart.readline()
        while not RPC_WATERMARK in cont:
            cont = uart.readline()
    cont = cont.decode('utf-8').strip("!PC_")
    print(cont)

def main(args):
    uart = serial.Serial(args.port, baudrate=args.baud, timeout=0)
    if args.rpc_cmd == "manual":
        uart.write(GLITCH_DEFAULT_UART_TRIGGER_EXP_BYTE)
    else:
        argv = []
        for arg in args.rpc_args:
            argv.append(int(arg, 0))
        send_rpc_cmd(uart, args.rpc_cmd, argv)
    uart.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="rpclient")
    parser.add_argument(
        "-p",
        "--port",
        required=True,
        help="Serial port to use",
    )
    parser.add_argument(
        "-b",
        "--baud",
        required=False,
        default=115200,
        help="Baud to use",
    )
    parser.add_argument(
        "rpc_cmd",
        metavar="RPC CMD",
        choices=["manual", *RPC_COMMANDS.keys()],
        help="RPC commands to send to Teensy",
    )
    parser.add_argument(
        "rpc_args",
        metavar="RPC ARG",
        nargs="*",
        help="RPC arguments to send to Teensy",
    )
    args = parser.parse_args()
    main(args)
