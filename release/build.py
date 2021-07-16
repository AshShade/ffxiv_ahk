import shutil
import yaml
import os
from string import Template
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

with open("config.yaml","r") as f:
    config = yaml.load(f,Loader=Loader)
dist = "./dist/"
try:
    shutil.rmtree(dist)
except FileNotFoundError:
    pass

os.mkdir(dist)

with open(config["input"]["instruction"],"r") as fin,open(dist + config["output"]["instruction"],"w") as fout:
    t = Template(fin.read()).substitute(config["template"])
    fout.write(t)
for ft in ["script","txt"]:
    shutil.copyfile(config["input"][ft],dist + config["output"][ft])

shutil.make_archive(config["output"]["zip"] + "@" + config["version"],"zip",dist)
shutil.rmtree(dist)
print("Done")