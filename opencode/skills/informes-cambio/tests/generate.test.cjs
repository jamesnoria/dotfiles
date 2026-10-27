const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const base = path.resolve(__dirname, '..');
const python = process.env.REPORT_PYTHON || 'python3';
let dir;
beforeEach(() => { dir = fs.mkdtempSync(path.join(os.tmpdir(), 'informes-test-')); });
afterEach(() => { fs.rmSync(dir, { recursive: true, force: true }); });
function template(kind = 'tecnico') {
  return JSON.parse(fs.readFileSync(path.join(base, 'templates', `${kind}.json`), 'utf8'));
}
function run(data, extra = []) {
  const input = path.join(dir, 'input.json');
  fs.writeFileSync(input, JSON.stringify(data));
  return spawnSync(python, [path.join(base, 'scripts/generate.py'), input,
    '--output-dir', dir, ...extra], { encoding: 'utf8' });
}
function inspect(file) {
  const script = 'import pymupdf,json,sys; d=pymupdf.open(sys.argv[1]); print(json.dumps({"pages":[p.get_text() for p in d],"toc":d.get_toc(),"images":len(d[0].get_images())}))';
  const result = spawnSync(python, ['-c', script, file], { encoding: 'utf8' });
  expect(result.status).toBe(0);
  return JSON.parse(result.stdout);
}

test.each(['tecnico', 'funcional'])('genera %s con índice, encabezado, logo y nueve secciones', kind => {
  const data = template(kind);
  data.metadata.jira = 'TEST-123';
  const result = run(data);
  expect(result.stderr).toBe('');
  expect(result.status).toBe(0);
  const pdf = result.stdout.trim();
  expect(fs.readFileSync(pdf).subarray(0, 5).toString()).toBe('%PDF-');
  const report = inspect(pdf);
  expect(data.metadata.status).toBe('Finalizado');
  expect(report.pages[0]).toMatch(/Estado\s+Finalizado/);
  expect(report.pages[0]).not.toContain('Borrador');
  expect(report.pages.length).toBeGreaterThanOrEqual(3);
  expect(report.pages[1]).toContain('Contenido');
  expect(report.pages[1]).not.toContain('Placeholder');
  expect(report.toc).toHaveLength(9);
  expect(report.toc[0][2]).toBe(1);
  expect(report.toc[1][2]).toBe(3);
  expect(report.images).toBeGreaterThan(0);
  for (const page of report.pages) expect(page).toContain('RIMAC');
});

test.each([
  ['tecnico', 'Borrador para revisión'],
  ['funcional', 'Borrador para revisión'],
  ['tecnico', undefined],
  ['funcional', undefined],
])('normaliza estado antiguo u omitido en %s: %s', (kind, status) => {
  const data = template(kind);
  data.metadata.status = status;
  const result = run(data);
  expect(result.status).toBe(0);
  const report = inspect(result.stdout.trim());
  expect(report.pages[0]).toMatch(/Estado\s+Finalizado/);
  expect(report.pages[0]).not.toContain('Borrador para revisión');
});

test('no reemplaza archivos salvo autorización explícita', () => {
  const data = template();
  const first = run(data);
  expect(first.status).toBe(0);
  const original = fs.readFileSync(first.stdout.trim());
  const second = run(data);
  expect(second.status).toBe(1);
  expect(second.stderr).toContain('ya existe');
  expect(fs.readFileSync(first.stdout.trim())).toEqual(original);
  expect(run(data, ['--overwrite']).status).toBe(0);
});

test.each(['sections', 'date', 'row', 'code', 'kind'])('rechaza entrada inválida: %s', invalid => {
  const data = template();
  if (invalid === 'sections') data.sections.pop();
  if (invalid === 'date') data.metadata.date = '2026-99-99';
  if (invalid === 'row') data.sections[1].blocks[0].rows = [['incompleta']];
  if (invalid === 'code') { data.kind = 'funcional'; data.sections[0].blocks.push({ type: 'code', text: 'x' }); }
  if (invalid === 'kind') data.kind = '../../otro';
  expect(run(data).status).toBe(1);
  expect(fs.readdirSync(dir).filter(f => f.endsWith('.pdf'))).toEqual([]);
});

test('texto literal, listas, código y tablas extensas sin perder contenido', () => {
  const data = template();
  data.metadata.jira = '../../TEST / 99';
  data.sections[0].blocks = [
    { type: 'paragraph', text: 'Árbol & validación <segura> "literal"' },
    { type: 'list', items: ['Primero', 'Último'] },
    { type: 'code', text: '<tag> & sintético\n' + 'x'.repeat(400) },
    { type: 'table', headers: ['Dato', 'Detalle'], rows: Array.from({ length: 80 }, (_, i) => [`Fila ${i}`, 'Información verificada. '.repeat(10)]) },
    { type: 'paragraph', text: 'FIN DE CONTENIDO' },
  ];
  const result = run(data);
  expect(result.status).toBe(0);
  expect(path.dirname(result.stdout.trim())).toBe(dir);
  const report = inspect(result.stdout.trim());
  const text = report.pages.join('\n');
  expect(text).toContain('Árbol & validación <segura> "literal"');
  expect(text).toContain('Fila 79');
  expect(text).toContain('FIN DE CONTENIDO');
  expect(report.pages.length).toBeGreaterThan(5);
});
