# sci-physics — scattering, spectroscopy and magnetism

This category holds materials-science software that `::gentoo` does not carry.
The supporting libraries live in `sci-libs/` and `dev-python/`.

- Small-angle scattering: `sasview`, `mantid` (SANS reduction, installed under
  `/opt/mantid`), and `numagsans` for magnetic SANS simulation (CUDA).
- Reflectometry and grazing incidence: `bornagain`.
- X-ray absorption: `xraylarch`, the modern replacement for the discontinued
  `ifeffit` (also here), and the classic Athena and Artemis GUIs in `demeter`.
- Powder diffraction: the Rietveld engine `bgmn` and its Qt6 front end
  `profex`.
- Electron microscopy: `prismatic` for STEM image simulation. The HyperSpy
  stack is in `dev-python/`.
- Micromagnetism: `mumax` (CUDA), `oommf`, and atomistic spin dynamics in
  `vampire`.

The [overlay README](../README.md) gives a broader overview with the related
libraries.
