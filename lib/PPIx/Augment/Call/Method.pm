
use v5.16;
use strict;
use warnings;

package HPB::PPIx::Augment::Call::Method;

use parent 'PPI::Node';

require PPIx::Utils;
require HPB::PPIx::Utils;

sub augment_document {
	my ($self, $document) = @_;

	my @list =
		grep { $_->content eq '->' }
		@{ $document->find ('
}

sub set_object {
	my ($self, $node) = @_;

	$self->{ppix_object} = $node;
}

sub set_call {
	my ($self, @node) = @_;
}

sub set_method {
}

sub content {
}
