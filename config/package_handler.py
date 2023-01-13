import importlib.util, pip, sys

package_list = ['wheel','msal','requests','pandas','pyodbc','sqlalchemy']

def import_or_install(package):
    try:
        __import__(package)
    except ImportError:
        pip.main(['install', '--user', package])

def handler(name):

    if name in sys.modules:
        print(f"{name!r} already in sys.modules")
    elif (spec := importlib.util.find_spec(name)) is not None:
        # If you choose to perform the actual import ...
        module = importlib.util.module_from_spec(spec)
        sys.modules[name] = module
        spec.loader.exec_module(module)
        print(f"{name!r} has been imported")
    else:
        print(f"can't find the {name!r} module ... attemping to install")
        import_or_install(name)