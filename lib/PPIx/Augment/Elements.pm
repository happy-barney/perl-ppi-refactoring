
use v5.14;
use warnings;

package PPIx::Augment::Elements {

	# PPI elements counterparts
	use PPIx::Augment::Node;
	use PPIx::Augment::Document;
	use PPIx::Augment::Element;
	use PPIx::Augment::Statement;
	use PPIx::Augment::Statement::Expression;
	use PPIx::Augment::Statement::Break;
	use PPIx::Augment::Statement::Compound;
	use PPIx::Augment::Statement::Data;
	use PPIx::Augment::Statement::End;
	use PPIx::Augment::Statement::Expression;
	use PPIx::Augment::Statement::Given;
	use PPIx::Augment::Statement::Include;
	use PPIx::Augment::Statement::Null;
	use PPIx::Augment::Statement::Package;
	use PPIx::Augment::Statement::Scheduled;
	use PPIx::Augment::Statement::Sub;
	use PPIx::Augment::Statement::Variable;
	use PPIx::Augment::Statement::When;
	use PPIx::Augment::Structure;
	use PPIx::Augment::Structure::Block;
	use PPIx::Augment::Structure::Condition;
	use PPIx::Augment::Structure::Constructor;
	use PPIx::Augment::Structure::For;
	use PPIx::Augment::Structure::Given;
	use PPIx::Augment::Structure::List;
	use PPIx::Augment::Structure::Subscript;
	use PPIx::Augment::Structure::Unknown;
	use PPIx::Augment::Structure::When;
	use PPIx::Augment::Token;
	use PPIx::Augment::Token::ArrayIndex;
	use PPIx::Augment::Token::Attribute;
	use PPIx::Augment::Token::BOM;
	use PPIx::Augment::Token::Cast;
	use PPIx::Augment::Token::Comment;
	use PPIx::Augment::Token::Data;
	use PPIx::Augment::Token::End;
	use PPIx::Augment::Token::HereDoc;
	use PPIx::Augment::Token::Label;
	use PPIx::Augment::Token::Magic;
	use PPIx::Augment::Token::Number::Binary;
	use PPIx::Augment::Token::Number::Exp;
	use PPIx::Augment::Token::Number::Float;
	use PPIx::Augment::Token::Number::Hex;
	use PPIx::Augment::Token::Number::Octal;
	use PPIx::Augment::Token::Number::Version;
	use PPIx::Augment::Token::Number;
	use PPIx::Augment::Token::Operator;
	use PPIx::Augment::Token::Pod;
	use PPIx::Augment::Token::Prototype;
	use PPIx::Augment::Token::Quote::Double;
	use PPIx::Augment::Token::Quote::Interpolate;
	use PPIx::Augment::Token::Quote::Literal;
	use PPIx::Augment::Token::Quote::Single;
	use PPIx::Augment::Token::QuoteLike::Backtick;
	use PPIx::Augment::Token::QuoteLike::Command;
	use PPIx::Augment::Token::QuoteLike::Readline;
	use PPIx::Augment::Token::QuoteLike::Regexp;
	use PPIx::Augment::Token::QuoteLike::Words;
	use PPIx::Augment::Token::Regexp::Match;
	use PPIx::Augment::Token::Regexp::Substitute;
	use PPIx::Augment::Token::Regexp::Transliterate;
	use PPIx::Augment::Token::Separator;
	use PPIx::Augment::Token::Structure;
	use PPIx::Augment::Token::Symbol;
	use PPIx::Augment::Token::Unknown;
	use PPIx::Augment::Token::Whitespace;
	use PPIx::Augment::Token::Word;

	# PPIx::Augment elements
	use PPIx::Augment::Context::Package;
	use PPIx::Augment::Expression;
	use PPIx::Augment::Expression::Invocant;
	use PPIx::Augment::Expression::Invoked_Method;
	use PPIx::Augment::Expression::Lhs;
	use PPIx::Augment::Expression::Rhs;
	use PPIx::Augment::Expression::Term;
	use PPIx::Augment::Expression::Term::Anonymous::Arrayref;
	use PPIx::Augment::Expression::Term::Anonymous::Coderef;
	use PPIx::Augment::Expression::Term::Anonymous::Hashref;
	use PPIx::Augment::Expression::Term::Dereference;
	use PPIx::Augment::Expression::Term::Do::Block;
	use PPIx::Augment::Expression::Term::Literal;
	use PPIx::Augment::Expression::Term::Variable;
	use PPIx::Augment::Structure::Arguments;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Elements - transitional package importing all augmented elements

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

