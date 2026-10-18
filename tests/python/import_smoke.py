"""Import and lifetime smoke test for the optional installed mt module."""

import gc

import mt


assert isinstance(mt.version(), str)
assert isinstance(mt.devices(), list)
assert mt.device_from_registry_id(0) is None

try:
    mt.device_from_registry_id("not an integer")
except TypeError:
    pass
else:
    raise AssertionError("registry IDs must reject non-integer values")

device = mt.default_device()
if device is not None:
    assert isinstance(device.info, dict)
    assert isinstance(repr(device), str)
    del device
    gc.collect()
