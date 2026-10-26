#!/usr/bin/env node
// Uso: node render.mjs diagrama.excalidraw [salida.png]
// Renderiza un .excalidraw a PNG (offline) y avisa de problemas básicos de layout.
import fs from "node:fs";
import { Resvg } from "@resvg/resvg-js";

const [, , inPath, outArg] = process.argv;
if (!inPath) {
  console.error("Uso: node render.mjs diagrama.excalidraw [salida.png]");
  process.exit(1);
}
const outPath = outArg ?? inPath.replace(/\.excalidraw$/, "") + ".png";
const raw = fs.readFileSync(inPath, "utf8");
const els = JSON.parse(raw).elements.filter((e) => !e.isDeleted);
const byId = new Map(els.map((e) => [e.id, e]));

const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const fill = (c) => (!c || c === "transparent" ? "none" : c);
const dash = (e) => (e.strokeStyle === "dashed" ? "8 6" : e.strokeStyle === "dotted" ? "2 6" : null);
const common = (e) =>
  `stroke="${fill(e.strokeColor)}" stroke-width="${e.strokeWidth ?? 2}" fill="${fill(e.backgroundColor)}"` +
  `${dash(e) ? ` stroke-dasharray="${dash(e)}"` : ""} opacity="${(e.opacity ?? 100) / 100}"`;

let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
const grow = (x, y) => { minX = Math.min(minX, x); minY = Math.min(minY, y); maxX = Math.max(maxX, x); maxY = Math.max(maxY, y); };
const body = [];

function arrowHead(x, y, px, py, color, w) {
  const ang = Math.atan2(y - py, x - px), len = 14, spread = 0.45;
  const p = (a) => `${x - len * Math.cos(a)},${y - len * Math.sin(a)}`;
  return `<polyline points="${p(ang - spread)} ${x},${y} ${p(ang + spread)}" fill="none" stroke="${color}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;
}

for (const e of els) {
  grow(e.x, e.y); grow(e.x + e.width, e.y + e.height);
  switch (e.type) {
    case "rectangle": {
      const r = e.roundness ? Math.min(12, e.width / 4, e.height / 4) : 0;
      body.push(`<rect x="${e.x}" y="${e.y}" width="${e.width}" height="${e.height}" rx="${r}" ${common(e)}/>`);
      break;
    }
    case "ellipse":
      body.push(`<ellipse cx="${e.x + e.width / 2}" cy="${e.y + e.height / 2}" rx="${e.width / 2}" ry="${e.height / 2}" ${common(e)}/>`);
      break;
    case "diamond": {
      const { x, y, width: w, height: h } = e;
      body.push(`<polygon points="${x + w / 2},${y} ${x + w},${y + h / 2} ${x + w / 2},${y + h} ${x},${y + h / 2}" stroke-linejoin="round" ${common(e)}/>`);
      break;
    }
    case "line":
    case "arrow": {
      const pts = e.points.map(([px, py]) => [e.x + px, e.y + py]);
      pts.forEach(([px, py]) => grow(px, py));
      body.push(`<polyline points="${pts.map((p) => p.join(",")).join(" ")}" fill="none" stroke="${fill(e.strokeColor)}" stroke-width="${e.strokeWidth ?? 2}" stroke-linejoin="round" stroke-linecap="round"${dash(e) ? ` stroke-dasharray="${dash(e)}"` : ""}/>`);
      if (e.type === "arrow" && e.startArrowhead && pts.length > 1) {
        const [x, y] = pts[0], [px, py] = pts[1];
        body.push(arrowHead(x, y, px, py, fill(e.strokeColor), e.strokeWidth ?? 2));
      }
      if (e.type === "arrow" && e.endArrowhead && pts.length > 1) {
        const [x, y] = pts.at(-1), [px, py] = pts.at(-2);
        body.push(arrowHead(x, y, px, py, fill(e.strokeColor), e.strokeWidth ?? 2));
      }
      break;
    }
    case "text": {
      const lines = e.text.split("\n");
      const lh = e.fontSize * (e.lineHeight ?? 1.25);
      const anchor = e.textAlign === "left" ? "start" : e.textAlign === "right" ? "end" : "middle";
      const tx = e.textAlign === "left" ? e.x : e.textAlign === "right" ? e.x + e.width : e.x + e.width / 2;
      lines.forEach((l, i) => {
        body.push(`<text x="${tx}" y="${e.y + i * lh + e.fontSize}" font-family="Ubuntu Sans, DejaVu Sans, sans-serif" font-size="${e.fontSize}" text-anchor="${anchor}" fill="${fill(e.strokeColor)}">${esc(l)}</text>`);
      });
      break;
    }
  }
}

const PAD = 40;
const W = Math.ceil(maxX - minX + PAD * 2), H = Math.ceil(maxY - minY + PAD * 2);
const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="${minX - PAD} ${minY - PAD} ${W} ${H}"><rect x="${minX - PAD}" y="${minY - PAD}" width="${W}" height="${H}" fill="#ffffff"/>${body.join("")}</svg>`;
fs.writeFileSync(outPath.replace(/\.png$/, ".svg"), svg);
const png = new Resvg(svg, { fitTo: { mode: "zoom", value: 1.5 }, font: { loadSystemFonts: true } }).render().asPng();
fs.writeFileSync(outPath, png);

// ---------- lint ----------
const warn = [];
const shapes = els.filter((e) => ["rectangle", "ellipse", "diamond"].includes(e.type) && e.strokeColor !== "transparent" && e.backgroundColor !== "transparent");
for (let i = 0; i < shapes.length; i++)
  for (let j = i + 1; j < shapes.length; j++) {
    const a = shapes[i], b = shapes[j];
    if (a.x < b.x + b.width && b.x < a.x + a.width && a.y < b.y + b.height && b.y < a.y + a.height)
      warn.push(`Solapamiento entre ${a.id} y ${b.id}`);
  }
for (const t of els.filter((e) => e.type === "text" && e.containerId)) {
  const c = byId.get(t.containerId);
  if (c && (t.width > c.width - 16 || t.height > c.height - 8))
    warn.push(`Texto "${t.text.slice(0, 30)}" no cabe en su caja ${c.id}`);
}
for (const a of els.filter((e) => e.type === "arrow")) {
  for (const k of ["startBinding", "endBinding"])
    if (a[k] && !byId.has(a[k].elementId)) warn.push(`Flecha ${a.id}: ${k} apunta a un elemento inexistente`);
}
const seen = new Set();
for (const e of els) { if (seen.has(e.id)) warn.push(`ID duplicado ${e.id}`); seen.add(e.id); }
for (const sh of els.filter((e) => e.boundElements?.length))
  for (const b of sh.boundElements) {
    const t = byId.get(b.id);
    if (!t) warn.push(`${sh.id} referencia ${b.id} inexistente`);
    else if (b.type === "text" && t.containerId !== sh.id) warn.push(`containerId de ${t.id} no coincide con ${sh.id}`);
  }
const nearEdge = (sh, x, y, tol = 15) => {
  const inX = x >= sh.x - tol && x <= sh.x + sh.width + tol, inY = y >= sh.y - tol && y <= sh.y + sh.height + tol;
  const onV = Math.abs(x - sh.x) <= tol || Math.abs(x - sh.x - sh.width) <= tol;
  const onH = Math.abs(y - sh.y) <= tol || Math.abs(y - sh.y - sh.height) <= tol;
  return (inY && onV) || (inX && onH);
};
for (const a of els.filter((e) => e.type === "arrow")) {
  for (const [k, pt] of [["startBinding", a.points[0]], ["endBinding", a.points.at(-1)]]) {
    if (!a[k]) continue;
    const sh = byId.get(a[k].elementId);
    if (sh && !nearEdge(sh, a.x + pt[0], a.y + pt[1])) warn.push(`Flecha ${a.id}: ${k} no toca el borde de ${sh.id}`);
  }
  if (a.points.length > 2 && (a.elbowed !== true || a.roundness !== null)) warn.push(`Flecha ${a.id}: multi-punto sin elbowed:true/roundness:null`);
}
console.log(`PNG: ${outPath} (${W}x${H}px), SVG: ${outPath.replace(/\.png$/, ".svg")}`);
console.log(warn.length ? "AVISOS:\n- " + warn.join("\n- ") : "Lint OK: sin solapamientos ni textos desbordados");
