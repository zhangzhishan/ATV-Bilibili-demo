#!/usr/bin/env python3
"""Rebuild tvOS branding from the checked-in cola master (requires Pillow)."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageFilter, ImageOps

HERE = Path(__file__).resolve().parent
BRAND = HERE.parents[1] / 'BilibiliLive/Supporting Files/Assets.xcassets/App Icon & Top Shelf Image.brandassets'


def export():
    master = Image.open(HERE / 'cola-master.png').convert('RGB')
    # Keep both glass bases intact: fit the entire 3:2 master into 5:3.
    # Extend/feather only the empty side gutters, never crop the artwork vertically.
    icon = ImageOps.fit(master, (1280, 768), method=Image.Resampling.LANCZOS).filter(ImageFilter.GaussianBlur(24))
    subject = ImageOps.contain(master, (1280, 768), method=Image.Resampling.LANCZOS)
    icon_mask = Image.new('L', subject.size, 255)
    for x in range(60):
        opacity = round(255 * x / 60)
        icon_mask.paste(opacity, (x, 0, x + 1, subject.height))
        icon_mask.paste(opacity, (subject.width - x - 1, 0, subject.width - x, subject.height))
    icon.paste(subject, ((1280 - subject.width) // 2, 0), icon_mask)
    files = []
    for stack, sizes in [('App Icon - App Store.imagestack', [(1280, 768, '')]),
                         ('App Icon.imagestack', [(400, 240, '_1x'), (800, 480, '_2x')])]:
        for layer in ['Front', 'Middle', 'Back']:
            for width, height, suffix in sizes:
                path = BRAND / stack / f'{layer}.imagestacklayer/Content.imageset/{layer.lower()}{suffix}.png'
                # Preserve the existing project's identical full-bleed stack convention.
                icon.resize((width, height), Image.Resampling.LANCZOS).save(path)
                files.append(path)
    for name, width in [('Top Shelf Image', 1920), ('Top Shelf Image Wide', 2320)]:
        for scale, suffix in [(1, ''), (2, '@2x')]:
            size = (width * scale, 720 * scale)
            # Extend the blue artwork softly, without vertically cropping the glasses.
            background = ImageOps.fit(master, size, method=Image.Resampling.LANCZOS).filter(ImageFilter.GaussianBlur(36 * scale))
            foreground = ImageOps.contain(master, (1080 * scale, 720 * scale), method=Image.Resampling.LANCZOS)
            mask = Image.new('L', foreground.size, 255)
            # Feather only the horizontal gutters; keep the central glasses untouched.
            edge = 100 * scale
            for x in range(edge):
                opacity = round(255 * x / edge)
                mask.paste(opacity, (x, 0, x + 1, foreground.height))
                mask.paste(opacity, (foreground.width - x - 1, 0, foreground.width - x, foreground.height))
            background.paste(foreground, ((size[0] - foreground.width) // 2, 0), mask)
            prefix = 'TopShelfWide' if name.endswith('Wide') else 'TopShelf'
            for marketing in ['', '-marketing']:
                path = BRAND / f'{name}.imageset' / f'{prefix}{marketing}{suffix}.png'
                background.save(path)
                files.append(path)
    rows = []
    for path in sorted(files):
        with Image.open(path) as image:
            rows.append({'path': str(path.relative_to(BRAND)), 'size': list(image.size),
                         'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
    (HERE / 'asset-manifest.json').write_text(json.dumps(rows, indent=2) + '\n')
    print(f'Exported {len(rows)} branding PNGs')


def verify():
    manifest = json.loads((HERE / 'asset-manifest.json').read_text())
    assert len(manifest) == 17
    for row in manifest:
        path = BRAND / row['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], path
        with Image.open(path) as image:
            assert list(image.size) == row['size'], path
            assert image.mode == 'RGB', path
            image.verify()
    # Validate ALL catalog references, including the top-shelf root entries.
    for path in BRAND.rglob('Contents.json'):
        doc = json.loads(path.read_text())
        for group in ['assets', 'layers', 'images']:
            for entry in doc.get(group, []):
                if 'filename' in entry:
                    assert (path.parent / entry['filename']).exists(), (path, entry['filename'])
    print('PASS: 17 images, exact dimensions, opaque pixels, hashes, catalog references')


if __name__ == '__main__':
    import sys
    if '--verify' not in sys.argv:
        export()
    verify()
