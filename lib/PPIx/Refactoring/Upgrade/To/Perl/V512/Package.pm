
use v5.14;
use warnings;

package PPIx::Refactoring::Upgrade::To::Perl::V512::Package {
	use parent q (PPIx::Refactoring);

	use PPIx::Augment::Utils;

	require PPIx::Augment::Augmentation::Repair::PPI::Comment;
	require PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces;

	use namespace::clean;

	sub how_to_refactor {
		invoke {
			my $from = 1 + child_index;

			my $sibling = current;
			while (1) {
				my $next_sibling = next_sibling $sibling;
				last unless $next_sibling;
				last if it_is_statement_package ($next_sibling);
				last if it_is_statement_end ($next_sibling);
				last if it_is_statement_data ($next_sibling);

				$sibling = $next_sibling;
			}

			my $to = child_index ($sibling) // -1;

			my @children = children (parent, $from, $to);

			pop @children
				while ! it_is_significant ($children[-1])
				;

			my $block = build_block (
				elements_remove (\ @children),
				build_newline,
			);

			# TODO: Augmentation Indent + increase indent

			ppix_search $block
				=> where {
					it_is_newline
					and it_is_not { it_is_newline (next_sibling) }
					# it_is_not { it_is_last_token }
					and ppi_bool (next_token next_token)
				}
				=> invoke {
					it_is_token_whitespace (next_sibling)
						? next_sibling->set_content (qq (\t) . next_sibling->content)
						: insert_after current, [ build_token_whitespace (qq (\t)) ]
				};

			elements_replace
				[ last_child ],
				[
					build_token_whitespace (q ( )),
					$block,
				];

		}
	}

	sub what_to_refactor {
		where {
			return ppi_exclude unless it_is_package_declaration;
			return ppi_exclude unless next_sibling;
			return ppi_include;
			say q (=> what: ), ref;
			it_is_package_declaration and next_sibling
		}
	}

	sub requires {
		return +(
			PPIx::Augment::Augmentation::Repair::PPI::Comment::,
			PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces::,
		);
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring::Upgrade::To::Perl::V512::Package

=head1 DESCRIPTION

Upgrade package statement to it's v5.12 version.

For example, it transforms

	package Foo;
	sub bar {}

into

	package Foo {
		sub bar {}
	}

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
