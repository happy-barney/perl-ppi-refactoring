
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use Exporter    qw[ import ];
	use Attribute::Handlers;

	use PPIx::Utils qw[];
	use Ref::Util   qw[];
	use Safe::Isa;

	use PPIx::Augment::Elements;

	our @EXPORT;
	our @EXPORT_OK;

	sub EXPORT :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT, *{$symbol}{NAME};
		push @EXPORT_OK, *{$symbol}{NAME};
	}

	sub EXPORT_OK :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT_OK, *{$symbol}{NAME};
	}

	sub _build_where {
		my ($where, @where) = grep $_->isa ('PPIx::Augment::Utils::Where'), @_;

		if (@where) {
			unshift @where, $where;
			$where = sub {
				my $context = $_;
				my $result = 1;
				for my $element (@where) {
					$result &&= $element->(@_);
				}
				$result;
			};
		}

		return $where // sub { };
	}

	sub _build_invoke {
		my ($invoke) = grep $_->isa ('PPIx::Augment::Utils::Invoke'), @_;

		return $invoke // sub { };
	}

	sub _ppix_transform {
		my ($element, $start, $step, @params) = @_;

		my $where = _build_where (@params);
		my $invoke = _build_invoke (@params);

		my $rv = 0;
		my @current = ([ $element, $start ]);

		while (@current) {
			my ($current, $index) = @{ shift @current };
			next unless $current;
			local $_ = $current;
			# when $current is replaced it losts its parent reference
			my $parent = $current->parent;

			if ($parent) {
				my $next_index = $index + $step;
				unshift @current, [ $parent->child ($next_index), $next_index ]
			}

			if ($where->()) {
				$rv++;
				$invoke->();
				$current = $parent->child ($index)
					if $parent;
			}

			unshift @current, [ $current->child ($start), $start ]
				if $current->$_isa (PPI::Node::);
		}

		return $rv;
	}

	sub current                     :EXPORT {
		$_;
	}

	sub invoke (&)                  :EXPORT {
		bless $_[0], 'PPIx::Augment::Utils::Invoke';
	}

	sub ppix_find                   :EXPORT {
		my ($element, $what, @args) = @_;

		return unless $element;
		my $where = Ref::Util::is_coderef ($what)
			? sub { local $_ = $_[1]; $what->($_[1], @args) }
			: $what
			;
		@{ $element->find ($where) || [] };
	}

	sub ppix_transform              :EXPORT {
		my ($element, @params) = @_;

		_ppix_transform ($element, 0, 1, @params);
	}

	sub ppix_transform_reverse      :EXPORT {
		my ($element, @params) = @_;

		_ppix_transform ($element, -1, -1, @params);
	}

	sub where (&)                   :EXPORT {
		bless $_[0], 'PPIx::Augment::Utils::Where';
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils - PPI processing utils

=head1 DESCRIPTION

Based on L<PPIx::Utils> idea, provides additional PPI utils.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
