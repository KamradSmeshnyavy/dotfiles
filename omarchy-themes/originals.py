"""Оригинальные обои райсов в темах: генераторы тем (rumda, surface, …) кладут их файлами в backgrounds/ первыми —
главные как 0-original.<ext>, остальные как 0r-<имя>.<ext> (идут после главного, но раньше своих 1-… / 2-…).

Источник — клон райса (по умолчанию ~/src/rice-refs/<имя>, переменная <ИМЯ>_SRC), иначе — raw.githubusercontent.com.
Большие картинки можно ужать по ширине (max_w) — тогда они пересохраняются JPEG-ом.
"""
import os
import shutil
import sys
import tempfile
import urllib.parse
import urllib.request


def fetch(repo, branch, rel, env=None, clone=None):
    """Путь к файлу rel райса repo ("owner/name"): из клона или скачанный во временную папку; None — если не вышло."""
    name = repo.split("/")[1]
    root = os.environ.get(env or name.upper().replace("-", "_") + "_SRC", clone or os.path.expanduser(f"~/src/rice-refs/{name}"))
    src = os.path.join(root, rel)
    if os.path.isfile(src):
        return src
    dst = os.path.join(tempfile.mkdtemp(prefix=name + "-"), os.path.basename(rel))
    try:
        url = f"https://raw.githubusercontent.com/{repo}/{branch}/" + urllib.parse.quote(rel)
        with urllib.request.urlopen(url, timeout=60) as r, open(dst, "wb") as f:
            f.write(r.read())
        return dst
    except Exception as e:  # noqa: BLE001
        print(f"  {repo}: {rel} не получен ({e})", file=sys.stderr)
        return None


def place(out_dir, repo, branch, items, **kw):
    """items: [(имя без расширения, путь в репозитории райса, max_w или None)]. Уже лежащие файлы не трогает."""
    os.makedirs(out_dir, exist_ok=True)
    for stem, rel, max_w in items:
        have = [f for f in os.listdir(out_dir) if os.path.splitext(f)[0] == stem]
        if have and not os.path.islink(os.path.join(out_dir, have[0])):
            continue
        for f in have:
            os.unlink(os.path.join(out_dir, f))
        src = fetch(repo, branch, rel, **kw)
        if not src:
            continue
        ext = os.path.splitext(rel)[1].lower()
        if max_w:
            from PIL import Image
            im = Image.open(src)
            if im.width > max_w:
                im = im.convert("RGB").resize((max_w, round(im.height * max_w / im.width)), Image.LANCZOS)
                im.save(os.path.join(out_dir, stem + ".jpg"), quality=90, optimize=True)
                continue
        shutil.copyfile(src, os.path.join(out_dir, stem + ext))
