"""Book reaction pieces (book_split.py output, 288 dpi) -> asset catalog folder as @3x images.
usage: build_book_assets.py SPLITDIR ASSETDIR prefix=pPAGEletter:name ...   e.g. p276g:r9g"""
import sys, os, json, shutil
src, out = sys.argv[1], sys.argv[2]
if os.path.isdir(out): shutil.rmtree(out)
os.makedirs(out)
json.dump({"info": {"author": "xcode", "version": 1}, "properties": {"provides-namespace": False}}, open(f"{out}/Contents.json", "w"), indent=2)
for spec in sys.argv[3:]:
    key, name = spec.split(":")
    for part in ("sm", "reagents", "product"):
        f = f"{src}/{key}-{part}.png"
        if not os.path.exists(f): print("missing", f); continue
        n = f"bk-{name}-{part}"; d = f"{out}/{n}.imageset"; os.makedirs(d)
        shutil.copy(f, f"{d}/{n}.png")
        json.dump({"images": [{"filename": f"{n}.png", "idiom": "universal", "scale": "2x"}], "info": {"author": "xcode", "version": 1}},
                  open(f"{d}/Contents.json", "w"), indent=2)
print(len(os.listdir(out)) - 1, "images")
