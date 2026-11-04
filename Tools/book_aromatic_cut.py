"""Cut single structures from the Ch. 21 pages (21.20 roadmap, 21.18 o, 21.22 a–c) at 288 dpi. Each structure owns a
core box; ink blobs whose centre falls outside it are dropped, red labels are removed by colour, and the roadmap's
letters (A–W) and problem letters are erased."""
import fitz, sys, re, numpy as np
from PIL import Image
from scipy import ndimage
doc = fitz.open(sys.argv[1]); out = sys.argv[2]
S, M = 4, 4
cores = {
    "benzene":   (619, 79, 181, 121, 224),
    "bromo":     (619, 77, 286, 122, 358), "chloro": (619, 139, 286, 182, 358),
    "nitro":     (619, 199, 286, 245, 358), "sulfonic": (619, 262, 286, 309, 358),
    "ethyl":     (619, 325, 286, 379, 358), "acetophenone": (619, 424, 271, 482, 358),
    "benzaldehyde": (619, 485, 271, 536, 358),
    "aniline":   (619, 159, 374, 204, 441), "diazonium": (619, 262, 374, 327, 444),
    "arbr":      (619, 95, 521, 141, 588), "arcl": (619, 159, 521, 202, 588), "arf": (619, 222, 521, 265, 588),
    "ari":       (619, 285, 521, 328, 588), "aroh": (619, 345, 521, 389, 588), "arcn": (619, 409, 521, 452, 588),
    "benzene2":  (619, 469, 541, 515, 588), "diene": (619, 469, 645, 515, 698),
    "acetanilide": (618, 150, 196, 202, 275),
    "mebenzoate": (620, 65, 108, 139, 164), "phenylacetate": (620, 222, 118, 302, 164), "benzoic": (620, 369, 108, 435, 164),
}
for name, (pno, x0, y0, x1, y1) in cores.items():
    page = doc[pno]
    clip = fitz.Rect(x0 - M, y0 - M, x1 + M, y1 + M) & page.rect
    pm = page.get_pixmap(matrix=fitz.Matrix(S, S), clip=clip)
    rgb = np.array(Image.frombytes("RGB", (pm.width, pm.height), pm.samples)).astype(np.int16)
    red = (rgb[..., 0] - np.maximum(rgb[..., 1], rgb[..., 2])) > 25
    g = rgb.mean(axis=2)
    g[ndimage.binary_dilation(red, iterations=1)] = 255
    def px(x, y): return int((x - clip.x0) * S), int((y - clip.y0) * S)
    for b in page.get_text("dict")["blocks"]:
        for l in b.get("lines", []):
            for s in l["spans"]:
                t = s["text"].strip()
                letter = (len(t) == 1 and "Bold" in s["font"]) or re.fullmatch(r"[a-z]\)", t)   # roadmap A–W, problem a)
                if letter and fitz.Rect(s["bbox"]).intersects(clip):
                    r = fitz.Rect(s["bbox"])
                    (a0, b0), (a1, b1) = px(r.x0, r.y0), px(r.x1, r.y1)
                    g[max(0, b0):max(0, b1) + 2, max(0, a0):max(0, a1) + 2] = 255
    ink = g < 200
    lab, n = ndimage.label(ndimage.binary_dilation(ink, iterations=3))
    (cx0, cy0), (cx1, cy1) = px(x0, y0), px(x1, y1)
    for i, c in enumerate(ndimage.center_of_mass(ink, lab, range(1, n + 1)), start=1):
        if np.isnan(c[0]): continue
        if not (cy0 <= c[0] <= cy1 and cx0 <= c[1] <= cx1): g[lab == i] = 255
    lab2, n2 = ndimage.label(g < 200)
    for i in range(1, n2 + 1):
        if (lab2 == i).sum() < 6: g[lab2 == i] = 255
    ys, xs = np.where(g < 200); P = 8
    g = np.pad(g[ys.min():ys.max()+1, xs.min():xs.max()+1], P, constant_values=255)
    a = (255 - g).clip(0, 255).astype(np.uint8)
    Image.merge("LA", (Image.new("L", (g.shape[1], g.shape[0]), 0), Image.fromarray(a))).save(f"{out}/{name}.png")
print("ok", len(cores))
