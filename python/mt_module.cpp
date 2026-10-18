#define PY_SSIZE_T_CLEAN

#include <Python.h>

#include <cstdint>
#include <memory>
#include <string>
#include <utility>

#include <mt/mt.hpp>
#include <mt/version.hpp>

namespace {

using DeviceHandle = decltype(mt::Device::systemDefault());

PyObject* g_mt_error = nullptr;

typedef struct {
    PyObject_HEAD
    DeviceHandle* handle;
} PyMTDevice;

PyTypeObject PyMTDeviceType = {
    PyVarObject_HEAD_INIT(nullptr, 0)
};

bool require_device(
    const PyMTDevice* self,
    DeviceHandle** handle
) {
    if (self == nullptr || self->handle == nullptr || !*self->handle) {
        PyErr_SetString(
            g_mt_error,
            "The mt.Device handle is no longer valid."
        );
        return false;
    }
    *handle = self->handle;
    return true;
}

PyObject* device_info_dict(const mt::DeviceInfo& info) {
    PyObject* result = PyDict_New();
    if (result == nullptr) {
        return nullptr;
    }
    const std::string name(info.name());
    auto set_object = [&](const char* key, PyObject* value) {
        if (value == nullptr || PyDict_SetItemString(result, key, value) < 0) {
            Py_XDECREF(value);
            return false;
        }
        Py_DECREF(value);
        return true;
    };
    if (!set_object("name", PyUnicode_FromString(name.c_str()))
        || !set_object(
            "registry_id",
            PyLong_FromUnsignedLongLong(info.registryID())
        )
        || !set_object(
            "type",
            PyLong_FromLong(static_cast<long>(info.type()))
        )
        || !set_object(
            "low_power",
            PyBool_FromLong(info.lowPower() ? 1 : 0)
        )
        || !set_object(
            "removable",
            PyBool_FromLong(info.removable() ? 1 : 0)
        )
        || !set_object(
            "recommended_max_working_set_size",
            PyLong_FromUnsignedLongLong(
                info.recommendedMaxWorkingSetSize()
            )
        )) {
        Py_DECREF(result);
        return nullptr;
    }
    return result;
}

PyObject* mt_version(PyObject*, PyObject*) {
    return PyUnicode_FromString(mt::library_version());
}

PyObject* mt_devices(PyObject*, PyObject*) {
    try {
        const auto devices = mt::Device::enumerate();
        PyObject* result = PyList_New(0);
        if (result == nullptr) {
            return nullptr;
        }
        for (const auto& info : devices) {
            PyObject* item = device_info_dict(info);
            if (item == nullptr || PyList_Append(result, item) < 0) {
                Py_XDECREF(item);
                Py_DECREF(result);
                return nullptr;
            }
            Py_DECREF(item);
        }
        return result;
    } catch (...) {
        PyErr_SetString(g_mt_error, "Metal device enumeration failed.");
        return nullptr;
    }
}

PyObject* make_device(DeviceHandle handle) {
    PyMTDevice* result = PyObject_New(PyMTDevice, &PyMTDeviceType);
    if (result == nullptr) {
        return nullptr;
    }
    try {
        result->handle = new DeviceHandle(std::move(handle));
    } catch (...) {
        PyObject_Del(result);
        PyErr_SetString(g_mt_error, "Could not allocate an mt.Device handle.");
        return nullptr;
    }
    return reinterpret_cast<PyObject*>(result);
}

PyObject* mt_default_device(PyObject*, PyObject*) {
    try {
        DeviceHandle handle = mt::Device::systemDefault();
        if (!handle) {
            Py_RETURN_NONE;
        }
        return make_device(std::move(handle));
    } catch (...) {
        PyErr_SetString(g_mt_error, "Could not create the default Metal device.");
        return nullptr;
    }
}

PyObject* mt_device_from_registry_id(PyObject*, PyObject* args) {
    unsigned long long registryID = 0;
    if (!PyArg_ParseTuple(args, "K:device_from_registry_id", &registryID)) {
        return nullptr;
    }
    try {
        DeviceHandle handle = mt::Device::fromRegistryID(
            static_cast<std::uint64_t>(registryID)
        );
        if (!handle) {
            Py_RETURN_NONE;
        }
        return make_device(std::move(handle));
    } catch (...) {
        PyErr_SetString(g_mt_error, "Could not create the requested device.");
        return nullptr;
    }
}

PyObject* PyMTDevice_info(PyMTDevice* self, void*) {
    DeviceHandle* handle = nullptr;
    if (!require_device(self, &handle)) {
        return nullptr;
    }
    try {
        return device_info_dict((*handle)->info());
    } catch (...) {
        PyErr_SetString(g_mt_error, "Could not read device information.");
        return nullptr;
    }
}

PyObject* PyMTDevice_repr(PyMTDevice* self) {
    PyObject* info = PyMTDevice_info(self, nullptr);
    if (info == nullptr) {
        return nullptr;
    }
    PyObject* name = PyDict_GetItemString(info, "name");
    PyObject* result = PyUnicode_FromFormat(
        "mt.Device(name=%U)",
        name == nullptr ? Py_None : name
    );
    Py_DECREF(info);
    return result;
}

void PyMTDevice_dealloc(PyMTDevice* self) {
    delete self->handle;
    self->handle = nullptr;
    Py_TYPE(self)->tp_free(reinterpret_cast<PyObject*>(self));
}

PyMethodDef module_methods[] = {
    {
        "version",
        mt_version,
        METH_NOARGS,
        "Return the installed mt library version."
    },
    {
        "devices",
        mt_devices,
        METH_NOARGS,
        "Return value-only information for all Metal devices."
    },
    {
        "default_device",
        mt_default_device,
        METH_NOARGS,
        "Return an owned Python handle for the system Metal device, or None."
    },
    {
        "device_from_registry_id",
        mt_device_from_registry_id,
        METH_VARARGS,
        "Return a device handle for a Metal registry ID, or None."
    },
    {nullptr, nullptr, 0, nullptr}
};

PyGetSetDef device_getset[] = {
    {
        "info",
        reinterpret_cast<getter>(PyMTDevice_info),
        nullptr,
        "Return a snapshot of device information.",
        nullptr
    },
    {nullptr, nullptr, nullptr, nullptr, nullptr}
};

PyModuleDef module_definition = {
    PyModuleDef_HEAD_INIT,
    "mt",
    "Optional Python bindings for the installed Swift/Metal mt C++ API.",
    -1,
    module_methods,
    nullptr,
    nullptr,
    nullptr,
    nullptr
};

} // namespace

PyMODINIT_FUNC PyInit_mt() {
    PyMTDeviceType.tp_name = "mt.Device";
    PyMTDeviceType.tp_basicsize = sizeof(PyMTDevice);
    PyMTDeviceType.tp_flags = Py_TPFLAGS_DEFAULT;
    PyMTDeviceType.tp_doc =
        "Owned Python handle for an application-selected Metal device.";
    PyMTDeviceType.tp_dealloc =
        reinterpret_cast<destructor>(PyMTDevice_dealloc);
    PyMTDeviceType.tp_repr = reinterpret_cast<reprfunc>(PyMTDevice_repr);
    PyMTDeviceType.tp_getset = device_getset;
    if (PyType_Ready(&PyMTDeviceType) < 0) {
        return nullptr;
    }

    PyObject* module = PyModule_Create(&module_definition);
    if (module == nullptr) {
        return nullptr;
    }
    g_mt_error = PyErr_NewException("mt.Error", PyExc_RuntimeError, nullptr);
    if (g_mt_error == nullptr) {
        Py_DECREF(module);
        return nullptr;
    }
    Py_INCREF(&PyMTDeviceType);
    if (PyModule_AddObject(module, "Error", g_mt_error) < 0) {
        Py_DECREF(g_mt_error);
        g_mt_error = nullptr;
        Py_DECREF(&PyMTDeviceType);
        Py_DECREF(module);
        return nullptr;
    }
    if (PyModule_AddObject(
            module,
            "Device",
            reinterpret_cast<PyObject*>(&PyMTDeviceType)
        ) < 0) {
        Py_DECREF(&PyMTDeviceType);
        Py_DECREF(module);
        return nullptr;
    }
    return module;
}
