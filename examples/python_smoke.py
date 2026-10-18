"""Small opt-in smoke example for the installed ``mt`` Python module."""

import mt


print(f"mt {mt.version()}")
for device in mt.devices():
    print(
        f"{device['name']} "
        f"(registry_id={device['registry_id']}, type={device['type']})"
    )

default = mt.default_device()
if default is not None:
    print(f"default device: {default!r}")
