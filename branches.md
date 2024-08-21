
# stage-0-basic-layout

Setup `PPIx::Augment` environment:
- `dew-sanity`
- `test-helper.pl`
- internal utils and exporter
- `Utils` - minimal layout
  - current / no / effective element
  - basic traversal / transformer

# stage-1-dom-elements

`PPIx::Augment::DOM::` counterparts to `PPI`

## Methods
   - `available_since` - inclusive v-string
   - `available_until` - exclusive v-string
   - `identify` - whether given element represents class (including `PPI::Element`)
   - `classify` - `identify` + classification
   - `Token::content_regex` - formal validation of token value

## Additional classes
   - `DOM::Number::Integer`
   - `DOM::Number::Decimal`
   - `DOM::Number::Octal::Traditional`
   - `DOM::Number::Octal::V_534`
