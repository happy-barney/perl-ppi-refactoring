
# stage-0-basic-layout

Setup `PPIx::Augment` environment:
- `dew-sanity`
- `test-helper.pl`
- internal utils and exporter
- `Utils` - minimal layout
  - current / no / effective element
  - basic traversal / transformer

# stage-1-utils-ppi

Utils wrapping / using PPI::Element interface

# stage-2-utils-augment

Extended utils wrapping / using PPIx::Augment::DOM::Element interface

# stage-3-augmentation

Augmentation of PPI documents
- fix PPI issues (from PPIx::Augment perspective)
  - PPIx::Augment expects parse (and fix) invalid code
    PPI, optimistically, assumes that code is valid
  - TODO port fixes back into PPI
