//! A scanned share QR code: any text decodes to a share or to nothing.
#![no_main]

use catlog_core::share::decode_share_qr;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|text: &str| {
    let _ = decode_share_qr(text);
});
