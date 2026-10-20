# Changelog

All notable changes to cat(a)log are documented in this file.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning: [SemVer](https://semver.org/).

## [2.4.0]

### Added
- A poster can be taken down and another put up (#85). "Flier hangs here" on a cat's page records a flier position where the phone is, like "Seen here now" records a sighting; a hold on the map asks, after the cat, whether it was seen here or its poster hangs here. Every poster still hanging is a square pin on the map, not only the latest; a hold on a pin offers "Flier taken down", which removes that position like any history row, so the pin goes and the history keeps the row with its arrow back. On the desk a right-click on a flier pin takes the poster down, the map's right-click offers the flier beside the sighting, and the cat page's Actions menu has "Flier hangs here" with the position picked on the map; the desk shows every poster as a pin without the stray area switched on.

### Fixed
- The desk records a Moment before a Merge, as the phone does, so a wrong merge can be gone back on from the Moments page.

### Changed
- Every page on the phone has the same top bar: the buttons on their own row, the title under them. A page's actions stand on the bar as long as it has room, and only what does not fit goes into the ⋮ menu, which is gone when nothing is in it: the clowder page shows Hide, Merge and Delete on the bar, a landscape phone or a tablet shows the cat page's whole menu, and an action in the menu wears its icon beside its words.

---

Historical changes have been moved to [OLDER_CHANGES.md](OLDER_CHANGES.md).
