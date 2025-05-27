
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);

	use PPI v1.278;

	use PPIx::Augment::DOM::No_Element;

	use constant ppi_class => q (PPI::Element);

	sub _no_element () {
		PPIx::Augment::DOM::No_Element::->new;
	}

	sub document {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub next_sibling {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub next_token {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub parent {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub previous_sibling {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub previous_token {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub snext_sibling {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub sprevious_sibling {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub statement {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	sub top {
		$_[0]->next::method () || $_[0]->_no_element;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Element - Augmented PPI class

=head1 INHERITANCE

TODO

=head1 DESCRIPTION

An augmented counterpart to L<PPI::Element>.

=head1 CONCEPT - NO ELEMENT

Unlike L<PPI>, scalar context lookup methods of L<PPIx::Augment> DOM elements
return an object which:

=over

=item in boolean context, evaluates as C<false>

=item is outside of the L<PPI::Element> inheritance tree

=item supports all DOM methods, returning a safe false value

=back

This allows for cleaner code, for example:

	while ($element->parent->snext_sibling->snext_sibling) {
	}

rather than:

	while (
        $element->parent
        && $element->parent->snext_sibling
        && $element->parent->snext_sibling->snext_sibling
    ) {
	}

C<No element> value is an instance of L<PPIx::Augment::DOM::No_Element>.

This concept affects the following methods:

=head2 document

=head2 next_sibling

=head2 next_token

=head2 parent

=head2 previous_sibling

=head2 previous_token

=head2 snext_sibling

=head2 sprevious_sibling

=head2 statement

=head2 top

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
