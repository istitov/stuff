# media-plugins — DeaDBeeF plugins

This category holds twenty-six plugins for the
[DeaDBeeF](https://deadbeef.sourceforge.io/) audio player. The player itself is
in `::gentoo`; the overlay adds a patched revision and a live ebuild of
`media-sound/deadbeef`.

- Formats and sources: `deadbeef-opus`, `deadbeef-vgmstream`,
  `deadbeef-archive-reader`, `deadbeef-vfs-rar`.
- Output: `deadbeef-pulse2`, `deadbeef-jack`.
- Sound: `deadbeef-bs2b`, `deadbeef-stereo-widener`,
  `deadbeef-replaygain-control`, `deadbeef-dr-meter`.
- Visualization: `deadbeef-spectrogram`, `deadbeef-musical-spectrum`,
  `deadbeef-vu-meter`, `deadbeef-waveform-seekbar`.
- Interface widgets: `deadbeef-fb` (file browser), `deadbeef-quick-search`,
  `deadbeef-customizable-toolbar`, `deadbeef-headerbar`,
  `deadbeef-playback-order`, `deadbeef-playback-status`, `deadbeef-rating`,
  `deadbeef-bookmark-manager`, `deadbeef-copy-info`.
- Desktop integration: `deadbeef-statusnotifier`, `deadbeef-gnome`
  (multimedia keys), `deadbeef-discord-presence`.

The one package here that is not for DeaDBeeF is `frei0r-plugins`, a
video-effects collection, for which the overlay adds only a live ebuild.

To enable the overlay, see the [setup guide](https://istitov.github.io/stuff/setup/)
or the [overlay README](../README.md).
