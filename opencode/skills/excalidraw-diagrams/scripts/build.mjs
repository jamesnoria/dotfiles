#!/usr/bin/env node
// Uso: node build.mjs spec.json out.excalidraw
// Convierte una spec (graph | sequence) en un archivo Excalidraw con auto-layout.
import fs from "node:fs";
import dagre from "@dagrejs/dagre";

const [, , specPath, outPath] = process.argv;
if (!specPath || !outPath) {
  console.error("Uso: node build.mjs spec.json out.excalidraw");
  process.exit(1);
}
const spec = JSON.parse(fs.readFileSync(specPath, "utf8"));

const FONT = 16;
const LINE_H = 1.25;
const CHAR_W = 9.2;
const COLORS = {
  service: { bg: "#a5d8ff", stroke: "#1971c2" },
  data: { bg: "#b2f2bb", stroke: "#2f9e44" },
  external: { bg: "#ffec99", stroke: "#e67700" },
  accent: { bg: "#ffc9c9", stroke: "#e03131" },
  neutral: { bg: "#e9ecef", stroke: "#495057" },
  frontend: { bg: "#a5d8ff", stroke: "#1971c2" },
  backend: { bg: "#d0bfff", stroke: "#7048e8" },
  storage: { bg: "#ffec99", stroke: "#f08c00" },
  ai: { bg: "#e599f7", stroke: "#9c36b5" },
  queue: { bg: "#fff3bf", stroke: "#fab005" },
  cache: { bg: "#ffe8cc", stroke: "#fd7e14" },
  user: { bg: "#e7f5ff", stroke: "#1971c2" },
  hub: { bg: "#ffa8a8", stroke: "#c92a2a" },
  decision: { bg: "#ffd8a8", stroke: "#e8590c" },
  network: { bg: "#dee2e6", stroke: "#495057" },
  classification: { bg: "#99e9f2", stroke: "#0c8599" },
  monitoring: { bg: "#d3f9d8", stroke: "#40c057" },
  "aws-compute": { bg: "#ff9900", stroke: "#cc7a00" },
  "aws-storage": { bg: "#3f8624", stroke: "#2d6119" },
  "aws-database": { bg: "#3b48cc", stroke: "#2d3899" },
  "aws-network": { bg: "#8c4fff", stroke: "#6b3dcc" },
  "aws-security": { bg: "#dd344c", stroke: "#b12a3d" },
  "aws-ml": { bg: "#01a88d", stroke: "#017d69" },
  "azure-compute": { bg: "#0078d4", stroke: "#005a9e" },
  "azure-storage": { bg: "#50e6ff", stroke: "#3cb5cc" },
  "azure-network": { bg: "#773adc", stroke: "#5a2ca8" },
  "azure-security": { bg: "#ff8c00", stroke: "#cc7000" },
  "gcp-compute": { bg: "#4285f4", stroke: "#3367d6" },
  "gcp-storage": { bg: "#34a853", stroke: "#2d8e47" },
  "gcp-database": { bg: "#ea4335", stroke: "#c53929" },
  "gcp-network": { bg: "#fbbc04", stroke: "#d99e04" },
  "gcp-ml": { bg: "#9334e6", stroke: "#7627b8" },
  "k8s-workload": { bg: "#326ce5", stroke: "#2756b8" },
  "k8s-config": { bg: "#7f8c8d", stroke: "#626d6e" },
  "k8s-ingress": { bg: "#00d4aa", stroke: "#00a888" },
  "k8s-node": { bg: "#303030", stroke: "#1a1a1a" },
};

// texto claro sobre fondos oscuros (paletas de nube)
const textOn = (bg) => {
  const m = /^#([0-9a-f]{6})$/i.exec(bg);
  if (!m) return "#1e1e1e";
  const [r, g, b] = [0, 2, 4].map((i) => parseInt(m[1].slice(i, i + 2), 16));
  return 0.299 * r + 0.587 * g + 0.114 * b < 140 ? "#ffffff" : "#1e1e1e";
};

let seed = 1;
const nid = () => `el${seed++}`;
const base = (type, x, y, w, h, extra = {}) => ({
  id: nid(), type, x, y, width: w, height: h, angle: 0,
  strokeColor: "#1e1e1e", backgroundColor: "transparent", fillStyle: "solid",
  strokeWidth: 2, strokeStyle: "solid", roughness: 0, opacity: 100,
  groupIds: [], frameId: null, roundness: null, seed: seed * 7919,
  version: 1, versionNonce: seed * 104729, isDeleted: false,
  boundElements: [], updated: 1, link: null, locked: false, ...extra,
});

const measure = (text, size = FONT) => {
  const lines = String(text).split("\n");
  const w = Math.max(...lines.map((l) => l.length)) * CHAR_W * (size / FONT);
  return { w: Math.ceil(w), h: Math.ceil(lines.length * size * LINE_H) };
};

const textEl = (text, cx, cy, opts = {}) => {
  const size = opts.size ?? FONT;
  const { w, h } = measure(text, size);
  return base("text", cx - w / 2, cy - h / 2, w, h, {
    text, originalText: text, fontSize: size, fontFamily: 2,
    textAlign: opts.align ?? "center", verticalAlign: "middle",
    containerId: opts.containerId ?? null, lineHeight: LINE_H,
    autoResize: true, strokeColor: opts.color ?? "#1e1e1e",
  });
};

const lineEl = (x, y, dx, dy, extra = {}) =>
  base("line", x, y, Math.abs(dx), Math.abs(dy), {
    points: [[0, 0], [dx, dy]], lastCommittedPoint: null,
    startBinding: null, endBinding: null, startArrowhead: null, endArrowhead: null, ...extra,
  });

for (const n of [...(spec.nodes ?? []), ...(spec.participants ?? []), ...(spec.groups ?? [])])
  if (n.color && !COLORS[n.color]) console.warn(`AVISO: color desconocido "${n.color}" en "${n.id}" (se usa neutral). Disponibles: ${Object.keys(COLORS).join(", ")}`);
const ids = new Set((spec.nodes ?? []).map((n) => n.id));
for (const e of spec.edges ?? [])
  if (!ids.has(e.from) || !ids.has(e.to)) { console.error(`ERROR: arista ${e.from}->${e.to} referencia un nodo inexistente`); process.exit(1); }

const els = [];
const byId = new Map();

const fixed = (el, [x, y]) => ({
  fixedPoint: [Math.min(1, Math.max(0, (x - el.x) / el.width)), Math.min(1, Math.max(0, (y - el.y) / el.height))],
});

function makeArrow(pts, fromEl, toEl, label, dashed, labelPos, opts = {}) {
  const [x0, y0] = pts[0];
  const xs = pts.map((p) => p[0]), ys = pts.map((p) => p[1]);
  const a = base("arrow", x0, y0, Math.max(...xs) - Math.min(...xs), Math.max(...ys) - Math.min(...ys), {
    points: pts.map(([x, y]) => [x - x0, y - y0]),
    strokeStyle: dashed ? "dashed" : "solid",
    roundness: null,
    startBinding: fromEl ? { elementId: fromEl.id, focus: 0, gap: 1, ...fixed(fromEl, pts[0]) } : null,
    endBinding: toEl ? { elementId: toEl.id, focus: 0, gap: 1, ...fixed(toEl, pts.at(-1)) } : null,
    startArrowhead: opts.bidirectional ? "arrow" : null, endArrowhead: "arrow", lastCommittedPoint: null, elbowed: pts.length > 2,
  });
  els.push(a);
  for (const s of [fromEl, toEl]) if (s) s.boundElements.push({ id: a.id, type: "arrow" });
  if (label) {
    let lx, ly;
    if (labelPos) [lx, ly] = labelPos;
    else {
      const i = Math.floor((pts.length - 1) / 2);
      const mid = pts[i], nxt = pts[i + 1] ?? mid;
      lx = (mid[0] + nxt[0]) / 2; ly = (mid[1] + nxt[1]) / 2;
    }
    const t = textEl(label, lx, ly, { size: 14 });
    const bg = base("rectangle", t.x - 4, t.y - 2, t.width + 8, t.height + 4, {
      backgroundColor: "#ffffff", strokeColor: "transparent", strokeWidth: 0,
    });
    els.push(bg, t);
  }
  return a;
}

// ---------- GRAPH (flujo, arquitectura, ER) ----------
function buildGraph() {
  const g = new dagre.graphlib.Graph({ multigraph: true });
  const dirLR = (spec.direction ?? "TB") === "LR" || spec.direction === "RL";
  const maxEdgeLabel = Math.max(0, ...spec.edges.map((e) => (e.label ? measure(e.label, 14).w : 0)));
  g.setGraph({ rankdir: spec.direction ?? "TB", nodesep: 60, ranksep: dirLR ? Math.max(80, maxEdgeLabel + 90) : 80, marginx: 40, marginy: 40, edgesep: 30 });
  g.setDefaultEdgeLabel(() => ({}));

  const info = new Map();
  for (const n of spec.nodes) {
    const label = n.label ?? n.id;
    const fields = n.fields ?? [];
    const title = measure(label);
    const body = fields.length ? measure(fields.join("\n")) : { w: 0, h: 0 };
    let w = Math.max(title.w, body.w) + 40;
    let h = fields.length ? title.h + 24 + body.h + 24 : title.h + 32;
    const shape = n.shape === "decision" ? "rect" : (n.shape ?? "rect");
    if (shape === "diamond") { w *= 1.6; h *= 1.8; }
    if (shape === "ellipse") { w *= 1.3; h *= 1.4; }
    w = Math.max(Math.ceil(w / 20) * 20, 120);
    h = Math.max(Math.ceil(h / 20) * 20, 60);
    info.set(n.id, { n, w, h, title, body, shape });
    g.setNode(n.id, { width: w, height: h });
  }
  spec.edges.forEach((e, i) => {
    const w = e.label ? measure(e.label, 14).w + 16 : 0;
    g.setEdge(e.from, e.to, { label: e.label ?? "", width: w, height: e.label ? 22 : 0, labelpos: "c" }, `e${i}`);
  });
  dagre.layout(g);

  for (const [id, d] of info) {
    const p = g.node(id);
    const isDecision = d.n.shape === "decision";
    const c = COLORS[isDecision ? "decision" : (d.n.color ?? "neutral")] ?? COLORS.neutral;
    const type = d.shape === "rect" ? "rectangle" : d.shape;
    const x = p.x - d.w / 2, y = p.y - d.h / 2;
    const shape = base(type, x, y, d.w, d.h, {
      backgroundColor: c.bg, strokeColor: c.stroke,
      strokeStyle: isDecision ? "dashed" : "solid",
      strokeWidth: d.n.color === "hub" ? 3 : 2,
      roundness: type === "rectangle" ? { type: 3 } : type === "diamond" ? { type: 2 } : null,
    });
    els.push(shape);
    byId.set(id, shape);
    d.box = { x, y, w: d.w, h: d.h, cx: p.x, cy: p.y };
    if (d.n.fields?.length) {
      els.push(textEl(d.n.label ?? id, p.x, y + 12 + d.title.h / 2, { color: textOn(c.bg) === "#ffffff" ? "#ffffff" : c.stroke }));
      const ly = y + 12 + d.title.h + 6;
      els.push(lineEl(x, ly, d.w, 0, { strokeColor: c.stroke, strokeWidth: 1 }));
      els.push(textEl(d.n.fields.join("\n"), x + 20 + d.body.w / 2, ly + 12 + d.body.h / 2, { align: "left", color: textOn(c.bg) }));
    } else {
      const t = textEl(d.n.label ?? d.n.id, p.x, p.y, { containerId: shape.id, color: textOn(c.bg) });
      shape.boundElements.push({ id: t.id, type: "text" });
      els.push(t);
    }
  }
  // Enrutado ortogonal: puntos de salida/entrada escalonados por borde
  const TB = (spec.direction ?? "TB") === "TB" || spec.direction === "BT";
  const slots = new Map(); // "nodo|lado" -> [edgeIdx...]
  const sideOf = (a, b) => {
    if (TB) return b.cy >= a.cy ? "bottom" : "top";
    return b.cx >= a.cx ? "right" : "left";
  };
  const opposite = { bottom: "top", top: "bottom", right: "left", left: "right" };
  const plan = spec.edges.map((e, i) => {
    const a = info.get(e.from).box, b = info.get(e.to).box;
    const forward = TB ? Math.abs(b.cy - a.cy) > 1 : Math.abs(b.cx - a.cx) > 1;
    const sa = sideOf(a, b), sb = opposite[sa];
    const ka = `${e.from}|${sa}`, kb = `${e.to}|${sb}`;
    for (const k of [ka, kb]) { if (!slots.has(k)) slots.set(k, []); slots.get(k).push(i); }
    return { e, i, a, b, sa, sb, ka, kb, forward };
  });
  const anchor = (box, side, k, i) => {
    const list = slots.get(k);
    const n = list.length, idx = list.indexOf(i);
    const horizontal = side === "top" || side === "bottom";
    const span = (horizontal ? box.w : box.h) * 0.6;
    const off = n === 1 ? 0 : -span / 2 + (span * idx) / (n - 1);
    if (side === "bottom") return [box.cx + off, box.y + box.h];
    if (side === "top") return [box.cx + off, box.y];
    if (side === "right") return [box.x + box.w, box.cy + off];
    return [box.x, box.cy + off];
  };
  for (const { e, i, a, b, sa, sb, ka, kb, forward } of plan) {
    const ed = g.edge({ v: e.from, w: e.to, name: `e${i}` });
    let pts;
    if (!forward) {
      pts = ed.points.map((p) => [p.x, p.y]);
    } else {
      const s0 = anchor(a, sa, ka, i), t0 = anchor(b, sb, kb, i);
      if (TB) {
        const my = s0[1] + (t0[1] - s0[1]) * 0.3;
        pts = Math.abs(s0[0] - t0[0]) < 1 ? [s0, t0] : [s0, [s0[0], my], [t0[0], my], t0];
      } else {
        const mx = s0[0] + (t0[0] - s0[0]) * 0.3;
        pts = Math.abs(s0[1] - t0[1]) < 1 ? [s0, t0] : [s0, [mx, s0[1]], [mx, t0[1]], t0];
      }
    }
    // etiqueta en el tramo final (el más largo y paralelo al flujo)
    const k = pts.length - 2;
    const lp = [(pts[k][0] + pts[k + 1][0]) / 2, (pts[k][1] + pts[k + 1][1]) / 2];
    makeArrow(pts, byId.get(e.from), byId.get(e.to), e.label, e.style === "dashed", lp, { bidirectional: e.bidirectional });
  }

  // Grupos / zonas: rectángulo punteado alrededor de sus nodos
  for (const grp of spec.groups ?? []) {
    const boxes = grp.nodes.map((id) => info.get(id)?.box).filter(Boolean);
    if (!boxes.length) continue;
    const PAD = 30, HEAD = 28;
    const x0 = Math.min(...boxes.map((b) => b.x)) - PAD, y0 = Math.min(...boxes.map((b) => b.y)) - PAD - HEAD;
    const x1 = Math.max(...boxes.map((b) => b.x + b.w)) + PAD, y1 = Math.max(...boxes.map((b) => b.y + b.h)) + PAD;
    const c = COLORS[grp.color ?? "neutral"] ?? COLORS.neutral;
    const r = base("rectangle", x0, y0, x1 - x0, y1 - y0, {
      strokeStyle: "dashed", strokeColor: c.stroke, strokeWidth: 1, roundness: { type: 3 },
    });
    const t = textEl(grp.label ?? grp.id, 0, 0, { size: 14, align: "left", color: c.stroke });
    t.x = x0 + 12; t.y = y0 + 8;
    els.unshift(r, t); // al fondo para no tapar nodos
  }
}

// ---------- SEQUENCE ----------
function buildSequence() {
  const parts = spec.participants;
  const TOP = 40, ROW = 60, HEAD_H = 60;
  const widths = parts.map((p) => Math.max(measure(p.label ?? p.id).w + 40, 120));
  const maxLabel = Math.max(0, ...spec.messages.map((m) => measure(m.label ?? "", 14).w));
  const spacing = Math.max(Math.max(...widths) + 60, maxLabel + 40);
  const cx = parts.map((_, i) => 40 + widths[0] / 2 + i * spacing);
  const lifeH = (spec.messages.length + 1) * ROW;
  const heads = new Map();
  parts.forEach((p, i) => {
    const c = COLORS[p.color ?? "service"] ?? COLORS.service;
    const r = base("rectangle", cx[i] - widths[i] / 2, TOP, widths[i], HEAD_H, {
      backgroundColor: c.bg, strokeColor: c.stroke, roundness: { type: 3 },
    });
    const t = textEl(p.label ?? p.id, cx[i], TOP + HEAD_H / 2, { containerId: r.id, color: textOn(c.bg) });
    r.boundElements.push({ id: t.id, type: "text" });
    els.push(r, t);
    heads.set(p.id, { cx: cx[i] });
    els.push(lineEl(cx[i], TOP + HEAD_H, 0, lifeH, { strokeStyle: "dashed", strokeColor: "#868e96", strokeWidth: 1 }));
  });
  spec.messages.forEach((m, i) => {
    const y = TOP + HEAD_H + (i + 1) * ROW;
    const a = heads.get(m.from), b = heads.get(m.to);
    const dashed = m.style === "dashed";
    const label = m.label ?? "";
    if (m.from === m.to) {
      makeArrow([[a.cx, y - 12], [a.cx + 50, y - 12], [a.cx + 50, y + 12], [a.cx, y + 12]], null, null, null, dashed);
      els.push(textEl(label, a.cx + 60 + measure(label, 14).w / 2, y, { size: 14 }));
    } else {
      makeArrow([[a.cx, y], [b.cx, y]], null, null, null, dashed);
      els.push(textEl(label, (a.cx + b.cx) / 2, y - 14, { size: 14 }));
    }
  });
}

if (spec.type === "sequence") buildSequence();
else buildGraph();

if (spec.title) {
  const minX = Math.min(...els.map((e) => e.x));
  const minY = Math.min(...els.map((e) => e.y));
  const t = textEl(spec.title, 0, 0, { size: 24, align: "left" });
  t.x = minX;
  t.y = minY - t.height - 24;
  els.push(t);
}

fs.writeFileSync(outPath, JSON.stringify({
  type: "excalidraw", version: 2, source: "excalidraw-diagrams-skill",
  elements: els, appState: { viewBackgroundColor: "#ffffff", gridSize: null }, files: {},
}, null, 2));
console.log(`OK ${outPath}: ${els.length} elementos`);
