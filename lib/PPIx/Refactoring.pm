
use v5.14;
use warnings;

package PPIx::Refactoring {
	use PPIx::Augment::Utils;

	use Module::Load qw[];
	use Safe::Isa;
	use Ref::Util;

	use PPI;
	use PPIx::Augment;

	sub new {
		my ($class, $source, @params) = @_;

		my $document;

		$document = $source
			if $source->$_isa ('PPI::Document');

		unless ($document) {
			$source = "$source"
				if $source->$_isa ('Path::Tiny');

			die "File $source doesn't exist"
				unless ref $source || -e $source;

			$document = PPIx::Augment->new ($source);
		}

		bless { document => $document, params => \ @params }, $class;
	}

	sub find_refactoring {
		my ($self, $refactoring) = @_;

		my $name = $refactoring =~ s/-/_/gr;

		die "Invalid refactoring name: $refactoring"
			unless $name =~ m/[_:]/;

		return undef
			// $self->can ($name)
			// $self->can ("refactoring_$name")
			// eval {
				my $package = __PACKAGE__ . '::' . $name;
				Module::Load::load ($package);
				$package->can ('refactoring');
			}
			// eval {
				my $package = $name;
				Module::Load::load ($package);
				$package->can ('refactoring');
			}
			// die "Invalid refactoring: $refactoring"
			;
	}

	sub save {
		my ($self, $filename) = @_;
		$filename //= $self->{document}->filename;

		return
			unless $self->{modified} || $filename ne $self->{document}->filename;

		$self->{document}->save ($filename);
	}

	sub apply {
		my ($self, $refactoring, @params) = @_;

		@params = @{ $self->{params} } unless @params;

		my $function = $self->find_refactoring ($refactoring);

		$function->($self, $self->{document}, @params);
	}

	sub refactor {
		my ($self, $refactoring, @params) = @_;

		$self->{modified} ||= $self->apply ($refactoring, @params);
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring - Basic framework for automated refactorings

=head1 DESCRIPTION

Fix some bugs and improve structre of PPI documents

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

Test::YAFT distribution is distributed under Artistic Licence 2.0.

=cut
