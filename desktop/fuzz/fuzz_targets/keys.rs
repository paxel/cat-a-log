//! Key records from a peer's file: any text parses to records or to none.
#![no_main]

use catlog_core::signing::parse_keys;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|text: &str| {
    let _ = parse_keys(text);
});
