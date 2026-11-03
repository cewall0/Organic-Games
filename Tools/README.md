# Reaction drawings from the book

Organic Games Plus cuts its reaction drawings from Chad's book (Wallace_Organic_Chem.pdf, vector figures).
Python with PyMuPDF (fitz), numpy, scipy and Pillow.

1. `book_split.py BOOK.pdf OUTDIR 276:e,f,g 298:c+14,d` — one crop per lettered reaction in a reaction summary
   (pdf page : letters; `+14` gives 14 pt more room below the label line). Red labels are removed (they give answers
   away), lines starting with "−" (what is given off, e.g. "− H₂O") are left out of the reagents, and each reaction
   is split at its arrow into sm / reagents / product PNGs. Check the `sheet-*.png` contact sheets.
2. `build_book_assets.py OUTDIR "Organic Games/Assets.xcassets/ReactionsChN" p276g:r9g ...` — installs them as
   `bk-<name>-sm/reagents/product` @2x images (the same text size as the Ch. 11 website drawings).

Then add the reactions to `Plus/Reactions.swift` with `book(...)`.
