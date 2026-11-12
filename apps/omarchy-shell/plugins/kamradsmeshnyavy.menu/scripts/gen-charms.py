#!/usr/bin/python3 -I
"""Данные режима «:» лаунчера (эмодзи, каомодзи, символы) → charms.json рядом с Menu.qml.

  /usr/bin/python3 -I scripts/gen-charms.py

Эмодзи и символы — из базы Unicode, которая есть в Python (unicodedata, Unicode License v3): одиночные
кодовые точки с именами, без последовательностей ZWJ, флагов и оттенков кожи. Каомодзи — свой список.
Запускать после обновления Python (новая версия Unicode — новые эмодзи); результат коммитится."""
import json
import os
import unicodedata

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HERE, "charms.json")

# Блоки, где живут эмодзи (одиночные кодовые точки).
EMOJI_RANGES = [
    (0x1F300, 0x1F5FF),  # символы и пиктограммы
    (0x1F600, 0x1F64F),  # смайлы
    (0x1F680, 0x1F6FF),  # транспорт и карты
    (0x1F900, 0x1F9FF),  # дополнительные символы и пиктограммы
    (0x1FA70, 0x1FAFF),  # расширенные A
    (0x2600, 0x26FF),    # разные символы (☀ ☔ ⚡ …)
    (0x2700, 0x27BF),    # дингбаты (✂ ✈ ✨ …)
]
# В блоках 2600/2700 эмодзи только часть знаков: остальное — обычные символы.
TEXT_DEFAULT = set(range(0x2600, 0x27C0))
EMOJI_IN_TEXT_BLOCKS = {
    0x2614, 0x2615, 0x2648, 0x2649, 0x264A, 0x264B, 0x264C, 0x264D, 0x264E, 0x264F, 0x2650, 0x2651, 0x2652, 0x2653,
    0x267F, 0x2693, 0x26A1, 0x26AA, 0x26AB, 0x26BD, 0x26BE, 0x26C4, 0x26C5, 0x26CE, 0x26D4, 0x26EA, 0x26F2, 0x26F3,
    0x26F5, 0x26FA, 0x26FD, 0x2705, 0x270A, 0x270B, 0x2728, 0x274C, 0x274E, 0x2753, 0x2754, 0x2755, 0x2757, 0x2795,
    0x2796, 0x2797, 0x27B0, 0x27BF, 0x2600, 0x2601, 0x2602, 0x2603, 0x2604, 0x260E, 0x2611, 0x2618, 0x261D, 0x2620,
    0x2622, 0x2623, 0x2626, 0x262A, 0x262E, 0x262F, 0x2638, 0x2639, 0x263A, 0x2640, 0x2642, 0x265F, 0x2660, 0x2663,
    0x2665, 0x2666, 0x2668, 0x267B, 0x267E, 0x2692, 0x2694, 0x2695, 0x2696, 0x2697, 0x2699, 0x269B, 0x269C, 0x26A0,
    0x26A7, 0x26B0, 0x26B1, 0x26C8, 0x26CF, 0x26D1, 0x26D3, 0x26E9, 0x26F0, 0x26F1, 0x26F4, 0x26F7, 0x26F8, 0x26F9,
    0x2702, 0x2708, 0x2709, 0x270C, 0x270D, 0x270F, 0x2712, 0x2714, 0x2716, 0x271D, 0x2721, 0x2733, 0x2734, 0x2744,
    0x2747, 0x2763, 0x2764, 0x27A1,
}

SYMBOL_RANGES = [
    (0x2190, 0x21FF),  # стрелки
    (0x2200, 0x22FF),  # математика
    (0x2300, 0x23FF),  # технические (⌘ ⌥ ⏎ …)
    (0x2500, 0x257F),  # рамки
    (0x2580, 0x259F),  # блоки
    (0x25A0, 0x25FF),  # геометрия
    (0x20A0, 0x20C0),  # валюты
    (0x2100, 0x214F),  # буквоподобные (℃ № ™ …)
    (0x2150, 0x218F),  # числовые формы (½ Ⅻ …)
    (0x0391, 0x03C9),  # греческие
    (0x00A1, 0x00BF),  # латиница-1: § © ® ° ± …
    (0x2010, 0x205E),  # пунктуация (— … ‰ †)
    (0x27F0, 0x27FF),  # стрелки-дополнение
]

KAOMOJI = [
    ("(◕‿◕)", "happy smile радость улыбка"), ("(＾▽＾)", "happy joy радость"), ("ヽ(•‿•)ノ", "yay hooray ура"),
    ("(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧", "excited sparkle восторг"), ("(｡♥‿♥｡)", "love heart любовь"), ("(づ｡◕‿‿◕｡)づ", "hug обнимашки"),
    ("(っ˘ω˘ς )", "hug cozy обнять"), ("(´｡• ω •｡`)", "cute мило"), ("(✿◠‿◠)", "flower happy цветок"),
    ("(⌐■_■)", "cool sunglasses круто"), ("(•_•) ( •_•)>⌐■-■ (⌐■_■)", "deal with it круто"), ("¯\\_(ツ)_/¯", "shrug whatever пожать плечами"),
    ("(╯°□°）╯︵ ┻━┻", "table flip rage ярость стол"), ("┬─┬ノ( º _ ºノ)", "table back put back стол вернуть"),
    ("(ಠ_ಠ)", "disapproval look неодобрение"), ("(ಥ﹏ಥ)", "cry sad плач"), ("(╥_╥)", "cry tears слёзы"),
    ("(；一_一)", "annoyed раздражение"), ("(¬_¬)", "suspicious подозрение"), ("(⊙_⊙)", "shocked shock шок"),
    ("(°ロ°) !", "surprised удивление"), ("(＞﹏＜)", "pain ouch больно"), ("(￣ヘ￣)", "pout grumpy недоволен"),
    ("(￣ω￣)", "smug довольный"), ("(ᵔᴥᵔ)", "bear мишка"), ("ʕ•ᴥ•ʔ", "bear мишка"), ("(=^･ω･^=)", "cat кот"),
    ("(=｀ω´=)", "cat angry кот злой"), ("U・ᴥ・U", "dog собака"), ("(・(ｪ)・)", "bear мишка"), ("<コ:彡", "squid кальмар"),
    ("( ˘▽˘)っ♨", "tea coffee чай кофе"), ("(っ˘ڡ˘ς)", "yummy food вкусно еда"), ("(ﾉ´ヮ`)ﾉ*: ･ﾟ", "magic sparkle магия"),
    ("( ͡° ͜ʖ ͡°)", "lenny ленни"), ("(•̀ᴗ•́)و ̑̑", "determined go вперёд"), ("ᕦ(ò_óˇ)ᕤ", "strong muscle сила"),
    ("(ง'̀-'́)ง", "fight бой"), ("(☞ﾟヮﾟ)☞", "point you ты"), ("☜(ﾟヮﾟ☜)", "point me я"), ("(¬‿¬)", "smirk ухмылка"),
    ("(￣～￣;)", "thinking hmm думаю"), ("(・・;)", "nervous нервно"), ("(；￣Д￣)", "disgust фу"), ("(×_×)", "dead dizzy мёртв"),
    ("(－‸ლ)", "facepalm фейспалм"), ("(〃＾▽＾〃)", "blush смущение"), ("(*/ω＼)", "shy hide стесняюсь"),
    ("(￣o￣) zzZZzzZZ", "sleep сон"), ("(‐^▽^‐)", "laugh смех"), ("(≧▽≦)", "excited радость"), ("o(≧▽≦)o", "cheer ура"),
    ("(^_^)/", "hi hello привет"), ("(^_^)/~~", "bye пока"), ("m(_ _)m", "sorry bow извини поклон"),
    ("(* ^ ω ^)", "happy счастье"), ("♪(´ε｀ )", "music sing музыка"), ("ヾ(⌐■_■)ノ♪", "dance танец"),
    ("(っ•́｡•́)♪♬", "music музыка"), ("⊂(◉‿◉)つ", "hug обнять"), ("(´・ω・`)", "sad down грусть"),
    ("(◞‸◟；)", "worried переживаю"), ("(￣▽￣)ノ", "wave помахать"), ("( ˘ ³˘)♥", "kiss поцелуй"),
]


def name_of(cp):
    try:
        return unicodedata.name(chr(cp)).lower()
    except ValueError:
        return ""


def main():
    emoji = []
    for a, b in EMOJI_RANGES:
        for cp in range(a, b + 1):
            n = name_of(cp)
            if not n or unicodedata.category(chr(cp)) not in ("So", "Sk"):
                continue
            if cp in TEXT_DEFAULT and cp not in EMOJI_IN_TEXT_BLOCKS:
                continue
            ch = chr(cp) + ("️" if cp in TEXT_DEFAULT else "")
            emoji.append([ch, n])
    symbols = []
    for a, b in SYMBOL_RANGES:
        for cp in range(a, b + 1):
            n = name_of(cp)
            if not n or unicodedata.category(chr(cp)) in ("Zs", "Cc", "Cf", "Mn"):
                continue
            symbols.append([chr(cp), n])
    data = {
        "unicode": unicodedata.unidata_version,
        "emoji": emoji,
        "kaomoji": [[k, t] for k, t in KAOMOJI],
        "symbols": symbols,
    }
    with open(OUT, "w") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")
    print(f"emoji {len(emoji)}, kaomoji {len(KAOMOJI)}, symbols {len(symbols)} → {OUT}")


if __name__ == "__main__":
    main()
