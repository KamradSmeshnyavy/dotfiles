// Сборка usercss тем же кодом, что внутри Stylus: его worker.js (metaParse, compileUsercss)
// и его less.js, загруженные из XPI в песочницу node — как в веб-воркере расширения.
//
//   node stylus-compile.cjs <каталог с js/worker.js, js/less.js, js/parserlib.js>
//
// stdin: JSON-строки {"id": n, "code": "...", "vars": {...}|null}
// stdout: JSON-строки {"id": n, "meta": {...}, "sections": [...]} или {"id": n, "error": "..."}
"use strict";
const fs = require("fs");
const path = require("path");
const vm = require("vm");
const readline = require("readline");

const root = process.argv[2];
const ctx = {
  console, setTimeout, clearTimeout, performance, TextEncoder, TextDecoder, URL,
  location: { pathname: "/js/worker.js" },
  navigator: {},
  close() {},
};
ctx.self = ctx;
ctx.importScripts = (...files) => {
  for (const f of files) vm.runInContext(fs.readFileSync(path.join(root, "js", f), "utf8"), ctx, { filename: f });
};
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(path.join(root, "js", "worker.js"), "utf8"), ctx, { filename: "worker.js" });

// Команды воркера доступны только через его onmessage: отдаём ему MessagePort-заглушку.
function call(cmd, ...args) {
  return new Promise((resolve, reject) => {
    const port = {
      postMessage({ res, err }) { err ? reject(err[0]) : resolve(res); },
    };
    ctx.onmessage({ data: { id: 1, args: [cmd, ...args] }, ports: [port] });
  });
}

const RX_META = /\/\*\s*==userstyle==[\s\S]*?==\/userstyle==\s*\*\//i;

async function build({ id, code, vars }) {
  const metaStr = (code.match(RX_META) || [""])[0];
  const { metadata } = await call("metaParse", metaStr);
  // Значения переменных пользователя переносятся из старой версии, как reuseStyleVars Stylus.
  if (metadata.vars && vars) {
    for (const [k, v] of Object.entries(metadata.vars)) {
      const old = vars[k];
      if (old && old.value != null && old.type === v.type &&
          (!v.options || v.options.some(o => o.name === old.value))) v.value = old.value;
    }
  }
  // Stylus отдаёт воркеру копию (postMessage), а compileUsercss правит vars на месте.
  const meta = JSON.parse(JSON.stringify(metadata));
  const [sections] = await call("compileUsercss", code, metadata.preprocessor, metadata.vars, id);
  return { id, meta, sections };
}

const rl = readline.createInterface({ input: process.stdin });
const jobs = [];
rl.on("line", line => {
  if (!line.trim()) return;
  const job = JSON.parse(line);
  jobs.push(build(job).catch(e => ({ id: job.id, error: String(e && e.message || e) }))
    .then(r => fs.writeSync(1, JSON.stringify(r) + "\n")));  // синхронно: stdout-пайп не теряет хвост
});
rl.on("close", () => Promise.all(jobs).then(() => process.exit(0)));
