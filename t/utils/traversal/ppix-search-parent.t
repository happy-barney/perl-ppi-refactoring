
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use Safe::Isa qw ($_isa);

my $fixture = ppi_document <<'END_OF_DOCUMENT';
package Foo {
	package Bar {
		sub foo {
			sub { baz }
		}
	}
}
END_OF_DOCUMENT

my ($node) = ppix_search $fixture => where {
	$_->content eq q (baz) && $_->$_isa (PPI::Token::);
};

assume      q (ppix_search_parent () without arguments returns empty list)
	=> got    => [ ppix_search_parent ]
	=> expect => [ ]
	;

assume      q (ppix_search_parent () without where returns empty list)
	=> got    => [ ppix_search_parent $node ]
	=> expect =>  [ ]
	;

assume      q (ppix_search_parent () lists all parents)
	=> got    => [ ppix_search_parent $node, where { ppi_include } ]
	=> expect => [
		expect_element (PPI::Statement::            => ()),
		expect_element (PPI::Structure::Block::     => ()),
		expect_element (PPI::Statement::            => ()),
		expect_element (PPI::Structure::Block::     => ()),
		expect_element (PPI::Statement::Sub::       => { name => q (foo) }),
		expect_element (PPI::Structure::Block::     => ()),
		expect_element (PPI::Statement::Package::   => { namespace => q (Bar) }),
		expect_element (PPI::Structure::Block::     => ()),
		expect_element (PPI::Statement::Package::   => { namespace => q (Foo) }),
		expect_element (PPI::Document::             => ()),
	];
	;

assume      q (ppix_search_parent () recognizes and apply where clause)
	=> got    => [
		ppix_search_parent $node,
		where { $_->$_isa (PPI::Statement::Package::) }
	]
	=> expect => [
		expect_element (PPI::Statement::Package::   => { namespace => q (Bar) }),
		expect_element (PPI::Statement::Package::   => { namespace => q (Foo) }),
	];

assume      q (ppix_search_parent() recognizes 'ppi_exclude_all')
	=> got    => [
		ppix_search_parent $node,
		where {
			$_->$_isa (PPI::Statement::Package::)
				? ppix_exclude_all
				: ppix_include
		}
	]
	=> expect => [
		# should return only parents up to first package
		expect_element (PPI::Statement::            => ()),
		expect_element (PPI::Structure::Block::     => ()),
		expect_element (PPI::Statement::            => ()),
		expect_element (PPI::Structure::Block::     => ()),
		expect_element (PPI::Statement::Sub::       => { name => q (foo) }),
		expect_element (PPI::Structure::Block::     => ()),
	];

had_no_warnings;
done_testing;

