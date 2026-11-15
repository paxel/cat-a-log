//! A pair code as typed or scanned: any text decodes to a pairing or to
//! nothing, and a decoded pin has six digits.
#![no_main]

use catlog_core::lan::decode_pair_code;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|text: &str| {
    if let Some(info) = decode_pair_code(text) {
        assert_eq!(info.pin.len(), 6, "{info:?}");
        assert!(info.port != 0, "{info:?}");
    }
});
