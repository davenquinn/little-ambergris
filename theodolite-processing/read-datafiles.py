from sys import argv
from functools import reduce
import re
from IPython import embed

subs = [
    ("\+0+"," +"),
    ("-0+"," -"),
    ("^110","")]
for i in (81,82,83):
    subs.append(("{}\.\.00".format(i)," "))

subs = [(re.compile(s),v) for s,v in subs]
def clean(text):
    for s,v in subs:
        text = re.sub(s,v,text)
    return text

def read_data(fn):
    with open(fn) as f:
        for line in f:
            text = clean(line)
            print(text.strip())

for fn in argv[2:]:
    read_data(fn)
