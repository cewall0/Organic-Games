"""Cut whole lettered reactions (9.75 a–l, 9.23 a–d) from the book at 288 dpi. Each reaction owns a 'core' box
(its row, between its letter label and the next); ink is cropped with a margin and any blob whose centre lies
outside the core (a neighbour's bond poking in) is dropped. Letter labels are erased."""
import fitz, sys, re, numpy as np
from PIL import Image
from scipy import ndimage
doc = fitz.open(sys.argv[1]); out = sys.argv[2]
S, M = 4, 10
cores = {  # name: (page, x0, y0, x1, y1) in PDF points
    "m75a": (283, 54, 268, 205, 361), "m75b": (283, 205, 268, 560, 361),
    "m75c": (283, 54, 361, 228, 423), "m75d": (283, 228, 361, 560, 423),
    "m75e": (283, 54, 423, 272, 481), "m75f": (283, 272, 423, 560, 481),
    "m75g": (283, 54, 481, 272, 518), "m75h": (283, 272, 481, 560, 518),
    "m75i": (283, 54, 518, 318, 569), "m75j": (283, 318, 518, 560, 569),
    "m75k": (283, 54, 569, 252, 618), "m75l": (283, 252, 569, 560, 618),
    "m23a": (273, 81, 252, 178, 308), "m23b": (273, 178, 252, 300, 308),
    "m23c": (273, 300, 252, 412, 308), "m23d": (273, 412, 252, 545, 304),
}
for name, (pno, x0, y0, x1, y1) in cores.items():
    page = doc[pno]
    m = 2 if name.startswith("m23") else M     # 9.23 sits in a framed box: stay inside the frame
    clip = fitz.Rect(x0 - m, y0 - m, x1 + m, y1 + m) & page.rect
    pm = page.get_pixmap(matrix=fitz.Matrix(S, S), clip=clip)
    g = np.array(Image.frombytes("RGB", (pm.width, pm.height), pm.samples).convert("L")).astype(np.int16)
    def px(x, y): return int((x - clip.x0) * S), int((y - clip.y0) * S)
    for b in page.get_text("dict")["blocks"]:          # erase "a)" labels (just the letter and paren)
        for l in b.get("lines", []):
            for s in l["spans"]:
                if re.fullmatch(r"\s*[a-l]\)\s*", s["text"]):
                    r = fitz.Rect(s["bbox"]); lx0 = r.x1 - 13
                    if fitz.Rect(lx0, r.y0, r.x1, r.y1).intersects(clip):
                        (a0, b0), (a1, b1) = px(lx0, r.y0), px(r.x1, r.y1)
                        g[max(0, b0):max(0, b1) + 2, max(0, a0):max(0, a1) + 2] = 255
    ink = g < 200
    lab, n = ndimage.label(ndimage.binary_dilation(ink, iterations=3))
    (cx0, cy0), (cx1, cy1) = px(x0, y0), px(x1, y1)
    for i, c in enumerate(ndimage.center_of_mass(ink, lab, range(1, n + 1)), start=1):
        if np.isnan(c[0]): continue
        cy, cx = c
        if not (cy0 <= cy <= cy1 and cx0 <= cx <= cx1): g[lab == i] = 255
    lab2, n2 = ndimage.label(g < 200)
    for i in range(1, n2 + 1):
        if (lab2 == i).sum() < 6: g[lab2 == i] = 255
    ys, xs = np.where(g < 200); P = 8
    g = np.pad(g[ys.min():ys.max()+1, xs.min():xs.max()+1], P, constant_values=255)
    a = (255 - g).clip(0, 255).astype(np.uint8)
    Image.merge("LA", (Image.new("L", (g.shape[1], g.shape[0]), 0), Image.fromarray(a))).save(f"{out}/{name}.png")
print("ok", len(cores))
