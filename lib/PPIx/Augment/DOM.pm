
use v5.14;
use warnings;

package PPIx::Augment::DOM {

	use PPIx::Augment::DOM::No_Element;

	use PPIx::Augment::DOM::Element;
	use PPIx::Augment::DOM::Node;
	use PPIx::Augment::DOM::Statement;
	use PPIx::Augment::DOM::Statement::Break;
	use PPIx::Augment::DOM::Statement::Compound;
	use PPIx::Augment::DOM::Statement::Data;
	use PPIx::Augment::DOM::Statement::End;
	use PPIx::Augment::DOM::Statement::Expression;
	use PPIx::Augment::DOM::Statement::Given;
	use PPIx::Augment::DOM::Statement::Include;
	use PPIx::Augment::DOM::Statement::Include::Perl6;
	use PPIx::Augment::DOM::Statement::Null;
	use PPIx::Augment::DOM::Statement::Package;
	use PPIx::Augment::DOM::Statement::Scheduled;
	use PPIx::Augment::DOM::Statement::Sub;
	use PPIx::Augment::DOM::Statement::Unknown;
	use PPIx::Augment::DOM::Statement::UnmatchedBrace;
	use PPIx::Augment::DOM::Statement::Variable;
	use PPIx::Augment::DOM::Statement::When;
	use PPIx::Augment::DOM::Structure;
	use PPIx::Augment::DOM::Structure::Block;
	use PPIx::Augment::DOM::Structure::Condition;
	use PPIx::Augment::DOM::Structure::Constructor;
	use PPIx::Augment::DOM::Structure::For;
	use PPIx::Augment::DOM::Structure::Given;
	use PPIx::Augment::DOM::Structure::List;
	use PPIx::Augment::DOM::Structure::Subscript;
	use PPIx::Augment::DOM::Structure::Unknown;
	use PPIx::Augment::DOM::Structure::When;
	use PPIx::Augment::DOM::Token;
	use PPIx::Augment::DOM::Token::ArrayIndex;
	use PPIx::Augment::DOM::Token::Attribute;
	use PPIx::Augment::DOM::Token::BOM;
	use PPIx::Augment::DOM::Token::Cast;
	use PPIx::Augment::DOM::Token::Comment;
	use PPIx::Augment::DOM::Token::DashedWord;
	use PPIx::Augment::DOM::Token::Data;
	use PPIx::Augment::DOM::Token::End;
	use PPIx::Augment::DOM::Token::HereDoc;
	use PPIx::Augment::DOM::Token::Label;
	use PPIx::Augment::DOM::Token::Magic;
	use PPIx::Augment::DOM::Token::Number;
	use PPIx::Augment::DOM::Token::Number::Binary;
	use PPIx::Augment::DOM::Token::Number::Exp;
	use PPIx::Augment::DOM::Token::Number::Float;
	use PPIx::Augment::DOM::Token::Number::Hex;
	use PPIx::Augment::DOM::Token::Number::Octal;
	use PPIx::Augment::DOM::Token::Number::Version;
	use PPIx::Augment::DOM::Token::Operator;
	use PPIx::Augment::DOM::Token::Pod;
	use PPIx::Augment::DOM::Token::Prototype;
	use PPIx::Augment::DOM::Token::Quote;
	use PPIx::Augment::DOM::Token::Quote::Double;
	use PPIx::Augment::DOM::Token::Quote::Interpolate;
	use PPIx::Augment::DOM::Token::Quote::Literal;
	use PPIx::Augment::DOM::Token::Quote::Single;
	use PPIx::Augment::DOM::Token::QuoteLike;
	use PPIx::Augment::DOM::Token::QuoteLike::Backtick;
	use PPIx::Augment::DOM::Token::QuoteLike::Command;
	use PPIx::Augment::DOM::Token::QuoteLike::Readline;
	use PPIx::Augment::DOM::Token::QuoteLike::Regexp;
	use PPIx::Augment::DOM::Token::QuoteLike::Words;
	use PPIx::Augment::DOM::Token::Regexp;
	use PPIx::Augment::DOM::Token::Regexp::Match;
	use PPIx::Augment::DOM::Token::Regexp::Substitute;
	use PPIx::Augment::DOM::Token::Regexp::Transliterate;
	use PPIx::Augment::DOM::Token::Separator;
	use PPIx::Augment::DOM::Token::Structure;
	use PPIx::Augment::DOM::Token::Symbol;
	use PPIx::Augment::DOM::Token::Unknown;
	use PPIx::Augment::DOM::Token::Whitespace;
	use PPIx::Augment::DOM::Token::Word;

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM

=head1 DESCRIPTION

L<PPIx::Augment> uses a DOM structure inspired by L<PPI> and extended
to better suit to static analysis and automated refactoring.

Further documentation assumes you are familiar with L<PPI>, so it references
it as a point of reference of fact without need for further explanation.

=head1 CONCEPTS

=head2 No Element

A value implementing all element/node methods, evaluated as false in boolean context.

Many L<PPI> accessor methods return a blessed value when a value exists,
or an empty string otherwise, requiring to use patterns like:

    while ($element->parent && $element->parent->snext_sibling) {
    }

By returning a C<No Element> value, one can simplify this:

    while ($element->parent->snext_sibling) {
    }

for both C<parent> and C<snext_sibling> returning blessed-but-false C<No Element> value.

=head2 Identity

    my $augmentation_class = PPIX_ELEMENT_SUBCLASS->identify ($element)

Augmented DOM classes provide a method to identify whether a given C<$element> is
either a head element representing code structure or an already augmented element.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
