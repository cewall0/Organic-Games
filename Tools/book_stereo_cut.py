"""Cut single molecules from the Ch. 7 pages (7.2, 7.3, 7.5, 7.8, 7.19) at 288 dpi, the way book_aromatic_cut.py does,
and find every atom position in each drawing from the vector bonds: bond ends, wedge tips and Fischer crossings.
Writes NAME.png, atoms.json ({name: [[x, y], ...]} as 0–1 fractions of the image) and NAME-atoms.png overlays
numbered so the stereocenters can be picked by index.

usage: book_stereo_cut.py BOOK.pdf OUTDIR"""
import fitz, sys, re, json, numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
doc = fitz.open(sys.argv[1]); out = sys.argv[2]
S, M = 4, 4
NAMES = {"Ibuprofen", "Menthol", "Nicotine", "VX", "nerve", "agent", "VX nerve agent", "HMX", "Cocaine",
         "Cinnamaldehyde", "Aspirin", "NicoAne"}   # "ti" is a ligature in the PDF text
P19 = 199   # 7.19
cores = {
    "s19a": (P19, 85, 91, 121, 123), "s19b": (P19, 144, 91, 191, 129), "s19c": (P19, 211, 89, 258, 139),
    "s19d": (P19, 268, 92, 312, 129), "s19e": (P19, 327, 92, 371, 129), "s19g": (P19, 440, 83, 538, 130),
    "s19h": (P19, 92, 144, 162, 194), "s19i": (P19, 184, 144, 253, 194), "s19j": (P19, 280, 142, 314, 202),
    "s19k": (P19, 344, 142, 379, 202), "s19l": (P19, 393, 144, 444, 190), "s19m": (P19, 458, 145, 531, 192),
    "s19n": (P19, 86, 214, 135, 266), "s19o": (P19, 154, 222, 197, 257), "s19p": (P19, 218, 220, 259, 266),
    "s19q": (P19, 277, 219, 338, 261), "s19r": (P19, 355, 214, 429, 262), "s19s": (P19, 450, 219, 526, 262),
    "s19t": (P19, 81, 283, 130, 339), "s19u": (P19, 149, 284, 190, 335), "s19v": (P19, 215, 281, 256, 334),
    "s19w": (P19, 290, 283, 351, 330), "s19x": (P19, 377, 288, 434, 324), "s19y": (P19, 455, 283, 521, 329),
    "s19z": (P19, 82, 343, 184, 397), "s19aa": (P19, 200, 359, 271, 381), "s19bb": (P19, 285, 340, 351, 395),
    "s19cc": (P19, 371, 342, 444, 402), "s19dd": (P19, 478, 349, 529, 386),
    "s19ee": (P19, 89, 415, 147, 452), "s19ff": (P19, 170, 415, 212, 450), "s19gg": (P19, 245, 428, 281, 447),
    "s19hh": (P19, 311, 425, 364, 450), "s19ii": (P19, 388, 418, 441, 462), "s19jj": (P19, 467, 418, 513, 455),
    "s19kk": (P19, 95, 459, 138, 497), "s19ll": (P19, 183, 458, 227, 512), "s19mm": (P19, 275, 455, 307, 514),
    "s19nn": (P19, 347, 457, 379, 506), "s19oo": (P19, 409, 470, 456, 501), "s19pp": (P19, 486, 470, 532, 501),
    "s19qq": (P19, 92, 507, 158, 545), "s19rr": (P19, 198, 515, 228, 545), "s19ss": (P19, 288, 520, 356, 550),
    "s19tt": (P19, 386, 509, 448, 550), "s19uu": (P19, 479, 509, 521, 550),
    # 7.2 (one stereocentre each), 7.3, 7.5 and 7.8: answered in the book
    "s2a": (179, 172, 515, 220, 552), "s2b": (179, 240, 510, 288, 564), "s2c": (179, 307, 502, 345, 573),
    "s2d": (179, 368, 500, 440, 576),
    "s3a": (181, 77, 85, 125, 138), "s3b": (181, 190, 85, 240, 155), "s3c": (181, 302, 85, 365, 158),
    "s3d": (181, 407, 85, 465, 138), "s3e": (181, 70, 167, 153, 220), "s3f": (181, 182, 167, 265, 220),
    "s3g": (181, 291, 172, 370, 227), "s3h": (181, 392, 170, 465, 223),
    "s5a": (187, 135, 287, 200, 408), "s5b": (187, 240, 312, 300, 393), "s5c": (187, 335, 312, 395, 393),
    "s5d": (187, 430, 312, 493, 393),
    "s8a": (191, 54, 85, 168, 151), "s8b": (191, 215, 85, 322, 151), "s8c": (191, 365, 100, 435, 140),
    "s8d": (191, 482, 100, 558, 140),
    # Isomer Match pairs: 7.7, 7.9, 7.14 d–j and Figs. 7.6–7.8 (1 = left, 2 = right)
    "i7a1": (190, 152, 94, 208, 170), "i7a2": (190, 227, 94, 285, 170), "i7b1": (190, 345, 94, 403, 170),
    "i7b2": (190, 420, 94, 478, 170), "i7c1": (190, 152, 187, 208, 263), "i7c2": (190, 227, 187, 285, 263),
    "i7d1": (190, 345, 182, 403, 258), "i7d2": (190, 420, 182, 478, 258),
    "i9a1": (192, 72, 123, 108, 157), "i9a2": (192, 120, 123, 163, 157), "i9b1": (192, 220, 120, 258, 157),
    "i9b2": (192, 272, 123, 323, 157), "i9c1": (192, 390, 111, 435, 168), "i9c2": (192, 445, 111, 490, 168),
    "i9d1": (192, 65, 179, 123, 209), "i9d2": (192, 132, 179, 190, 219), "i9e1": (192, 210, 171, 270, 209),
    "i9e2": (192, 282, 171, 343, 219), "i9f1": (192, 387, 179, 443, 211), "i9f2": (192, 462, 177, 515, 211),
    "i14d1": (198, 316, 121, 384, 150), "i14d2": (198, 398, 123, 466, 167),
    "i14e1": (198, 65, 171, 120, 223), "i14e2": (198, 132, 171, 200, 238),
    "i14f1": (198, 225, 177, 280, 228), "i14f2": (198, 295, 177, 345, 230),
    "i14g1": (198, 345, 185, 413, 233), "i14g2": (198, 440, 185, 495, 233),
    "i14h1": (198, 65, 237, 120, 283), "i14h2": (198, 130, 237, 183, 283),
    "i14i1": (198, 222, 237, 278, 283), "i14i2": (198, 290, 237, 345, 283),
    "i14j1": (198, 370, 240, 428, 283), "i14j2": (198, 460, 240, 525, 283),
    "if6a": (189, 110, 280, 180, 380), "if6b": (189, 210, 280, 285, 380), "if6c": (189, 322, 280, 400, 380),
    "if6d": (189, 430, 280, 503, 380),
    "if7a1": (189, 98, 553, 175, 612), "if7a2": (189, 203, 553, 277, 612),
    "if7b1": (189, 300, 558, 402, 612), "if7b2": (189, 418, 558, 512, 612),
    "if8a1": (190, 187, 500, 295, 560), "if8a2": (190, 322, 500, 435, 560),
    # Fischer R and S: 7.16 e and h
    "f16e": (198, 288, 446, 343, 506), "f16h": (198, 493, 458, 540, 501),
}
for k, v in json.loads(sys.argv[3]).items() if len(sys.argv) > 3 else []:
    cores[k] = tuple(v)
only = sys.argv[4].split(",") if len(sys.argv) > 4 else None


def segments(page, core):
    """Bond centre lines in the core box: thin filled bars and strokes give both ends, wedges their tip and base,
    and runs of hash marks one segment."""
    segs, hashes = [], []
    for dr in page.get_drawings():
        pts = [np.array([p.x, p.y]) for it in dr["items"] if it[0] == "l" for p in it[1:3]]
        if not pts: continue
        P = np.array(pts); c = P.mean(axis=0)
        if not core.contains(fitz.Point(*c)): continue
        if dr["type"] == "s":
            for it in dr["items"]:
                if it[0] == "l": segs.append((np.array(it[1]), np.array(it[2])))
            continue
        u, s, vt = np.linalg.svd(P - c); ax = vt[0]; proj = (P - c) @ ax; perp = (P - c) @ vt[1]
        L, W = proj.max() - proj.min(), perp.max() - perp.min()
        if L < 4: hashes.append(c); continue
        a, b = c + ax * proj.min(), c + ax * proj.max()
        if W > 1.6:   # wedge: the narrow end is the stereocentre end
            na = np.ptp(perp[proj < proj.min() + L * .2]) if (proj < proj.min() + L * .2).any() else 0
            nb = np.ptp(perp[proj > proj.max() - L * .2]) if (proj > proj.max() - L * .2).any() else 0
            segs.append((a, b) if na <= nb else (b, a))
        else:
            segs.append((a, b))
    # chain hash marks that sit close together into hashed bonds
    left = list(range(len(hashes)))
    while left:
        group = [left.pop(0)]; grew = True
        while grew:
            grew = False
            for j in list(left):
                if min(np.linalg.norm(hashes[j] - hashes[g]) for g in group) < 2.2:
                    group.append(j); left.remove(j); grew = True
        if len(group) >= 3:
            G = np.array([hashes[g] for g in group]); c = G.mean(axis=0)
            ax = np.linalg.svd(G - c)[2][0]; pr = (G - c) @ ax
            segs.append((c + ax * pr.min(), c + ax * pr.max()))
    return segs


def atoms(segs):
    pts = [p for s in segs for p in s]
    for (a, b) in segs:   # Fischer crossings: a near-horizontal bar through a near-vertical one
        for (c, d) in segs:
            r, s = b - a, d - c; den = r[0] * s[1] - r[1] * s[0]
            if abs(den) < 1e-6: continue
            t = ((c - a)[0] * s[1] - (c - a)[1] * s[0]) / den; u = ((c - a)[0] * r[1] - (c - a)[1] * r[0]) / den
            if .15 < t < .85 and .15 < u < .85: pts.append(a + t * r)
    out = []
    for p in pts:
        for q in out:
            if np.linalg.norm(q[0] / q[1] - p) < 2.0: q[0] += p; q[1] += 1; break
        else: out.append([p.copy(), 1])
    return [q[0] / q[1] for q in out]


table = {}
for name, (pno, x0, y0, x1, y1) in cores.items():
    if only and name not in only: continue
    page = doc[pno]; core = fitz.Rect(x0, y0, x1, y1)
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
                sentence = " " in t   # problem text runs into some drawings; atom labels have no spaces
                if (re.fullmatch(r"[a-z]{1,2}\)|\([RS]\)|vs\.", t) or t in NAMES or sentence) and fitz.Rect(s["bbox"]).intersects(clip):
                    r = fitz.Rect(s["bbox"])
                    (a0, b0), (a1, b1) = px(r.x0, r.y0), px(r.x1, r.y1)
                    g[max(0, b0):max(0, b1) + 2, max(0, a0):max(0, a1) + 2] = 255
    ink = g < 200
    for row in np.where(ink.mean(axis=1) > .9)[0]: g[row] = 255   # exercise box frame
    for col in np.where(ink.mean(axis=0) > .9)[0]: g[:, col] = 255
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
    ox, oy = xs.min() - P, ys.min() - P
    g = np.pad(g[ys.min():ys.max()+1, xs.min():xs.max()+1], P, constant_values=255)
    H, W = g.shape
    a = (255 - g).clip(0, 255).astype(np.uint8)
    Image.merge("LA", (Image.new("L", (W, H), 0), Image.fromarray(a))).save(f"{out}/{name}.png")
    pts = [((p[0] - clip.x0) * S - ox, (p[1] - clip.y0) * S - oy) for p in atoms(segments(page, core))]
    pts = [p for p in pts if 0 <= p[0] <= W and 0 <= p[1] <= H]
    table[name] = [[round(x / W, 4), round(y / H, 4)] for x, y in pts]
    ov = Image.fromarray(g.astype(np.uint8)).convert("RGB").resize((W * 2, H * 2)); d = ImageDraw.Draw(ov)
    for i, (x, y) in enumerate(pts):
        d.ellipse((2*x - 5, 2*y - 5, 2*x + 5, 2*y + 5), outline=(255, 0, 0), width=2)
        d.text((2*x + 6, 2*y - 14), str(i), fill=(0, 0, 255))
    ov.save(f"{out}/{name}-atoms.png")
old = json.load(open(f"{out}/atoms.json")) if only else {}
old.update(table)
json.dump(old, open(f"{out}/atoms.json", "w"), indent=0)
print("ok", len(table))
