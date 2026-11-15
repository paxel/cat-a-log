//! What a peer on the network sends the host: any bytes parse to a request,
//! to nothing, or to an error, never a panic.
#![no_main]

use std::net::{IpAddr, Ipv4Addr};

use catlog_core::lan::read_request;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|bytes: &[u8]| {
    let mut reader = std::io::BufReader::new(bytes);
    let _ = read_request(&mut reader, IpAddr::V4(Ipv4Addr::LOCALHOST));
});
