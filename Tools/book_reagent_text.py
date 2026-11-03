"""Wrong-answer reagent text cut letter-exact from the book's own Calibri, scaled to the 9.13 summary's 7.2 pt, 288 dpi."""
import fitz, sys, numpy as np
from scipy import ndimage
from PIL import Image
doc = fitz.open(sys.argv[1]); out = sys.argv[2]
TARGET = 7.2
want = {"x-nacl": "NaCl", "x-nabr": "NaBr", "x-cl2": "Cl2", "x-i2": "I2", "x-br2-ccl4": "Br2, CCl4"}
found = {}
for pno in range(len(doc)):
    if len(found) == len(want): break
    for b in doc[pno].get_text("rawdict")["blocks"]:
        for l in b.get("lines", []):
            chars = [(c, s["size"], s["font"]) for s in l["spans"] for c in s["chars"]]
            text = "".join(c["c"] for c, _, _ in chars)
            for name, t in want.items():
                if name in found: continue
                i = text.find(t)
                while i >= 0:
                    seg = chars[i:i + len(t)]
                    before = text[i-1] if i > 0 else " "; after = text[i+len(t)] if i + len(t) < len(text) else " "
                    ok = all("Calibri" in f and "Bold" not in f for _, _, f in seg) and not before.isalnum() and not (after.isalnum() or after == "₂")
                    subs = [(c, sz) for c, sz, _ in seg if c["c"] in "24"]
                    ok = ok and all(0.7 * seg[0][1] <= sz <= 0.8 * seg[0][1] and c["origin"][1] > seg[0][0]["origin"][1] + 0.8 for c, sz in subs) and after in " \n\t"
                    if ok:
                        main = seg[0][1]
                        r = fitz.Rect(seg[0][0]["bbox"]);  [r.include_rect(fitz.Rect(c["bbox"])) for c, _, _ in seg]
                        found[name] = (pno, main, r, t); break
                    i = text.find(t, i + 1)
for name, (pno, main, r, t) in found.items():
    z = 4 * TARGET / main
    clip = fitz.Rect(r.x0 - 0.3, r.y0, r.x1 + 0.3, r.y1)
    pm = doc[pno].get_pixmap(matrix=fitz.Matrix(z, z), clip=clip)
    g = np.array(Image.frombytes("RGB", (pm.width, pm.height), pm.samples).convert("L"))
    lab, n = ndimage.label(g < 200)          # drop specks from neighboring lines (a comma is ~20 px)
    for i in range(1, n + 1):
        if (lab == i).sum() < 10: g[lab == i] = 255
    ys, xs = np.where(g < 200); P = 6
    g = np.pad(g[ys.min():ys.max()+1, xs.min():xs.max()+1], P, constant_values=255)
    a = (255 - g).astype(np.uint8)
    Image.merge("LA", (Image.new("L", (g.shape[1], g.shape[0]), 0), Image.fromarray(a))).save(f"{out}/{name}-reagents.png")
    print(name, "page", pno, "size", main, Image.open(f"{out}/{name}-reagents.png").size)
print("missing", set(want) - set(found))
