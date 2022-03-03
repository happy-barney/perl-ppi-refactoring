
use v5.16;
use warnings;

package PPIx::Augment::Expression::Call::Function {
	use parent qw[ PPIx::Augment::Expression ];

	use HPB::PPIx::Utils qw[];

	sub new {
		my ($class, %content) = @_;

		my $self = $class->SUPER::new;

		$self->add_element ($self->function ($content{function}));

		$self->add_element ($self->arguments ($content{arguments}))
			if $content{arguments};

		return $self;
	}

	sub function {
		shift->_accessor (ppix_augment_function => @_);
	}

	sub arguments {
		shift->_accessor (ppix_augment_arguments => @_);
	}
}

1;
