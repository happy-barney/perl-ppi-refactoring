
package Foo;

sub foo ($bar) {
	$bar ? <<'TRUE' : <<'FALSE';
true
TRUE
false
FALSE
}
