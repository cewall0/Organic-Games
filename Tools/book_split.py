"""Cut reactions out of the book's reaction summaries (vector PDF): one crop per lettered reaction,
red labels removed, then split at the arrow into starting material / reagents / product.

usage: book_split.py BOOK.pdf OUTDIR page:letters [page:letters ...]   e.g. 276:e,f,g 298:c,d
"""
import sys, os, re, json
import numpy as np
import fitz
from PIL import Image, ImageDraw
from scipy import ndimage

pdf, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
d = fitz.open(pdf)

def is_red(c):
    r, g, b = (c >> 16) & 255, (c >> 8) & 255, c & 255
    return r > 150 and g < 120 and b < 120

def strip_red(page):
    """Delete red text (labels like "1° alcohol" that give answers away); drawings stay."""
    hit = False
    for s in spans(page):
        if is_red(s["color"]) and s["text"].strip():
            page.add_redact_annot(fitz.Rect(s["bbox"]), fill=False); hit = True
    if hit:
        page.apply_redactions(images=fitz.PDF_REDACT_IMAGE_NONE, graphics=fitz.PDF_REDACT_LINE_ART_NONE)
SCALE = 4                       # 288 dpi
COLS = [(50, 318), (320, 562)]  # page columns, points

def spans(page):
    for b in page.get_text("dict")["blocks"]:
        for l in b.get("lines", []):
            for s in l["spans"]:
                yield s

def region(page, letter, extra=0):
    labels, heads = [], []
    for s in spans(page):
        t = s["text"].strip()
        if re.fullmatch(r"[a-z]{1,2}\)", t): labels.append((t[:-1], fitz.Rect(s["bbox"])))
        elif s["flags"] & 2 and s["color"] == 0x243f60: heads.append(fitz.Rect(s["bbox"]))
    lab = dict(labels)[letter]
    col = next(c for c in COLS if c[0] <= lab.x0 <= c[1])
    above = [r.y1 for _, r in labels if col[0] <= r.x0 <= col[1] and r.y1 < lab.y0]
    above += [r.y1 for r in heads if r.y1 < lab.y0]      # section headings span both columns
    top = max(above, default=60) + 2
    return fitz.Rect(lab.x1 + 1, top, col[1], lab.y1 + 1 + extra)

def lost_lines(page, rect):
    """Text lines like "- H₂O" or "- 2 HBr" under an arrow: what is given off, not a reagent (left out)."""
    for b in page.get_text("dict", clip=rect)["blocks"]:
        for l in b.get("lines", []):
            text = "".join(s["text"] for s in l["spans"]).strip()
            if text[:1] in "-−–":
                yield fitz.Rect(l["bbox"])

def render(page, rect):
    pm = page.get_pixmap(matrix=fitz.Matrix(SCALE, SCALE), clip=rect)
    a = np.frombuffer(pm.samples, np.uint8).reshape(pm.height, pm.width, pm.n)[..., :3].astype(int).copy()
    for r in lost_lines(page, rect):
        x0, y0 = int((r.x0 - rect.x0) * SCALE) - 2, int((r.y0 - rect.y0) * SCALE) + 2
        x1, y1 = int((r.x1 - rect.x0) * SCALE) + 3, int((r.y1 - rect.y0) * SCALE) - 1
        a[max(0, y0):max(0, y1), max(0, x0):max(0, x1)] = 255
    # Red labels ("1° alcohol") give answers away. Black ink is grey at its edges (r ≈ g ≈ b), red ink and its
    # anti-aliased edges are reddish (r well above g and b): whiten those, labels and halos both.
    red = (a[..., 0] - np.maximum(a[..., 1], a[..., 2])) > 25
    a[ndimage.binary_dilation(red, iterations=1)] = 255
    return a.mean(axis=2)          # grey, 0 = ink

def arrow(dark):
    """Longest horizontal run that ends in a filled arrowhead (long bonds have no head)."""
    best = (0, 0, 0, 0)
    h = dark.shape[0]
    for y in range(h):
        row = np.concatenate([[0], dark[y].astype(np.int8), [0]])
        dd = np.diff(row); st = np.where(dd == 1)[0]; en = np.where(dd == -1)[0]
        for a, b in zip(st, en):
            if b - a < 60 or b - a <= best[0]: continue
            head = dark[max(0, y - 14):y + 15, max(a, b - 24):b]
            if head.sum(axis=0).max() >= 10:          # a tall filled triangle near the end
                best = (b - a, y, a, b - 1)
    return best

def save(g, path):
    ink = 255 - g
    rows = np.where(ink.max(1) > 40)[0]; cols = np.where(ink.max(0) > 40)[0]
    if not len(rows): return None
    ink = ink[max(0, rows[0] - 6):rows[-1] + 7, max(0, cols[0] - 6):cols[-1] + 7]
    rgba = np.zeros(ink.shape + (4,), np.uint8); rgba[..., 3] = np.clip(ink * 1.1, 0, 255).astype(np.uint8)
    Image.fromarray(rgba).save(path)
    return Image.fromarray(rgba)

rows = []
for spec in sys.argv[3:]:
    pno, letters = spec.split(":")
    page = d[int(pno) - 1]
    for item in letters.split(","):
        letter, _, extra = item.partition("+")       # "c+14": 14 pt more below the label line
        g = render(page, region(page, letter, float(extra or 0)))
        dark = g < 150
        length, ay, ax0, ax1 = arrow(dark)
        body = dark.copy()
        body[max(0, ay - 3):ay + 4, ax0:ax1 + 1] = False
        body[max(0, ay - 14):ay + 15, max(ax0, ax1 - 30):ax1 + 6] = False      # arrowhead
        lab, n = ndimage.label(ndimage.binary_dilation(body, iterations=4))
        parts = {"sm": np.zeros_like(body), "reagents": np.zeros_like(body), "product": np.zeros_like(body)}
        for i, (ys, xs) in enumerate(ndimage.find_objects(lab), start=1):
            if (ys.stop - ys.start) * (xs.stop - xs.start) < 40: continue     # keep minus signs (− H₂O)
            cx = (xs.start + xs.stop) / 2
            k = "sm" if cx < ax0 else "product" if cx > ax1 - 10 else "reagents"
            parts[k][lab == i] = True
        key = f"p{pno}{letter}"
        imgs = {}
        for k, m in parts.items():
            keep = ndimage.binary_dilation(m, iterations=3)
            gg = np.where(keep, g, 255)
            imgs[k] = save(gg, f"{out}/{key}-{k}.png")
        full = save(g, f"{out}/{key}-full.png")
        rows.append((key, full, imgs))

# review sheet
W = 1800; sheet_rows = []
for key, full, imgs in rows:
    r = Image.new("RGB", (W, 200), "white"); dr = ImageDraw.Draw(r)
    def put(im, x, w):
        if im is None: dr.text((x + 10, 80), "MISSING", fill="red"); return
        s = min(180 / im.height, w / im.width, 1.0)
        im2 = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))))
        bg = Image.new("RGB", im2.size, (255, 240, 210)); bg.paste(im2, (0, 0), im2); r.paste(bg, (x, 10))
    put(full, 0, 700); x = 720
    for k in ("sm", "reagents", "product"): put(imgs[k], x, 340); x += 360
    dr.text((2, 2), key, fill="blue")
    sheet_rows.append(r)
for i in range(0, len(sheet_rows), 8):
    ch = sheet_rows[i:i + 8]; s = Image.new("RGB", (W, 200 * len(ch)), "white")
    for j, r in enumerate(ch): s.paste(r, (0, 200 * j))
    s.save(f"{out}/sheet-{i // 8 + 1}.png")
print(len(rows), "reactions")
