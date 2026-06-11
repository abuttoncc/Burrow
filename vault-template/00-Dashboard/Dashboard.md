---
cssclasses:
  - dashboard
---

```dataviewjs
/* ════ BURROW · Dashboard ════
   Single-block render, DOM mirrors the design prototype (masthead / north-star strip /
   three-column grid / footer). Styles live in .obsidian/snippets/dashboard.css (.bw namespace).
   Requires the Dataview community plugin. */
try {

/* ───── CONFIG — edit these for your vault ───── */
const CFG = {
  wikiDir: "wiki",
  typeOrder: ["institutions","instruments","indicators","mechanisms","companies","products","events","analyses","sources"],
  classificationLabels: ["price-based","quantity-based","structural"],
  ledgerPath: "08-Ops/approval-ledger",
  routinesDir: "08-Ops/routines",
  reviewDir: "08-Ops/review",
  runsDir: "08-Ops/runs",
  qaDir: "07-QA",
  inboxDir: "Inbox",
  dailyDir: "05-Daily",          // optional — the todo section degrades gracefully
  flywheelId: "flywheel",        // `routine:` value on full-revolution run records
  claudeCmd: "claude",           // CLI for the console buttons (resolved via PATH)
  nav: [["Wiki","wiki/_index"],["Ops","08-Ops/README"],["Q&A","07-QA/README"],["Inbox","Inbox/README"],["MOC","00-Dashboard/MOC"]],
};

/* ───── Data collection ───── */
const esc = s => String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;");
const cut = (s, n) => { s = String(s ?? ""); return s.length > n ? s.slice(0, n) + "…" : s; };
const fmtD = d => d && d.toFormat ? d.toFormat("MM-dd") : (d ? String(d) : "—");

// Ontology (all domains)
const nodes = dv.pages('"' + CFG.wikiDir + '"').where(p => p.type && p.type != "ontology" && p.type != "registry" && p.type != "hub" && !p.file.name.startsWith("_") && p.file.name != "README" && p.file.name != "log").array();
const edges = nodes.reduce((s, p) => s + ((p.relations || []).length), 0);
const domains = new Set(nodes.map(p => p.file.folder.split("/")[1]).filter(Boolean)).size;
const LABELS = new Set(CFG.classificationLabels);
const contested = nodes.filter(p => p.confidence == "contested" || p.confidence == "low").length;
const noSrc = nodes.filter(p => p.type != "source" && (!p.sources || p.sources.length == 0)).length;
const orphan = nodes.filter(p => p.type != "source" && p.type != "analysis" && p.file.inlinks.length == 0).length;
let broken = 0;
for (const p of nodes) for (const l of (p.file.outlinks || [])) {
  if (!l.path) continue;
  const nm = l.path.split("/").pop().replace(/\.md$/, "");
  if (LABELS.has(nm)) continue;
  if (!dv.page(l.path)) broken++;
}
const defects = contested + noSrc + orphan + broken;
const cnt = {}; for (const p of nodes) { const s = p.file.folder.split("/").pop(); cnt[s] = (cnt[s] || 0) + 1; }

// Inbox
const pendInbox = dv.pages('"' + CFG.inboxDir + '"').where(p => p.file.name !== "README" && p.compiled !== true).array();
let oldest = 0;
for (const p of pendInbox) {
  if (!p.created) continue;
  const c = (typeof p.created === "string") ? dv.date(p.created) : p.created;
  const d = Math.floor(dv.date("today").diff(c, "days").days);
  if (d > oldest) oldest = d;
}

// The Burrow layer
const cands = dv.pages('"' + CFG.reviewDir + '"').where(p => p.type == "candidate" && p.status == "pending").sort(p => p.created, "asc").array();
const gatesPage = dv.page(CFG.ledgerPath);
const gates = (gatesPage && gatesPage.gates) ? gatesPage.gates : [];
const gateCtx = id => { const g = gates.find(x => x.id == id); return g ? (g.state == "locked" ? "human forever" : g.state == "auto" ? "auto ✓" : g.streak + "/" + g.threshold) : ""; };
const routines = dv.pages('"' + CFG.routinesDir + '"').where(p => p.type == "routine").sort(p => p.sort, "asc").array();
const runs = dv.pages('"' + CFG.runsDir + '"').where(p => p.type == "run").sort(p => p.started, "desc").array();
const lastRun = runs.length ? runs[0] : null;
const STALE_MS = 2 * 3600 * 1000;
const stateOf = r => {
  if (r.status == "paused") return "paused";
  const lr = runs.find(x => x.routine == r.routine);
  if (lr && lr.status == "fail") return "anomaly";
  if (lr && lr.status == "running") {
    const ms = lr.started && lr.started.toMillis ? lr.started.toMillis() : null;
    if (!ms || Date.now() - ms > STALE_MS) return "anomaly";   // zombie run: no timestamp, or running > 2h
    return "working";
  }
  if (cands.some(c => c.routine == r.routine)) return "queue";
  return "idle";
};
const rStates = routines.map(stateOf);
const nAnomaly = rStates.filter(k => k == "anomaly").length;
let nRecent = 0;
try { const cutoff = dv.date("today").minus(dv.duration("1d")); nRecent = runs.filter(r => r.started && r.started >= cutoff).length; } catch (e) { nRecent = lastRun ? 1 : 0; }

// QA
const qas = dv.pages('"' + CFG.qaDir + '"').where(p => p.type == "qa").sort(p => p["last-run"], "desc").array().slice(0, 5);

// Flywheel steps of the latest run
let steps = [], runMeta = "";
if (lastRun) {
  const raw = await dv.io.load(lastRun.file.path);
  const m = raw.match(/## Flywheel\n([\s\S]*?)(\n## |$)/);
  if (m) {
    steps = m[1].trim().split("\n").filter(l => l.startsWith("- ")).map(l => {
      const mm = l.match(/^- (\S+)\s+([✓✗…xX])\s+(.*)$/);
      if (!mm) return { t: "", mark: "·", what: l.slice(2), small: "", n: "" };
      const seg = mm[3].split(" · ");
      return { t: mm[1], mark: mm[2], what: seg[0] || "", small: seg.length > 2 ? seg.slice(1, -1).join(" · ") : "", n: seg.length > 1 ? seg[seg.length - 1] : "" };
    });
  }
}

// Review card bodies (first lines of Change / Source sections)
const cardData = [];
for (const c of cands.slice(0, 4)) {
  let diff = "", src = "";
  try {
    const raw = await dv.io.load(c.file.path);
    const dm = raw.match(/## Change\n([\s\S]*?)(\n## |$)/);
    if (dm) diff = dm[1].trim().split("\n").filter(x => x.trim()).slice(0, 3).map(esc).join("<br>");
    const sm = raw.match(/## Source\n([\s\S]*?)(\n## |$)/);
    if (sm) src = esc(sm[1].trim().split("\n")[0]);
  } catch (e) {}
  cardData.push({ c, diff, src });
}

/* ───── The clock (SVG) ───── */
const STATES = [
  { key: "working", name: "working", angle: 0,   color: "#2F7D4E" },
  { key: "queue",   name: "queued",  angle: 72,  color: "#B5851B" },
  { key: "idle",    name: "idle",    angle: 144, color: "#7A8694" },
  { key: "paused",  name: "paused",  angle: 216, color: "#8E887A" },
  { key: "anomaly", name: "anomaly", angle: 288, color: "#C8371F" },
];
const C0 = 170;
const polar = (a, r) => [ +(C0 + r * Math.sin(a * Math.PI / 180)).toFixed(1), +(C0 - r * Math.cos(a * Math.PI / 180)).toFixed(1) ];
const secPath = (a0, a1, r) => { const [x0, y0] = polar(a0, r), [x1, y1] = polar(a1, r); return "M" + C0 + "," + C0 + " L" + x0 + "," + y0 + " A" + r + "," + r + " 0 0 1 " + x1 + "," + y1 + " Z"; };
let secs = "", labs = "";
for (const s of STATES) {
  secs += '<path d="' + secPath(s.angle - 36, s.angle + 36, 128) + '" fill="' + s.color + '" opacity="' + (s.key == "anomaly" ? ".13" : ".07") + '"/>';
  for (const a of [s.angle - 36, s.angle + 36]) {
    const [x0, y0] = polar(a, 120), [x1, y1] = polar(a, 128);
    secs += '<line x1="' + x0 + '" y1="' + y0 + '" x2="' + x1 + '" y2="' + y1 + '" stroke="#C9C1AD" stroke-width="1"/>';
  }
  const [lx, ly] = polar(s.angle, 146);
  labs += '<text x="' + lx + '" y="' + (ly + 4) + '" text-anchor="middle" class="sector-label">' + s.name + '</text>';
}
const LEN = [118, 96, 108, 88, 112, 100], JIT = [-14, 10, -6, 16, -18, 6];
let hands = "", legend = "";
routines.forEach((r, i) => {
  const st = STATES.find(s => s.key == rStates[i]);
  const len = LEN[i % 6], ang = st.angle + JIT[i % 6];
  hands += '<g class="hand" data-state="' + st.key + '" data-base="' + ang + '" data-href="' + r.file.path + '" style="transform-origin:170px 170px;transform:rotate(' + ang + 'deg);cursor:pointer">'
    + '<line x1="170" y1="178" x2="170" y2="' + (170 - len) + '" stroke="#1B1812" stroke-width="2"/>'
    + '<circle cx="170" cy="' + (170 - len) + '" r="8.5" fill="' + st.color + '" stroke="#F5F2EA" stroke-width="1.5"/>'
    + '<text class="tip" x="170" y="' + (170 - len + 3.4) + '" text-anchor="middle">' + (i + 1) + '</text></g>';
  legend += '<span data-href="' + r.file.path + '"><b>' + (i + 1) + '</b> ' + esc(r.name) + ' <span class="dot" style="background:' + st.color + '"></span></span>';
});
const clockSvg = '<svg class="clock-svg" viewBox="0 0 340 340">' + secs
  + '<circle cx="170" cy="170" r="128" fill="none" stroke="#1B1812" stroke-width="1.5"/>'
  + '<circle cx="170" cy="170" r="98" fill="none" stroke="#C9C1AD" stroke-width="1" stroke-dasharray="2 4"/>'
  + labs + hands
  + '<circle cx="170" cy="170" r="7" fill="#1B1812"/><circle cx="170" cy="170" r="2.5" fill="#F5F2EA"/></svg>';

/* ───── Section HTML ───── */
const now = new Date();
const pad = n => String(n).padStart(2, "0");
const dateLine = now.getFullYear() + "-" + pad(now.getMonth() + 1) + "-" + pad(now.getDate()) + " " + ["SUN","MON","TUE","WED","THU","FRI","SAT"][now.getDay()] + " · " + pad(now.getHours()) + ":" + pad(now.getMinutes());
const todayStr = dv.date("today").toFormat("yyyy-MM-dd");
const hourNow = now.getHours();
const period = hourNow < 6 ? "Small hours" : hourNow < 12 ? "Good morning" : hourNow < 18 ? "Good afternoon" : "Good evening";
const WD = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const greet = period + " · " + now.getFullYear() + "." + pad(now.getMonth() + 1) + "." + pad(now.getDate()) + " " + WD[now.getDay()];
const typesHtml = CFG.typeOrder.filter(k => cnt[k]).map(k => '<span class="ht" data-search="path:' + k + '/" title="Search all nodes under ' + k + '/">' + k + ' <b>' + cnt[k] + '</b></span>').join("");
const healthChip = defects > 0 ? '<span class="hchip warn">defects ' + defects + '</span>' : '<span class="hchip ok">healthy · no broken links / orphans / contested</span>';
const navItems = CFG.nav.slice();
if (CFG.dailyDir) navItems.push(["Daily", CFG.dailyDir + "/" + todayStr]);
const navHtml = '<div class="navlinks">' + navItems.map(([nm, h]) => '<a data-href="' + h + '">' + nm + '</a>').join('<span class="sep">·</span>') + '</div>';
const mast = '<header class="mast rv rv1">'
  + '<div class="brand"><div class="big">BURROW <em>VAULT</em></div>'
  + '<div class="subline"><span class="bbadge">THE BURROW</span><span class="greet">' + greet + '</span><span class="morning">Past day: <b data-href="' + (lastRun ? lastRun.file.path : "08-Ops/README") + '">' + nRecent + '</b> agent runs, <b data-href="08-Ops/review/README">' + cands.length + '</b> exceptions await your judgment, <b data-href="08-Ops/README">' + nAnomaly + '</b> agents anomalous</span></div></div>'
  + '<div class="mast-mid"><div class="mlbl">ONTOLOGY · ALL DOMAINS (' + domains + ')</div><div class="types">' + typesHtml + '</div></div>'
  + '<div class="head-right">' + navHtml + '<div class="hr-bot">' + healthChip + '<span class="date">' + dateLine + '</span></div></div></header>';
const ranToday = runs.some(r => r.routine == CFG.flywheelId && r.started && r.started.toFormat && r.started.toFormat("yyyy-MM-dd") == todayStr);
const dueQ = dv.pages('"' + CFG.qaDir + '"').where(q => q.type == "qa" && q.mode == "dynamic" && q.status == "due").array().length;
const navrow = '<div class="navrow rv rv2">'
  + '<div class="cap"><input class="capin" type="text" placeholder="Capture → Inbox: a confusion / idea / link — Enter to file"><button class="capgo">Go</button></div>'
  + '<div class="conrow navcon">' + [
    cands.length ? ['review', 'primary', 'Review queue ×' + cands.length, cands.length + ' candidate cards pending'] : ['review', 'done', 'Review queue ✓ clear', 'The queue is empty'],
    pendInbox.length ? ['digest', 'primary', 'Digest Inbox ×' + pendInbox.length, pendInbox.length + ' items to compile'] : ['digest', 'done', 'Digest Inbox ✓ empty', 'Inbox is drained'],
    ranToday ? ['routine', 'done', "Today's routine ✓ ran", 'The flywheel already turned today'] : (dueQ ? ['routine', 'primary', "Today's routine ×" + dueQ, dueQ + ' dynamic questions due'] : ['routine', '', "Today's routine", 'Nothing due — run manually if you like']),
    ['term', '', 'Terminal', 'Open an integrated terminal at the vault root'],
  ].map(([act, cls, txt, tip]) => '<button data-act="' + act + '" class="' + cls + '" title="' + tip + '">' + txt + '</button>').join('') + '</div></div>';

const ncell = (href, lbl, val, sub) => '<div class="ncell" data-href="' + href + '"><div class="lbl">' + lbl + '</div><div class="val">' + val + '</div><div class="sub">' + sub + '</div></div>';
const nstrip = '<div class="nstrip rv rv2">'
  + ncell("00-Dashboard/MOC", "Ontology nodes", String(nodes.length), "edges " + edges + " · domains " + domains)
  + ncell("wiki/_index", "Health defects", defects > 0 ? '<span style="color:var(--amber)">' + defects + '</span>' : "0", '<span class="dot ' + (defects > 0 ? "a" : "g") + '"></span>broken ' + broken + ' · orphans ' + orphan + ' · unsourced ' + noSrc + ' · contested ' + contested)
  + ncell("Inbox/README", "To digest", pendInbox.length + ' <small>items</small>', '<span class="dot ' + (oldest >= 3 || pendInbox.length >= 5 ? "r" : pendInbox.length ? "a" : "g") + '"></span>oldest ' + oldest + 'd (red at ≥3d)')
  + ncell("08-Ops/review/README", "To judge", cands.length > 0 ? '<span style="color:var(--red)">' + cands.length + '</span>' : "0", '<span class="dot ' + (cands.length ? "r pulse" : "g") + '"></span>exceptions first · verdicts feed the ledger')
  + ncell(lastRun ? lastRun.file.path : "08-Ops/README", "Last run", lastRun ? '<small>' + esc(lastRun["budget-spent"] || lastRun.status) + '</small>' : "—", lastRun ? esc(lastRun.routine) + " · " + esc(lastRun.status) + " · esc " + (lastRun.escalations ?? 0) : "no runs yet")
  + '</div>';

// 01 clock
const secClock = '<div class="sec rv rv3"><div class="sec-h" data-href="08-Ops/README"><h2><span class="no">01</span>Agent clock</h2><span class="meta">AGENT CLOCK · LIVE</span></div>'
  + '<div class="clockbox">' + clockSvg + '<div class="clock-legend">' + legend + '</div></div></div>';

// 02 agent list
const SLBL = { working: ["g", "working"], queue: ["a", "queued"], idle: ["s", "idle"], paused: ["p", "paused"], anomaly: ["r", "anomaly"] };
let applRows = "";
routines.forEach((r, i) => {
  const [cls, txt] = SLBL[rStates[i]];
  applRows += '<tr class="' + (rStates[i] == "anomaly" ? "anomaly" : "") + '" data-href="' + r.file.path + '">'
    + '<td class="a-name">' + esc(r.name) + '<small>' + esc(r.routine) + '</small></td>'
    + '<td class="a-state"><span class="dot ' + cls + '"></span>' + txt + '</td>'
    + '<td class="a-out">' + esc(cut(r["last-result"] || "—", 26)) + (r["last-run"] ? ' <small>' + fmtD(r["last-run"]) + '</small>' : "")
    + '<br><span class="ctr">' + esc(cut(r.trigger || "", 34)) + ' · ' + esc(cut(r.budget || "", 20)) + '</span></td>'
    + '<td class="a-tgl"><span class="tgl" data-toggle="' + r.file.path + '" data-cur="' + (r.status || "active") + '">' + (r.status == "paused" ? "resume" : "pause") + '</span></td></tr>';
});
const secAppl = '<div class="sec rv rv4"><div class="sec-h" data-href="08-Ops/README"><h2><span class="no">02</span>Agents</h2><span class="meta">' + routines.length + ' ROUTINES · CONTRACT-BOUND</span></div>'
  + '<table class="appl"><tbody>' + applRows + '</tbody></table></div>';

// console + today's todos (degrades when no daily note)
const daily = CFG.dailyDir ? (dv.page(CFG.dailyDir + "/" + todayStr) || dv.page(todayStr)) : null;
const openTasks = daily ? (daily.file.tasks || []).filter(t => !t.completed).slice(0, 5) : [];
const taskHtml = daily
  ? (openTasks.length ? openTasks.map(t => '<div class="tk" data-tline="' + t.line + '" data-tpath="' + t.path + '" title="Click to check off">' + esc(cut(t.text, 40)) + '</div>').join("") : '<div class="tk" style="color:var(--green)">All clear today</div>')
  : '<div class="tk">No daily note today' + (CFG.dailyDir ? "" : " (dailyDir off)") + '</div>';
const secTodo = '<div class="sec rv rv5"><div class="sec-h"' + (CFG.dailyDir ? ' data-href="' + CFG.dailyDir + '/' + todayStr + '"' : '') + '><h2><span class="no">07</span>Today</h2><span class="meta">' + todayStr + ' · DAILY</span></div>'
  + '<div class="conbox"><div class="contasks">' + taskHtml + '</div></div></div>';

// 03 flywheel
let flyHtml = "";
if (!lastRun) flyHtml = '<div class="qempty">No run records yet — appears after the first unattended run</div>';
else {
  flyHtml = '<div class="fly">' + steps.map(s => {
    const fail = s.mark == "✗";
    const col = fail ? "var(--red)" : s.mark == "✓" ? "var(--green)" : "var(--amber)";
    return '<div class="step' + (fail ? " fail" : "") + '" data-href="' + lastRun.file.path + '"><span class="t">' + esc(s.t) + '</span><span class="mark" style="color:' + col + '">' + s.mark + '</span>'
      + '<span class="what">' + esc(s.what) + (s.small ? '<small>' + esc(s.small) + '</small>' : "") + '</span><span class="n">' + esc(s.n) + '</span></div>';
  }).join("") + '</div>'
  + '<div class="runmeta"><a data-href="' + lastRun.file.path + '">RUN ' + esc(lastRun["run-id"] || lastRun.file.name) + '</a> · ' + esc(lastRun.outputs || "") + ' · budget ' + esc(lastRun["budget-spent"] || "—")
  + (runs.length > 1 ? '<br>earlier: ' + runs.slice(1, 4).map(x => '<a data-href="' + x.file.path + '">' + esc(x.routine) + " " + fmtD(x.started) + " " + esc(x.status) + '</a>').join(" · ") : "") + '</div>';
}
const secFly = '<div class="sec rv rv4"><div class="sec-h"' + (lastRun ? ' data-href="' + lastRun.file.path + '"' : '') + '><h2><span class="no">03</span>Run trace</h2><span class="meta">' + (lastRun ? "RUN " + esc(lastRun["run-id"] || "") + " · " + esc(lastRun.routine).toUpperCase() : "NO RUNS") + '</span></div>' + flyHtml + '</div>';

// 04 QA timeline
let qaHtml = "";
if (!qas.length) qaHtml = '<div class="qempty">No standing questions yet — see 07-QA/README</div>';
else qaHtml = '<div class="qa">' + qas.map(q => {
  const fresh = q.status == "fresh";
  const scope = Array.isArray(q["recall-scope"]) ? q["recall-scope"].join("/") : (q["recall-scope"] || "");
  return '<div class="qa-item" data-href="' + q.file.path + '"><span class="d">' + fmtD(q["last-run"]) + '</span><span class="rail"></span>'
    + '<div><h4>' + (q["last-summary"] ? esc(cut(q["last-summary"], 56)) : '<span style="color:var(--ink-3)">(awaiting first answer)</span>') + '</h4>'
    + '<div class="verdict ' + (fresh ? "v-hit" : "v-wait") + '">' + (fresh ? "✓ answered · fresh" : "○ due") + '</div>'
    + '<div class="q">Q: ' + esc(q.file.name) + ' (' + esc(q.cadence || "") + ' · ' + esc(scope) + ')</div></div></div>';
}).join("") + '</div>';
const secQa = '<div class="sec rv rv5"><div class="sec-h" data-href="07-QA/README"><h2><span class="no">04</span>QA timeline</h2><span class="meta">APPEND-ONLY · INV-7</span></div>' + qaHtml + '</div>';

// 05 review queue
const CHIP = { "new-node": ["new", "NEW NODE"], retirement: ["retire", "RETIREMENT"], disputed: ["disp", "DISPUTED"], "cross-domain-edge": ["edge", "X-DOMAIN EDGE"], edge: ["edge", "EDGE"], "t0-merge": ["edge", "T0 MERGE"], "axiom-change": ["retire", "AXIOM"] };
let queueHtml = "";
if (!cardData.length) queueHtml = '<div class="qempty"><div class="big">All quiet at the Burrow.</div>Queue clear · candidates arrive from unattended agents</div>';
else {
  queueHtml = '<div class="queue">' + cardData.map(({ c, diff, src }) => {
    const [cls, nm] = CHIP[c.gate] || ["disp", c.gate];
    return '<div class="qcard" data-href="' + c.file.path + '"><div class="card-top"><span class="chip ' + cls + '">' + nm + '</span>'
      + '<span class="gatehint">ledger · ' + gateCtx(c.gate) + '</span></div>'
      + '<h3>' + esc(c.target || c.file.name) + ' <span style="font-weight:400;color:var(--ink-3)">(' + esc(c.domain || "—") + ' · ' + esc(c.routine || "—") + ')</span></h3>'
      + (diff ? '<div class="diff">' + diff + '</div>' : "")
      + (src ? '<div class="src">Source: ' + src + '</div>' : "") + '</div>';
  }).join("") + '</div>'
  + '<div class="qhint">Say "<b>process the review queue</b>" in the terminal (or use the console button) → approve / reject / contested; every verdict feeds the ledger.</div>';
}
const secQueue = '<div class="sec rv rv5"><div class="sec-h" data-href="08-Ops/review/README"><h2><span class="no">05</span>Review queue</h2><span class="meta">' + cands.length + ' PENDING · VERDICTS = TRAINING</span></div>' + queueHtml + '</div>';

// 06 approval ledger
let gateHtml = "";
for (const x of gates) {
  let cls = "", tag = '<span class="gs">' + x.streak + "/" + x.threshold + '</span>', w = x.threshold ? Math.min(100, Math.round(x.streak / x.threshold * 100)) : 0;
  if (x.state == "locked") { cls = "locked"; tag = '<span class="gs lock">human forever</span>'; w = 100; }
  else if (x.state == "auto") { cls = "full"; tag = '<span class="gs auto">auto ✓</span>'; w = 100; }
  gateHtml += '<div class="gate"><div class="gate-top"><span class="gn">' + esc(x.name) + '</span>' + tag + '</div>'
    + '<div class="gbar ' + cls + '"><i style="width:' + w + '%"></i></div>'
    + '<div class="note">' + esc(x.note || "") + '</div></div>';
}
const secGates = '<div class="sec rv rv6"><div class="sec-h" data-href="' + CFG.ledgerPath + '"><h2><span class="no">06</span>Approval ledger</h2><span class="meta">AUTONOMY IS EARNED · STREAKS UP / REJECTIONS RESET</span></div>'
  + '<div class="gates" data-href="' + CFG.ledgerPath + '">' + gateHtml + '</div></div>';

// footer
const foot = '<footer class="foot rv rv6"><div class="inv"><span>INV-1 ONE GATE</span><span>INV-4 RETIRE NEVER DELETE</span><span>INV-7 QA APPEND-ONLY</span><span>INV-8 RIGOR AT THE GATE</span></div>'
  + '<span>BURROW · 08-OPS · RUNS ×' + runs.length + ' · <a data-href="08-Ops/README">Ops</a> · <a data-href="00-Dashboard/MOC">MOC</a></span></footer>';

/* ───── Assemble ───── */
const root = dv.el("div", "");
root.className = "bw";
root.innerHTML = mast + nstrip + navrow
  + '<div class="bw-grid">'
  + '<div class="col col1">' + secClock + secAppl + '</div>'
  + '<div class="col col2">' + secFly + secQa + '</div>'
  + '<div class="col col3">' + secQueue + secGates + secTodo + '</div>'
  + '</div>' + foot;

/* ───── Interactions ───── */
// Drill-down: any [data-href] element opens the note
root.addEventListener("click", e => {
  if (e.target.closest("button")) return;
  const sr = e.target.closest("[data-search]");
  if (sr) { try { app.internalPlugins.getPluginById("global-search").instance.openGlobalSearch(sr.dataset.search); } catch (err) { new Notice("Global search unavailable"); } return; }
  const el = e.target.closest("[data-href]");
  if (el) { e.preventDefault(); app.workspace.openLinkText(el.dataset.href, "", false); }
});
// Agent pause/resume: flip the contract's frontmatter status (clock + list settle on Dataview refresh)
root.querySelectorAll(".tgl").forEach(el => el.addEventListener("click", async e => {
  e.stopPropagation();
  const f = app.vault.getAbstractFileByPath(el.dataset.toggle);
  if (!f) { new Notice("Contract file not found"); return; }
  const next = el.dataset.cur == "paused" ? "active" : "paused";
  await app.fileManager.processFrontMatter(f, fm => { fm.status = next; });
  new Notice(f.basename + (next == "paused" ? " paused · skipped at next tick" : " resumed"));
}));
// Today's todos: click to check off (writes back to the daily note by line number)
root.querySelectorAll(".tk[data-tline]").forEach(el => el.addEventListener("click", async e => {
  e.stopPropagation();
  const f = app.vault.getAbstractFileByPath(el.dataset.tpath);
  if (!f) return;
  await app.vault.process(f, txt => {
    const ls = txt.split("\n"); const i = +el.dataset.tline;
    if (ls[i] !== undefined) ls[i] = ls[i].replace("- [ ]", "- [x]");
    return ls.join("\n");
  });
  el.style.textDecoration = "line-through"; el.style.opacity = ".5";
}));
// Console buttons: integrated-terminal commands when available; external terminal fallback is macOS-only
const CMDS = {
  review:  { cmd: "process the review queue", id: "terminal:open-terminal.claudeReview.root" },
  digest:  { cmd: "/burrow-ingest",  id: "terminal:open-terminal.claudeDigest.root" },
  routine: { cmd: "/burrow-routine", id: "terminal:open-terminal.claudeRoutine.root" },
  term:    { cmd: "",                id: "terminal:open-terminal.integrated.root" },
};
root.querySelectorAll("button[data-act]").forEach(b => b.addEventListener("click", () => {
  const a = CMDS[b.dataset.act];
  if (b.dataset.act != "term" && !b.dataset.fired) { b.dataset.fired = "1"; b.classList.add("fired"); b.append(" · fired"); }
  const reg = app.commands && app.commands.commands;
  if (a.id && reg && reg[a.id]) { app.commands.executeCommandById(a.id); new Notice("Integrated terminal · " + (a.cmd || "shell")); return; }
  try {
    const { spawn } = require("child_process");
    const ad = app.vault.adapter, vault = ad.getBasePath ? ad.getBasePath() : ad.basePath;
    const sh = a.cmd ? "cd '" + vault + "' && " + CFG.claudeCmd + " '" + a.cmd + "'" : "cd '" + vault + "' && " + CFG.claudeCmd;
    if (process.platform === "darwin") {
      spawn("osascript", ["-e", 'tell application "Terminal" to do script "' + sh.replace(/"/g, '\\"') + '"', "-e", 'tell application "Terminal" to activate']);
      new Notice("External terminal · " + (a.cmd || "shell"));
    } else { new Notice("Run in your terminal: " + sh); }
  } catch (err) { new Notice("Launch failed: " + (err && err.message || err)); }
}));
// Capture bar: files an Inbox note (compiled:false marks it for digestion)
const capIn = root.querySelector(".capin"), capGo = root.querySelector(".capgo");
const doCapture = async () => {
  const txt = (capIn.value || "").trim();
  if (!txt) { new Notice("Type something first"); return; }
  const clean = txt.replace(/[\\/:*?"<>|#^\[\]]/g, " ").replace(/\s+/g, " ").trim();
  const title = clean.length > 24 ? clean.slice(0, 24) : clean;
  let path = CFG.inboxDir + "/" + todayStr + "-" + title + ".md";
  if (app.vault.getAbstractFileByPath(path)) path = CFG.inboxDir + "/" + todayStr + "-" + title + "-" + pad(now.getHours()) + pad(now.getMinutes()) + ".md";
  const body = ["---", "tags: [research]", "type: research-note", "status: open",
    'topic: "' + title + '"', 'created: "' + todayStr + '"', 'updated: "' + todayStr + '"',
    "compiled: false", "---", "",
    "# " + title, "", "## Confusion", "", "- " + txt, "",
    "## Goal", "", "- ", "", "## Threads", "", "- ", ""].join("\n");
  try {
    await app.vault.create(path, body);
    capIn.value = "";
    new Notice("Captured → " + path);
    app.workspace.openLinkText(path, "", false);
  } catch (err) { new Notice("Capture failed: " + (err && err.message || err)); }
};
capGo.addEventListener("click", doCapture);
capIn.addEventListener("keydown", e => { if (e.key === "Enter") doCapture(); });

// Working hands wobble gently (2.6s period)
if (window._bwClockTick) clearInterval(window._bwClockTick);
window._bwClockTick = setInterval(() => {
  if (!root.isConnected) { clearInterval(window._bwClockTick); return; }
  root.querySelectorAll('.hand[data-state="working"]').forEach(g => {
    const w = Math.random() * 8 - 4;
    g.style.transform = "rotate(" + (parseFloat(g.dataset.base) + w) + "deg)";
  });
}, 2600);

} catch (e) { dv.paragraph("[!] Dashboard render failed: " + (e && e.message || e) + "<br><small>" + (e && e.stack ? String(e.stack).split("\n").slice(0,3).join("<br>") : "") + "</small>"); }
```
