# Lunar terrain sources

## Version 0 source

Use NASA Scientific Visualization Studio's **CGI Moon Kit**:

- page: https://svs.gsfc.nasa.gov/4720
- 4-pixels/degree unsigned displacement TIFF:
  https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/ldem_4_uint.tif
- 2K 2025 LROC color JPEG:
  https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/lroc_color_2k.jpg

The displacement map is 1440 x 720 and about 2 MB.  NASA describes the
unsigned samples as half-meter units with a +20,000-sample offset.  Equivalently,

    lunar_height_metres = 0.5 * (sample - 20000)

relative to the 1,737,400 m lunar reference sphere.

The first game should not preserve the Moon's physical radius.  It should
preserve the *shape* while rescaling onto a roughly 20 m toy planet:

    game_height =
        lunar_height_metres
        * (game_radius / 1737400)
        * vertical_exaggeration

with `vertical_exaggeration` initially around 20.

That keeps craters and highlands visible at walking scale without replacing the
real elevation field with procedural noise.

## Lighter debug source

NASA also exposes:

- 1024 x 512 8-bit elevation JPEG:
  https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/ldem_3_8bit.jpg

This is useful for a renderer smoke test but should not become the canonical
height data because the 16-bit TIFF retains much more elevation information.

## Higher-resolution follow-up

Once the renderer and asset pipeline are stable:

- `ldem_16_uint.tif`: 5760 x 2880, about 31.7 MB
- `ldem_64_uint.tif`: 23040 x 11520, about 506 MB

The phone should receive a preprocessed compact asset, not decode the large
scientific source product at runtime.

For a later high-detail region, SLDEM2015 combines LOLA with Kaguya Terrain
Camera stereo data at about 512 pixels/degree over latitudes 60 S to 60 N.

## Provenance

The CGI Moon Kit says its elevation maps are reformatted from LRO Lunar Orbiter
Laser Altimeter gridded products and its color maps are based on the LRO Camera
wide-angle mosaic. Keep this provenance and credit in any packaged build.
