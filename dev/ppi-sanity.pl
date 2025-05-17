#!/usr/bin/env perl

use v5.14;
use strict;

package App::ppi_sanity {

	use Attribute::Handlers;
	use Getopt::Long qw (GetOptionsFromArray);
	use Path::Iterator::Rule;
	use PPI;

	my @DEFAULT_INCLUDE = qw (bin lib t);

	my @POLICIES;
	my @POLICIES_DEFAULT;
	my @POLICIES_EFFECTIVE;

	my $verbose = 0;

	sub Policy                          :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @POLICIES, *{$symbol}{NAME};
	}

	sub Default                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @POLICIES_DEFAULT, *{$symbol}{NAME};
	}

	sub verbose (&);

	sub _build_path_iterator {
		my ($options) = @_;

		my $exclude = _build_path_regex (@{ $options->{exclude} // [] });

		my $rule = Path::Iterator::Rule
			->new
			->file
			->or (
				Path::Iterator::Rule->new->name (qr ( [.] (?: pm | pl | t ) $ )x),
				Path::Iterator::Rule->new->shebang (qr (^[#]! .* \b perl \b )x),
			)
			;

		$rule = $rule ->not (sub { $_ =~ $exclude })
			if $exclude
			;

		$rule->iter (@{ $options->{include} }, { recurse => 1 });
	}

	sub _build_path_regex {
		return
			unless my $regex = join q (|), map { qr ((?:\Q$_\E)) } @_
			;

		return qr (\b $regex $)x;
	}

	sub parse_options {
		my (@argv) = @_;

		my %options = (
			verbose  => 0,
		);

		GetOptionsFromArray (
			\ @argv,
			'include=s@' => sub { push @{ $options{include} //= [] }, $_[1] },
			'exclude=s@' => sub { push @{ $options{exclude} //= [] }, $_[1] },
			'verbose'    => \ $options{verbose},

			# policies options
			map {
				my $policy = $_;
				my $option = $_ =~ tr [_] [-]r =~ s (^policy[-]) ()r;
				($option => sub { push @{ $options{policies} //= [] }, $policy })
			}
			@POLICIES
		);

		push @{ $options{include} //= [] }, @argv
			if @argv
			;

		# Default values
		# ##########################################################

		$options{include}  //= \ @DEFAULT_INCLUDE;
		$options{policies} //= \ @POLICIES;

		return \ %options;
	}

	sub run {
		my $options = & parse_options;

		$verbose = $options->{verbose};

		my $iterator = _build_path_iterator ($options);

		while (my $file = $iterator->()) {
			verbose { qq (==> $file) };

			eval {
				my $document = PPI::Document::->new (qq ($file));
				my $changes = 0;

				for my $policy (@POLICIES_EFFECTIVE) {
					verbose { q (  > policy ), $policy };

					if (__PACKAGE__->can ($policy)->($document)) {
						say qq ([$file] '$policy' modified document);
						$changes ++;
					};
				}

				$document->save ($file)
					if $changes
					;

				1;
			} // do {
				say qq ([$file] Oops, something went wrong: $@);
			};
		}
	}

	sub verbose (&) {
		my $code = shift;

		say $code->() if $verbose;
	}
}

App::ppi_sanity::run (@ARGV)
	unless caller
	;
