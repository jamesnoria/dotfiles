#!/usr/bin/env python3
"""Render a final plain-text report specification locally as a PDF."""
import argparse
import html
import json
import os
from pathlib import Path
import re
import tempfile
import textwrap
from datetime import date

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle,
    Preformatted,
)
from reportlab.platypus.tableofcontents import TableOfContents

BASE = Path(__file__).resolve().parents[1]
MONTHS = ('enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre').split()
LABELS = {'tecnico': 'Técnica', 'funcional': 'Funcional'}
PINK = colors.HexColor('#e4b8b8')


def require_text(value, field):
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f'{field}: se requiere texto no vacío')


def validate(data):
    if not isinstance(data, dict) or data.get('kind') not in LABELS:
        raise ValueError('kind debe ser tecnico o funcional')
    meta = data.get('metadata')
    if not isinstance(meta, dict):
        raise ValueError('metadata debe ser un objeto')
    for field in ('jira', 'title', 'date', 'author', 'area', 'version'):
        require_text(meta.get(field), f'metadata.{field}')
    # This is document completion, not approval/deployment of the underlying change.
    meta['status'] = 'Finalizado'
    date.fromisoformat(meta['date'])
    sections = data.get('sections')
    if not isinstance(sections, list) or len(sections) != 8:
        raise ValueError('sections debe contener las ocho secciones 2–9')
    for section in sections:
        if not isinstance(section, dict):
            raise ValueError('Cada sección debe ser un objeto')
        require_text(section.get('title'), 'section.title')
        if not isinstance(section.get('blocks'), list) or not section['blocks']:
            raise ValueError('Cada sección necesita blocks no vacío')
        for block in section['blocks']:
            if not isinstance(block, dict):
                raise ValueError('Cada bloque debe ser un objeto')
            kind = block.get('type')
            if kind in ('paragraph', 'heading', 'code'):
                require_text(block.get('text'), 'block.text')
                if kind == 'code' and data['kind'] == 'funcional':
                    raise ValueError('El informe funcional no admite bloques de código')
            elif kind == 'list':
                if not isinstance(block.get('items'), list) or not block['items']:
                    raise ValueError('La lista necesita items')
                for item in block['items']:
                    require_text(item, 'list.item')
            elif kind == 'table':
                headers, rows = block.get('headers'), block.get('rows')
                if not isinstance(headers, list) or not 1 <= len(headers) <= 4:
                    raise ValueError('Las tablas necesitan entre 1 y 4 columnas')
                for header in headers:
                    require_text(header, 'table.header')
                if not isinstance(rows, list) or not rows:
                    raise ValueError('La tabla necesita filas')
                for row in rows:
                    if not isinstance(row, list) or len(row) != len(headers):
                        raise ValueError('Fila de tabla con número incorrecto de columnas')
                    for cell in row:
                        require_text(cell, 'table.cell')
            else:
                raise ValueError(f'Tipo de bloque desconocido: {kind}')


def safe_id(value):
    return re.sub(r'[^A-Za-z0-9_-]+', '-', value).strip('-')[:100] or 'SIN-JIRA'


def escaped(value):
    return html.escape(value).replace('\n', '<br/>')


class Report(SimpleDocTemplate):
    def afterFlowable(self, flowable):
        if isinstance(flowable, Paragraph) and flowable.style.name == 'Section':
            text = flowable.getPlainText()
            key = f'section-{text.split(".")[0]}'
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(text, key, 0)
            self.notify('TOCEntry', (0, text, self.page, key))


def build(data, output, logo):
    meta = data['metadata']
    label = LABELS[data['kind']]
    day = date.fromisoformat(meta['date'])
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle('BodyReport', fontName='Helvetica', fontSize=10,
                              leading=14, spaceAfter=8, splitLongWords=True))
    styles.add(ParagraphStyle('CellReport', parent=styles['BodyReport'], fontSize=9,
                              leading=12, spaceAfter=0))
    styles.add(ParagraphStyle('Section', parent=styles['Heading1'], fontName='Helvetica-Bold',
                              fontSize=15, leading=19, spaceBefore=16, spaceAfter=12))
    styles.add(ParagraphStyle('Subsection', parent=styles['Heading2'], fontSize=11,
                              leading=15, spaceBefore=10, spaceAfter=8))
    styles.add(ParagraphStyle('ReportTitle', parent=styles['Title'], fontSize=23,
                              leading=29, alignment=0, spaceAfter=20))
    styles.add(ParagraphStyle('HeaderReport', fontName='Helvetica-Bold', fontSize=8,
                              leading=10, alignment=TA_CENTER))
    styles.add(ParagraphStyle('CodeReport', fontName='Courier', fontSize=8,
                              leading=10, spaceAfter=10))
    width = A4[0] - 84

    def paragraph(text, style='BodyReport'):
        return Paragraph(escaped(text), styles[style])

    def table(headers, rows, widths=None):
        cells = [[paragraph(c, 'CellReport') for c in row] for row in [headers] + rows]
        result = Table(cells, colWidths=widths or [width / len(headers)] * len(headers),
                       repeatRows=1, hAlign='LEFT', splitInRow=1)
        result.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), PINK),
            ('GRID', (0, 0), (-1, -1), .5, colors.black),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ]))
        return result

    image = ImageReader(str(logo))

    def header(canvas, doc):
        canvas.saveState()
        # Fixed header frame; long metadata shrinks to fit without overlapping body.
        x, y, h = 26, A4[1] - 74, 48
        full = A4[0] - 52
        logo_w, area_w = 96, 142
        center_w = full - logo_w - area_w
        canvas.setStrokeColor(colors.black)
        canvas.setLineWidth(.6)
        canvas.rect(x, y, full, h)
        canvas.line(x + logo_w, y, x + logo_w, y + h)
        canvas.line(x + logo_w + center_w, y, x + logo_w + center_w, y + h)
        canvas.line(x + logo_w, y + h / 2, x + full, y + h / 2)
        canvas.drawImage(image, x + 10, y + 8, width=logo_w - 20, height=h - 16,
                         preserveAspectRatio=True, anchor='c', mask='auto')

        def fit(text, left, bottom, box_w, box_h):
            p = paragraph(text, 'HeaderReport')
            pw, ph = p.wrap(box_w - 10, 10000)
            scale = min(1, (box_h - 4) / ph)
            canvas.saveState()
            canvas.translate(left + box_w / 2, bottom + box_h / 2)
            canvas.scale(scale, scale)
            p.drawOn(canvas, -pw / 2, -ph / 2)
            canvas.restoreState()

        fit(f'Especificación {label}', x + logo_w, y + h / 2, center_w, h / 2)
        fit(meta['title'], x + logo_w, y, center_w, h / 2)
        fit(meta['area'], x + logo_w + center_w, y + h / 2, area_w, h / 2)
        fit(f'{MONTHS[day.month - 1].capitalize()}   {day:%d/%m/%Y}',
            x + logo_w + center_w, y, area_w, h / 2)
        canvas.setFont('Helvetica', 9)
        canvas.drawRightString(A4[0] - 30, 25, str(doc.page))
        canvas.restoreState()

    doc = Report(str(output), pagesize=A4, rightMargin=42, leftMargin=42,
                 topMargin=100, bottomMargin=46,
                 title=f'Especificación {label} – {meta["jira"]} – {meta["title"]}',
                 author=meta['author'])
    story = [paragraph(f'Especificación {label} – {meta["title"]}', 'ReportTitle'),
             paragraph(f'1. Ficha {label} e Historial de Revisiones', 'Section')]
    story.append(table(['Campo', 'Detalle'], [
        ['Nombre del Requerimiento', meta['title']],
        ['Código de Historia de Usuario (HU)', meta['jira']],
        ['Fecha de Elaboración', f'{day.day:02} de {MONTHS[day.month - 1]} de {day.year}'],
        ['Autor', meta['author']], ['Versión', meta['version']], ['Estado', meta['status']],
    ], [width * .43, width * .57]))
    story.extend([PageBreak(), paragraph('Contenido', 'ReportTitle')])
    toc = TableOfContents()
    toc.levelStyles = [ParagraphStyle('Index', fontName='Helvetica', fontSize=10,
                                      leading=15, spaceBefore=8, rightIndent=22)]
    story.extend([toc, PageBreak()])
    for number, section in enumerate(data['sections'], 2):
        story.append(paragraph(f'{number}. {section["title"]}', 'Section'))
        for block in section['blocks']:
            kind = block['type']
            if kind == 'paragraph':
                story.append(paragraph(block['text']))
            elif kind == 'heading':
                story.append(paragraph(block['text'], 'Subsection'))
            elif kind == 'list':
                for item in block['items']:
                    story.append(paragraph('• ' + item))
            elif kind == 'table':
                story.extend([table(block['headers'], block['rows']), Spacer(1, 10)])
            elif kind == 'code':
                # Explicit visual wraps preserve all characters, including long tokens.
                lines = []
                for line in block['text'].expandtabs(4).splitlines():
                    lines.extend(textwrap.wrap(line, 94, replace_whitespace=False,
                                               drop_whitespace=False) or [''])
                story.append(Preformatted('\n'.join(lines), styles['CodeReport']))
    doc.multiBuild(story, onFirstPage=header, onLaterPages=header)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--output-dir', type=Path, required=True)
    parser.add_argument('--overwrite', action='store_true')
    args = parser.parse_args()
    try:
        data = json.loads(args.input.read_text(encoding='utf-8'))
        validate(data)
        logo = BASE / 'assets' / 'rimac.png'
        if not logo.is_file():
            raise ValueError(f'Falta el logo RIMAC: {logo}')
        args.output_dir.mkdir(parents=True, exist_ok=True)
        target = args.output_dir / f'Especificación {LABELS[data["kind"]]} - {safe_id(data["metadata"]["jira"])}.pdf'
        if target.exists() and not args.overwrite:
            raise ValueError(f'El PDF ya existe: {target}. Solicita autorización antes de usar --overwrite.')
        # Render to a sibling first so layout failures never corrupt an existing report.
        fd, temporary = tempfile.mkstemp(suffix='.pdf', dir=args.output_dir)
        os.close(fd)
        try:
            build(data, temporary, logo)
            if args.overwrite:
                os.replace(temporary, target)
            else:
                os.link(temporary, target)  # Exclusive publish, including concurrent invocations.
        finally:
            Path(temporary).unlink(missing_ok=True)
        print(target)
    except (ValueError, OSError, KeyError, TypeError) as error:
        parser.exit(1, f'Error: {error}\n')


if __name__ == '__main__':
    main()
