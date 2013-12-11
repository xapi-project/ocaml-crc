CRC implementation for OCaml
============================

This library allows you to compute CRC-32 checksums of buffers
and strings e.g.

```
# Crc32.string "hello" 0 5;;
- : int32 = 907060870l
```

The current algorithm is
[CRC-32](http://en.wikipedia.org/wiki/Cyclic_redundancy_check#Commonly_used_and_standardized_CRCs)
as used by HDLC, ANSI X3.66, ITU-T V.42,
Ethernet, Serial ATA, MPEG-2, PKZIP, Gzip, Bzip2, PNG and
others.

