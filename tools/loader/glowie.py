import asyncio
from collections.abc import Iterator
import re

from bleak import BleakClient, BleakScanner

discover_srvc_uuid = "00000000-1fbd-0481-2a47-f3b657518ec1"
cmd_in_uuid = "00000001-1fbd-0481-2a47-f3b657518ec1"

cmd_max_length = 512
script_max_length = cmd_max_length - len("run ")

def compact_script(script: str) -> str:
    """Make script more compact by removing comments and extra whitespaces"""
    script = re.sub("--.*\n", "", script)
    return " ".join(script.split())

def generate_multipart_script(script: str) -> Iterator[str]:
    seq = 0

    header = f"mrun 0 {len(script)} "
    first_packet_script_len = cmd_max_length - len(header)
    yield header + script[:first_packet_script_len]
    remaining = script[first_packet_script_len:]
    seq += 1

    while(remaining):
        header = f"mrun {seq} "
        packet_script_len = cmd_max_length - len(header)
        yield header + remaining[:packet_script_len]
        remaining = remaining[packet_script_len:]
        seq += 1

    yield f"mrun ${seq}"

class Glowie:
    def __init__(self, device):
        self.event_loop = asyncio.new_event_loop()
        self.ble_client = BleakClient(device)

    def __enter__(self):
        self.event_loop.run_until_complete(self.ble_client.connect())

    def __exit__(self, *args):
        self.event_loop.run_until_complete(self.ble_client.disconnect())

    def send_command(self, cmd: str):
        # print("sending: " + cmd)
        assert self.ble_client.is_connected, "Glowie is not connected"
        data = cmd.encode()
        self.event_loop.run_until_complete(
            self.ble_client.write_gatt_char(cmd_in_uuid, data, response=True)
        )

    def send_script(self, script: str):
        assert self.ble_client.is_connected, "Glowie is not connected"
        compacted = compact_script(script)

        if len(compacted) <= script_max_length:
            self.send_command("run " + compacted)
        else:
            for cmd in generate_multipart_script(compacted):
                print(cmd[:20] + " ...")
                self.send_command(cmd)


def filter(dev, adv) -> bool:
    return discover_srvc_uuid in adv.service_uuids


def find_glowie() -> Glowie | None:
    device = asyncio.run(BleakScanner.find_device_by_filter(filter))
    if device is None:
        return None
    else:
        return Glowie(device)
