
use v5.14;
use warnings;

package PPIx::Refactoring::Repair::Critic::Policy {
	use parent q (PPIx::Refactoring);

	use PPIx::Augment::Utils qw (
		current
		ppi_exclude
		ppi_include
		where
	);

	require PPIx::Augment::Augmentation::Repair::PPI::Comment;
	require PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces;

	use namespace::clean;

	sub how_to_refactor {
		invoke {
			my $from = 1 + child_index;

			my $sibling = current;
			do {
				my $next_sibling = next_sibling;
				last unless $next_sibling;
				last if it_is_statement_package ($next_sibling);
				last if it_is_statement_end ($next_sibling);
				last if it_is_statement_data ($next_sibling);

				$sibling = $next_sibling;
			} while (1);

			my $to = child_index ($sibling) // -1;

			my @children = children (parent, $from, $to);

			pop @children
				while it_is_token_whitespace ($children[-1])
				;

			elements_replace
				[ last_element ],
				[
					build_token_whitespace (q ( )),
					(my $block = build_block (@children)),
				];

			ppix_transform $block
				=> where { it_is_newline && it_is_not { it_is_newline next_token } }
				=> invoke {
					if (it_is_token_whitespace (my $next_token = next_token)) {
						$next_token->set_content (q (\t) . $next_token->content);
					} else {
						insert_after (build_token_whitespace (q (\t)));
					}
				};
		}
	}

	sub what_to_refactor {
		where { it_is_package_declaration && next_sibling }
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

PPIx::Refactoring::Repair::Critic::Policy

=head1 DESCRIPTION

Base class for repairing L<Perl::Critic> violations.

This class uses L<Perl::Critic::Policy> methods C<applies_to> and C<violates>
to determine elements which violates given policy.

It recognizes L<no critic> notifications.

L<Current element|PPIx::Augment::Utils/current element> is an instances
of class specified by L<applies_to>.

=head1 METHODS

=head2 critic_policy

Method must be implemented by child.

	use constant critic_policy => Perl::Critic::Policy::...;

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
