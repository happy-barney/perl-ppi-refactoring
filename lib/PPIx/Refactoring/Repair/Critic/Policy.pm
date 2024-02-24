
use v5.14;
use warnings;

package PPIx::Refactoring::Repair::Critic::Policy {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils qw (
		current
		ppix_exclude
		ppix_include
		where
	);

	use namespace::clean;

	use Perl::Critic::Document;

	sub critic_policy;

	sub what_to_augment {
		my ($self, $document) = @_;

		my $perl_critic = Perl::Critic::Document::->new (-source => $document);
		$perl_critic->process_annotations;

		my $policy = $self->critic_policy->new;
		my @applies_to = $policy->applies_to;

		return where {
			return ppix_exclude unless grep { $_[1]->isa ($_) } @applies_to;
			return ppix_exclude unless my $violation = $policy->violates (current, $perl_critic);
			return ppix_exclude if $perl_critic->line_is_disabled_for_policy ($violation->location->[0], $self->critic_policy);
			return ppix_include;
		};
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::Critic::Policy

=head1 DESCRIPTION

Base class for repairing L<Perl::Critic> violations.

This class uses L<Perl::Critic::Policy> methods C<applies_to> and C<violates>
to determine elements which violates given policy.

L<Current element|PPIx::Augment::Utils/current element> is an instances
of class specified by L<applies_to>.

=head1 METHODS

=head2 critic_policy

	use constant critic_policy => Perl::Critic::Policy::...;

Method must be implemented by child.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
