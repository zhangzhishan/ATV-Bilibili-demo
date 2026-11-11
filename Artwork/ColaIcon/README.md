# Kanpai cola branding

The icon depicts two handleless glasses of dark cola with ice, clinking together.
The original blue celebratory palette is retained; there are no beer handles or foam heads.

## Source

`cola-master.png` is the unmodified Azure GPT Image edit result, based on the previous
1280×768 icon back layer. Keep this master rather than regenerating art during builds.

Art brief: replace both beer mugs with clear handleless cola tumblers; dark brown cola,
reddish amber highlights, large translucent ice cubes, bubbles and condensation; rims
touch near the upper center; preserve the polished saturated blue/cyan celebratory
illustration and central sparkle; full glasses with safe margins; no beer foam, handles,
text, labels, logos or watermark. Generated at 1536×1024, high quality/high input fidelity.

## Rebuild and verify

```sh
python3 Artwork/ColaIcon/export_assets.py
python3 Artwork/ColaIcon/export_assets.py --verify
```

Requires Pillow. All 17 production PNGs are checked in, so Xcode/Cloud builds need no
Python packages or image-generation credentials. The export script fits the entire
master into 5:3 for tvOS icons without cutting either glass base, preserves the existing identical full-bleed layer convention,
and composes uncropped standard/wide Top Shelf images on softly extended blue artwork.
It records dimensions and SHA-256 hashes and verifies every asset-catalog filename.
