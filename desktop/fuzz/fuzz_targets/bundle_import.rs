//! A bundle file (a share, an import, a backup being restored) comes from
//! outside: importing any bytes into a fresh Catalog ends in a result or an
//! error, never a panic.
#![no_main]

use std::io::Write;

use catlog_core::Catalog;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|bytes: &[u8]| {
    let Ok(dir) = tempfile::tempdir() else {
        return;
    };
    let Ok(mut catalog) = Catalog::open(dir.path()) else {
        return;
    };
    let path = dir.path().join("incoming.catsync");
    let Ok(mut file) = std::fs::File::create(&path) else {
        return;
    };
    if file.write_all(bytes).and_then(|()| file.flush()).is_err() {
        return;
    }
    let _ = catalog.import_bundle(&path);
});
