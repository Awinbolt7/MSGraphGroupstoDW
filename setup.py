#init module
from config import package_handler as ph
from time import sleep

#handle packages
for package in ph.package_list:
    ph.handler(package)
    sleep(1)
