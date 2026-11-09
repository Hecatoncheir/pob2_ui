"""Собрать индекс оригинальных изображений экипировки из каталога PoE2DB."""

from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from html.parser import HTMLParser
import json
from pathlib import Path
from urllib.parse import urlsplit
from urllib.request import Request, urlopen


SOURCE = "https://poe2db.tw/us/"
ART_PREFIX = "/image/Art/2DItems/"
HEADERS = {"User-Agent": "pob2_ui asset catalogue", "Referer": "https://poe2db.tw/"}
CATEGORIES = (
    "Claws Daggers Wands One_Hand_Swords One_Hand_Axes One_Hand_Maces Sceptres Spears "
    "Flails Bows Staves Two_Hand_Swords Two_Hand_Axes Two_Hand_Maces Quarterstaves "
    "Crossbows Traps Talismans Quivers Shields Bucklers Foci Gloves Boots Body_Armours "
    "Helmets Amulets Rings Belts Life_Flasks Mana_Flasks Charms Jewels"
).split()
ROOT = Path(__file__).resolve().parents[1]


def art_path(url):
    uri = urlsplit(url)
    if (uri.scheme == "https" and uri.netloc == "cdn.poe2db.tw"
            and uri.path.startswith(ART_PREFIX) and uri.path.endswith(".webp")
            and not uri.query and not uri.fragment):
        return uri.path.removeprefix(ART_PREFIX)
    return ""


@dataclass
class Entry:
    unique: bool
    image: str = ""
    name: str = ""
    base: str = ""

    def key(self):
        if self.unique:
            return f"{self.name.strip()}, {self.base.strip()}".lower()
        return self.base.strip().lower()


class ItemLinks(HTMLParser):
    def __init__(self):
        super().__init__()
        self.entries = {}
        self.item = None
        self.field = None
        self.hover = ""

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "a":
            self.open_item(attrs.get("data-hover", ""))
        elif self.item and tag == "img":
            self.item.image = art_path(attrs.get("src", "")) or self.item.image
        elif self.item and self.item.unique and tag == "span":
            classes = attrs.get("class", "").split()
            if "uniqueName" in classes:
                self.field = "name"
            elif "uniqueTypeLine" in classes:
                self.field = "base"

    def open_item(self, hover):
        self.item, self.field = None, None
        self.hover = hover
        if "/Poe_Data_UniqueItems_hover/" in hover:
            self.item = Entry(unique=True)
        elif "/Poe_Data_BaseItemTypes_hover/" in hover:
            self.item = Entry(unique=False)
            self.field = "base"

    def handle_data(self, data):
        if self.item and self.field:
            setattr(self.item, self.field, getattr(self.item, self.field) + data)

    def handle_endtag(self, tag):
        if tag == "a":
            if self.item:
                entry = self.entries.setdefault(self.hover, Entry(unique=self.item.unique))
                entry.image = self.item.image or entry.image
                entry.name = self.item.name.strip() or entry.name
                entry.base = self.item.base.strip() or entry.base
            self.item, self.field = None, None
        elif tag == "span" and self.item and self.item.unique:
            self.field = None


def read_category(category):
    request = Request(SOURCE + category, headers=HEADERS)
    with urlopen(request, timeout=25) as response:
        content = response.read(8 * 1024 * 1024 + 1)
    if len(content) > 8 * 1024 * 1024:
        raise ValueError(f"Слишком большой каталог {category}")
    parser = ItemLinks()
    parser.feed(content.decode("utf-8"))
    return parser.entries.values()


def unambiguous(entries, unique):
    matches = {}
    for item in entries:
        if item.unique == unique and item.image and item.base.strip():
            if not unique or item.name.strip():
                matches.setdefault(item.key(), set()).add(item.image)
    return {key: next(iter(images)) for key, images in matches.items() if len(images) == 1}


def main():
    with ThreadPoolExecutor(max_workers=3) as pool:
        entries = [item for page in pool.map(read_category, CATEGORIES) for item in page]
    bases = unambiguous(entries, unique=False)
    uniques = unambiguous(entries, unique=True)
    if "withered wand" not in bases or "liminal coil, twisted wand" not in uniques:
        raise ValueError("В каталоге PoE2DB изменилась разметка")
    target = ROOT / "assets/item_art.json"
    target.parent.mkdir(exist_ok=True)
    data = {"source": SOURCE + "Items", "copyright": "Grinding Gear Games",
            "bases": bases, "uniques": uniques}
    target.write_text(json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                      encoding="utf-8", newline="\n")
    print(f"Изображения: {len(bases)} баз, {len(uniques)} уникальных предметов")


if __name__ == "__main__":
    main()
