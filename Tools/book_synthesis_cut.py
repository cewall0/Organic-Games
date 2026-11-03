"""Cut 11.40 / 11.47 structures (and acetylene) from the book at 288 dpi, black on transparent, labels like 'a)' removed."""
import fitz, sys, re, numpy as np
from PIL import Image
from scipy import ndimage
doc = fitz.open(sys.argv[1]); out = sys.argv[2]
boxes = {   # name: (pdf page, x0, y0, x1, y1)
    "s40a-sm": (347, 70, 305, 121, 345), "s40a-tg": (347, 146, 305, 200, 349),
    "s40b-sm": (347, 248, 305, 283, 347), "s40b-tg": (347, 320, 305, 366, 349),
    "s40c-sm": (347, 390, 301, 447, 349), "s40c-tg": (347, 485, 306, 553, 339),
    "s40d-sm": (347, 70, 351, 121, 393), "s40d-tg": (347, 141, 351, 195, 394),
    "s40e-sm": (347, 206, 348, 262, 394), "s40e-tg": (347, 278, 351, 333, 392),
    "s40f-sm": (347, 350, 353, 401, 392), "s40f-tg": (347, 425, 356, 472, 392),
    "s47b-tg": (348, 207, 341, 312, 374), "s47c-tg": (348, 351, 331, 469, 374),
    "s47d-tg": (348, 67, 373.5, 173, 422), "s47e-tg": (348, 205, 373, 312, 415),
    "s47j-tg": (348, 62, 437, 140, 484), "s47l-tg": (348, 349, 443, 431, 482),
    "s47m-tg": (348, 70, 483, 127, 522), "s47n-tg": (348, 207, 491, 321, 524),
    "s47o-tg": (348, 356, 483, 442, 524),
    "acetylene": (101, 340, 508, 388, 525),
}
S = 4
arrows = {"s40a-sm": [(113, 324, 336)], "s40c-sm": [(438, 321, 330)], "s40d-sm": [(108, 371, 382)],
          "s40e-sm": [(257, 370, 380)], "s40f-sm": [(390, 374, 385)]}
for name, (pno, x0, y0, x1, y1) in boxes.items():
    page = doc[pno]; clip = fitz.Rect(x0, y0, x1, y1)
    pm = page.get_pixmap(matrix=fitz.Matrix(S, S), clip=clip)
    g = np.array(Image.frombytes("RGB", (pm.width, pm.height), pm.samples).convert("L")).astype(np.int16)
    for b in page.get_text("dict")["blocks"]:          # erase problem letters "a)"... inside the box
        for l in b.get("lines", []):
            for s in l["spans"]:
                if re.fullmatch(r"\s*[a-o]\)\s*", s["text"]) and fitz.Rect(s["bbox"]).intersects(clip):
                    r = fitz.Rect(s["bbox"]) & clip
                    g[int((r.y0-y0)*S):int((r.y1-y0)*S)+2, int((r.x0-x0)*S):int((r.x1-x0)*S)+2] = 255
    for ex0, ey0, ey1 in arrows.get(name, []):       # the reaction arrow's tail, beside Cl/Br labels
        g[int((ey0-y0)*S):int((ey1-y0)*S), int((ex0-x0)*S):] = 255
    lab, n = ndimage.label(g < 200)
    for i, (ys, xs) in enumerate(ndimage.find_objects(lab), start=1):
        h, w = ys.stop - ys.start, xs.stop - xs.start
        if (lab == i).sum() < 6: g[lab == i] = 255
    ys, xs = np.where(g < 200); P = 6
    g = np.pad(g[ys.min():ys.max()+1, xs.min():xs.max()+1], P, constant_values=255)
    a = (255 - g).clip(0, 255).astype(np.uint8)
    Image.merge("LA", (Image.new("L", (g.shape[1], g.shape[0]), 0), Image.fromarray(a))).save(f"{out}/{name}.png")
print("ok", len(boxes))
