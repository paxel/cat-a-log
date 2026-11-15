//! The body of a joiner's `/sync` request: whatever it holds, the host
//! answers or refuses, never panics.
#![no_main]

use catlog_core::Catalog;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|body: &[u8]| {
    let Ok(dir) = tempfile::tempdir() else {
        return;
    };
    let Ok(mut catalog) = Catalog::open(dir.path()) else {
        return;
    };
    let _ = catalog.serve_sync(body, false);
});
