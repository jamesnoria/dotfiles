#!/usr/bin/env python3
"""Render every PDF page locally for visual verification (requires PyMuPDF)."""
import argparse
from pathlib import Path
import pymupdf

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('pdf', type=Path)
args = parser.parse_args()
with pymupdf.open(args.pdf) as doc:
    for number, page in enumerate(doc, 1):
        output = args.pdf.with_name(f'{args.pdf.stem}-pagina-{number:03}.png')
        if output.exists():
            parser.exit(1, f'La vista previa ya existe: {output}\n')
        page.get_pixmap(dpi=110).save(output)
        print(output)
