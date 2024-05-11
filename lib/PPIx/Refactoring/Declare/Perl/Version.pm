
use v5.14;
use warnings;

package PPIx::Refactoring::Declare::Perl::Version {
	use parent q (PPIx::Refactoring);

	use PPIx::Augment::Utils;

	require PPIx::Augment::Augmentation::Repair::PPI::Comment;
	require PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces;

	use mro;

	use namespace::clean;

	sub _guess_required_version {
		my ($self, $document) = @_;

		# TODO: determine min perl
		return v5.10;
	}

	sub new {
		my ($class, %args) = @_;

		my $self = $class->next::method;
		$self->{version} = version->parse ($args{version});

		return $self;
	}

	sub analyze {
		my ($self, $document) = @_;

		return
			unless $document->schild (0)
			;

		return $document;
	}

	sub refactor {
		my ($self, $document) = @_;

		my $stringified = $self->{version}->normal =~ s ([.]0$)()r;

		my $insert_before = $document->schild (0);
		unless ($insert_before) {
			die q (TODO: not implemented: missing first schild);
		}

		my @insert_before;

		if (it_is_statement_include ($insert_before)) {
			if (my $version_element = $insert_before->version) {
				my $version = version->parse ($version_element);
				$insert_before->schild (1)->set_content ($stringified)
					if $version < $self->{version}
					;
				return 1;
			}
		}

		($insert_before) = insert_before $insert_before, [ build_newline ]
			unless it_is_statement_include ($insert_before)
			&& $insert_before->pragma
			;

		insert_before
			$insert_before,
			[
				build_statement_include (
					build_token_word       (q (use)),
					build_token_whitespace (q ( )),
					build_token_number_version ($stringified),
					build_semicolon,
				),
				build_newline,
			];

		return 1;
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
