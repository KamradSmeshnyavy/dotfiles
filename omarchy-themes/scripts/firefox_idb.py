"""
Чтение и запись IndexedDB расширений Firefox, пока Firefox закрыт.

База — sqlite в storage/default/moz-extension+++<uuid>[^userContextId=…]/idb/*.sqlite.
Значение строки — structured clone SpiderMonkey, сжатый snappy; ключ-строка —
0x30 + символы со сдвигом +1. Здесь поддержано то, что кладут расширения: объекты,
массивы, строки, числа, bool, null/undefined, обратные ссылки (только чтение).

snappy — через системную libsnappy (ctypes), отдельный Python-пакет не нужен.
"""
import ctypes
import re
import sqlite3
import struct
from pathlib import Path

_snappy = None

TAG_HEADER = 0xFFF10000
TAG_NULL, TAG_UNDEFINED, TAG_BOOLEAN, TAG_INT32, TAG_STRING = 0xFFFF0000, 0xFFFF0001, 0xFFFF0002, 0xFFFF0003, 0xFFFF0004
TAG_ARRAY, TAG_OBJECT, TAG_BACKREF, TAG_END = 0xFFFF0007, 0xFFFF0008, 0xFFFF000D, 0xFFFF0013
FLOAT_MAX = 0xFFF00000
HEADER_SCOPE = 3  # DifferentProcessForIndexedDB — как в записях самого Firefox


class Undefined:
    def __repr__(self):
        return "undefined"


UNDEFINED = Undefined()


def _lib():
    global _snappy
    if _snappy is None:
        _snappy = ctypes.CDLL("libsnappy.so.1")
    return _snappy


def unsnap(data):
    lib, n = _lib(), ctypes.c_size_t()
    if lib.snappy_uncompressed_length(data, len(data), ctypes.byref(n)) != 0:
        raise ValueError("snappy: bad length")
    out = ctypes.create_string_buffer(n.value)
    if lib.snappy_uncompress(data, len(data), out, ctypes.byref(n)) != 0:
        raise ValueError("snappy: bad data")
    return out.raw[:n.value]


def snap(data):
    lib = _lib()
    n = ctypes.c_size_t(lib.snappy_max_compressed_length(ctypes.c_size_t(len(data))))
    out = ctypes.create_string_buffer(n.value)
    if lib.snappy_compress(data, len(data), out, ctypes.byref(n)) != 0:
        raise ValueError("snappy: compress failed")
    return out.raw[:n.value]


# --- structured clone --------------------------------------------------------

class _Reader:
    def __init__(self, raw):
        self.raw, self.pos, self.objs = raw, 0, []

    def pair(self):
        lo, hi = struct.unpack_from("<II", self.raw, self.pos)
        self.pos += 8
        return lo, hi

    def string(self, lo):
        n, latin1 = lo & 0x7FFFFFFF, lo >> 31
        size = n if latin1 else 2 * n
        s = self.raw[self.pos:self.pos + size].decode("latin-1" if latin1 else "utf-16-le")
        self.pos += (size + 7) // 8 * 8
        return s

    def value(self):
        start = self.pos
        lo, hi = self.pair()
        if hi < FLOAT_MAX:
            return struct.unpack_from("<d", self.raw, start)[0]
        if hi == TAG_NULL:
            return None
        if hi == TAG_UNDEFINED:
            return UNDEFINED
        if hi == TAG_BOOLEAN:
            return bool(lo)
        if hi == TAG_INT32:
            return struct.unpack("<i", struct.pack("<I", lo))[0]
        if hi == TAG_STRING:
            return self.string(lo)
        if hi == TAG_BACKREF:
            return self.objs[lo]
        if hi in (TAG_OBJECT, TAG_ARRAY):
            out = {} if hi == TAG_OBJECT else [None] * lo
            self.objs.append(out)
            while True:
                klo, khi = self.pair()
                if khi == TAG_END:
                    break
                key = self.string(klo) if khi == TAG_STRING else struct.unpack("<i", struct.pack("<I", klo))[0]
                val = self.value()
                if hi == TAG_ARRAY:
                    out[int(key)] = val
                else:
                    out[str(key) if not isinstance(key, str) else key] = val
            return out
        raise ValueError(f"structured clone: tag {hi:#x} не поддержан")


def decode(raw):
    r = _Reader(raw)
    lo, hi = r.pair()
    if hi != TAG_HEADER:
        raise ValueError("structured clone: нет заголовка")
    return r.value()


class _Writer:
    def __init__(self):
        self.out = bytearray()

    def pair(self, lo, hi):
        self.out += struct.pack("<II", lo & 0xFFFFFFFF, hi)

    def string(self, s, tag=TAG_STRING):
        if all(ord(c) < 256 for c in s):
            data, lo = s.encode("latin-1"), len(s) | 0x80000000
        else:
            data = s.encode("utf-16-le")
            lo = len(data) // 2
        self.pair(lo, tag)
        self.out += data + b"\0" * ((-len(data)) % 8)

    def key(self, k):
        if isinstance(k, int) or (isinstance(k, str) and re.fullmatch(r"0|[1-9][0-9]{0,8}", k)
                                  and int(k) <= 0x7FFFFFFF):
            self.pair(int(k), TAG_INT32)
        else:
            self.string(k)

    def value(self, v):
        if v is None:
            self.pair(0, TAG_NULL)
        elif v is UNDEFINED:
            self.pair(0, TAG_UNDEFINED)
        elif isinstance(v, bool):
            self.pair(int(v), TAG_BOOLEAN)
        elif isinstance(v, int) and -2**31 <= v < 2**31:
            self.pair(v, TAG_INT32)
        elif isinstance(v, (int, float)):
            f = float(v)
            if f.is_integer() and -2**31 <= f < 2**31 and not (f == 0 and str(f).startswith("-")):
                self.pair(int(f), TAG_INT32)
            else:
                self.out += struct.pack("<d", f)
        elif isinstance(v, str):
            self.string(v)
        elif isinstance(v, list):
            self.pair(len(v), TAG_ARRAY)
            for i, item in enumerate(v):
                self.key(i)
                self.value(item)
            self.pair(0, TAG_END)
        elif isinstance(v, dict):
            self.pair(0, TAG_OBJECT)
            for k, item in v.items():
                self.key(k)
                self.value(item)
            self.pair(0, TAG_END)
        else:
            raise TypeError(f"structured clone: {type(v).__name__} не поддержан")


def encode(value):
    w = _Writer()
    w.pair(HEADER_SCOPE, TAG_HEADER)
    w.value(value)
    return bytes(w.out)


# --- база ---------------------------------------------------------------------

def string_key(text):
    """Ключ-строка IndexedDB: 0x30 + символы ASCII со сдвигом +1."""
    return b"0" + bytes(ord(c) + 1 for c in text)


def open_db(idb_dir, name):
    """sqlite базы IndexedDB с именем name в каталоге idb (или None)."""
    for path in sorted(Path(idb_dir).glob("*.sqlite")):
        con = sqlite3.connect(path, timeout=5)
        try:
            row = con.execute("SELECT name FROM database").fetchone()
        except sqlite3.Error:
            con.close()
            continue
        if row and row[0] == name:
            # Триггеры на file_ids зовут функцию Firefox update_refcount. Своя версия только
            # запоминает изменения, а flush_refcounts применяет их к таблице file: запрос
            # к той же базе изнутри функции sqlite3 выполнять не даёт.
            pending = []
            con.create_function("update_refcount", 2, lambda old, new: pending.append((old, new)))
            _pending[id(con)] = pending
            _files[id(con)] = path.with_suffix(".files")
            return con
        con.close()
    return None


def _ids(spec):
    return [int(x.lstrip(".")) for x in (spec or "").split() if x.lstrip(".").isdigit()]


_pending, _files = {}, {}


def files_dir(con):
    """Каталог больших значений этой базы: <имя базы>.files рядом с .sqlite."""
    return _files[id(con)]


def flush_refcounts(con):
    """Счётчики ссылок на файлы .files/<id> после изменений file_ids (в той же транзакции).
    Запись с нулём удаляет триггер Firefox; сам файл остаётся, его уберёт Firefox."""
    pending = _pending.get(id(con), [])
    for old, new in pending:
        for fid in _ids(old):
            con.execute("UPDATE file SET refcount = refcount - 1 WHERE id = ?", (fid,))
        for fid in _ids(new):
            con.execute("UPDATE file SET refcount = refcount + 1 WHERE id = ?", (fid,))
    pending.clear()


def unsnap_framed(data):
    """snappy в формате кадров (так Firefox пишет большие значения в файлы .files/<id>)."""
    out, pos = bytearray(), 0
    while pos + 4 <= len(data):
        kind, size = data[pos], int.from_bytes(data[pos + 1:pos + 4], "little")
        chunk = data[pos + 4:pos + 4 + size]
        pos += 4 + size
        if kind == 0x00:
            out += unsnap(chunk[4:])  # первые 4 байта — CRC32C
        elif kind == 0x01:
            out += chunk[4:]
    return bytes(out)


def read_value(data, file_ids, files_dir):
    """Значение строки object_data. Большие значения Firefox держит в файле <files_dir>/<id>,
    а в data тогда лежит число, а не байты."""
    if file_ids and not isinstance(data, bytes):
        fid = _ids(file_ids)[0]
        return decode(unsnap_framed((Path(files_dir) / str(fid)).read_bytes()))
    return decode(unsnap(data))
