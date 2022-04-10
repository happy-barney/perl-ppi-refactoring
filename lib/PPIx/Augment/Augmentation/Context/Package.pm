
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Context::Package {
	use parent qw[ PPIx::Augment::Augmentation ];

	use PPIx::Augment::Utils;
	use PPI::Singletons '%_PARENT';
	use Scalar::Util    qw{refaddr};

	use List::MoreUtils qw[ part ];

	use PPIx::Augment::Context::Package;

	my $AUGMENT_CLASS = PPIx::Augment::Context::Package::;

	sub _wrap {
		elements_wrap ($AUGMENT_CLASS, @_);
	}

	sub _process_partition {
		my ($partition) = @_;

		# Partition which doesn't start with package declaration then process all elements
		return @$partition unless it_is_package_declaration $partition->[0];

		_wrap (@$partition);

		# When partition starts with package declaration then process only following elements
		@$partition[1 .. $#$partition];
	}

	sub _split_children_by_package_declaration {
		my $i = 0;

		my @children = children;
		my @partitions =
			part { $i++ if it_is_package_declaration; $i }
			@children
			;

		return grep { $_ } @partitions;
	}

	sub augment {
		my (undef, $document) = @_;

		my @queue = ($document);

		while (local $_ = shift @queue) {
			if (it_is_package_definition) {
				my ($block) = grep { it_is_structure_block } children;
				my $context = _wrap ($_);
				push @queue, $block;
				next;
			}

			push @queue,
				map { _process_partition $_ }
				_split_children_by_package_declaration
				;
		}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Context::Package - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Context::Package->requires ($ppi_document)
	PPIx::Augment::Augmentation::Context::Package->augment ($ppi_document)

=head1 DESCRIPTION

Wraps every statement belonging to package into L<PPIx::Augment::Context::Package>
node. Package statement is always first child of given node.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
