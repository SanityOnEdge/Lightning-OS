import select
import time
import evdev
from evdev import UInput, ecodes

DEVICE_PATH = "/dev/input/by-id/ckb-CORSAIR_K60_RGB_PRO_Mechanical_Gaming_Keyboard_vKB_-event"
THRESHOLD = 0.030  # 30 ms buforowania mikro-przerw styku

dev = evdev.InputDevice(DEVICE_PATH)
time.sleep(0.5)
dev.grab()
ui = UInput.from_device(dev, name="Corsair-Filtered")

pressed_keys = set()
pending_releases = {}

try:
    while True:
        now = time.monotonic()
        timeout = None
        if pending_releases:
            next_release = min(pending_releases.values()) + THRESHOLD
            timeout = max(0.0, next_release - now)

        r, _, _ = select.select([dev.fd], [], [], timeout)
        now = time.monotonic()

        if r:
            for event in dev.read():
                if event.type == ecodes.EV_KEY:
                    code, val = event.code, event.value

                    if val == 1:
                        if code in pending_releases:
                            del pending_releases[code]
                            continue
                        if code not in pressed_keys:
                            pressed_keys.add(code)
                            ui.write(ecodes.EV_KEY, code, 1)
                            ui.syn()
                    elif val == 2:
                        if code in pressed_keys and code not in pending_releases:
                            ui.write(ecodes.EV_KEY, code, 2)
                            ui.syn()
                    elif val == 0:
                        if code in pressed_keys:
                            pending_releases[code] = now

        for code, rel_time in list(pending_releases.items()):
            if now - rel_time >= THRESHOLD:
                del pending_releases[code]
                pressed_keys.discard(code)
                ui.write(ecodes.EV_KEY, code, 0)
                ui.syn()
except KeyboardInterrupt:
    pass
finally:
    dev.ungrab()
    ui.close()
