
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Rebless {
	use PPIx::Augment::Utils;
	use PPIx::Augment::Elements;
	use Ref::Util qw[ is_plain_hashref ];

	use namespace::clean;

	our %rebless_map = (
		PPI::Document::                 => PPIx::Augment::Document::,
		PPI::Structure::Block::         => PPIx::Augment::Structure::Block::,
		PPI::Structure::Condition::     => PPIx::Augment::Structure::Condition::,
		PPI::Structure::Constructor::   => PPIx::Augment::Structure::Constructor::,
		PPI::Structure::For::           => PPIx::Augment::Structure::For::,
		PPI::Structure::Given::         => PPIx::Augment::Structure::Given::,
		PPI::Structure::List::          => PPIx::Augment::Structure::List::,
		PPI::Structure::Unknown::       => PPIx::Augment::Structure::Unknown::,
		PPI::Structure::When::          => PPIx::Augment::Structure::When::,
		PPI::Structure::Subscript::     => PPIx::Augment::Structure::Subscript::,
		PPI::Token::ArrayIndex::        => PPIx::Augment::Token::ArrayIndex::,
		PPI::Token::Attribute::         => PPIx::Augment::Token::Attribute::,
		PPI::Token::BOM::               => PPIx::Augment::Token::BOM::,
		PPI::Token::Cast::              => PPIx::Augment::Token::Cast::,
		PPI::Token::Comment::           => PPIx::Augment::Token::Comment::,
		PPI::Token::Data::              => PPIx::Augment::Token::Data::,
		PPI::Token::End::               => PPIx::Augment::Token::End::,
		PPI::Token::HereDoc::           => PPIx::Augment::Token::HereDoc::,
		PPI::Token::Label::             => PPIx::Augment::Token::Label::,
		PPI::Token::Magic::             => PPIx::Augment::Token::Magic::,
		PPI::Token::Number::            => PPIx::Augment::Token::Number::,
		PPI::Token::Number::Binary::    => PPIx::Augment::Token::Number::Binary::,
		PPI::Token::Number::Exp::       => PPIx::Augment::Token::Number::Exp::,
		PPI::Token::Number::Float::     => PPIx::Augment::Token::Number::Float::,
		PPI::Token::Number::Hex::       => PPIx::Augment::Token::Number::Hex::,
		PPI::Token::Number::Octal::     => PPIx::Augment::Token::Number::Octal::,
		PPI::Token::Number::Version::   => PPIx::Augment::Token::Number::Version::,
		PPI::Token::Operator::          => PPIx::Augment::Token::Operator::,
		PPI::Token::Pod::               => PPIx::Augment::Token::Pod::,
		PPI::Token::Prototype::         => PPIx::Augment::Token::Prototype::,
		PPI::Token::Quote::Double::     => PPIx::Augment::Token::Quote::Double::,
		PPI::Token::Quote::Interpolate:: => PPIx::Augment::Token::Quote::Interpolate::,
		PPI::Token::Quote::Literal::    => PPIx::Augment::Token::Quote::Literal::,
		PPI::Token::Quote::Single::     => PPIx::Augment::Token::Quote::Single::,
		PPI::Token::QuoteLike::Backtick:: => PPIx::Augment::Token::QuoteLike::Backtick::,
		PPI::Token::QuoteLike::Command:: => PPIx::Augment::Token::QuoteLike::Command::,
		PPI::Token::QuoteLike::Readline:: => PPIx::Augment::Token::QuoteLike::Readline::,
		PPI::Token::QuoteLike::Regexp:: => PPIx::Augment::Token::QuoteLike::Regexp::,
		PPI::Token::QuoteLike::Words::  => PPIx::Augment::Token::QuoteLike::Words::,
		PPI::Token::Regexp::Match::     => PPIx::Augment::Token::Regexp::Match::,
		PPI::Token::Regexp::Substitute:: => PPIx::Augment::Token::Regexp::Substitute::,
		PPI::Token::Regexp::Transliterate:: => PPIx::Augment::Token::Regexp::Transliterate::,
		PPI::Token::Separator::         => PPIx::Augment::Token::Separator::,
		PPI::Token::Structure::         => PPIx::Augment::Token::Structure::,
		PPI::Token::Symbol::            => PPIx::Augment::Token::Symbol::,
		PPI::Token::Unknown::           => PPIx::Augment::Token::Unknown::,
		PPI::Token::Whitespace::        => PPIx::Augment::Token::Whitespace::,
		PPI::Token::Word::              => PPIx::Augment::Token::Word::,
	);

	sub requires {
	}

	sub augment {
		my (undef, $document) = @_;

		ppix_transform $document
			=> where { exists $rebless_map{ ref current } }
			=> invoke { bless $_, $rebless_map{ref current} }
			;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Rebless - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Rebless::augment ($unused, $ppi_document)

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
