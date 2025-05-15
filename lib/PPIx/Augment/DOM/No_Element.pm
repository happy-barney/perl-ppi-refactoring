
use v5.14;
use warnings;

package PPIx::Augment::DOM::No_Element {

	use PPI;

	use overload q (bool) => \ &PPI::Util::FALSE;
	use overload q ("")   => \ &content;
	use overload q (==)   => \ &PPI::Util::FALSE;
	use overload q (!=)   => \ &PPI::Util::FALSE;
	use overload q (eq)   => \ &PPI::Util::FALSE;
	use overload q (ne)   => \ &PPI::Util::FALSE;

	sub new {
		bless {}, ref $_[0] || $_[0];
	}

	sub ancestor_of         { PPI::Util::FALSE }
	sub child               { shift->new }
	sub children            { () }
	sub class               { goto &PPI::Element::class }
	sub contains            { PPI::Util::FALSE }
	sub content             { q () }
	sub descendant_of       { PPI::Util::FALSE }
	sub document            { shift->new }
	sub elements            { () }
	sub find                { PPI::Util::FALSE }
	sub find_any            { PPI::Util::FALSE }
	sub find_first          { shift->new }
	sub first_element       { shift->new }
	sub first_token         { shift->new }
	sub last_element        { shift->new }
	sub last_token          { shift->new }
	sub next_sibling        { shift->new }
	sub parent              { shift->new }
	sub previous_sibling    { shift->new }
	sub prune               { 0 }
	sub remove_child        { shift->new }
	sub replace_child       { shift->new }
	sub schild              { shift->new }
	sub schildren           { () }
	sub set_content         { shift->new }
	sub significant         { PPI::Util::FALSE }
	sub snext_sibling       { shift->new }
	sub sprevious_sibling   { shift->new }
	sub statement           { shift->new }
	sub tokens              { };;
	sub top                 { shift->new }

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::No_Element

=head1 DESCRIPTION

Class represents L<PPI::Node> compatible value with all methods returning value expected
to be returned by "this element doesn't exist".

Class exists so it will be possible to chain misc method calls without error.

=over

=item every comparison returns false

=item evaluates as false in boolean context

=item every scalar element accessor returns "no element" instance

=item every list elements accessor returns empty list

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
