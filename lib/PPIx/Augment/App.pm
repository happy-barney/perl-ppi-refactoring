
use v5.14;
use warnings;

package PPIx::Augment::App {
	use Path::Iterator::Rule;

	sub new {
		my ($class) = @_;

		bless {}, $class;
	}

	sub list_files {
		my ($self, @arguments) = @_;

		@arguments = ('.') unless @arguments;

		Path::Iterator::Rule
			->new
			->file
			->name (qr/\.(?:pm|pl|t)$/)
			->all (@arguments, { recurse => 1 })
		;
	}

	1;
}
