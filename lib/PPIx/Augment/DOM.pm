
use v5.14;
use warnings;

package PPIx::Augment::DOM {

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM - PPIx::Augment document model

=head1 CONCEPTS

=head2 Build

Every L<PPIx::Augment> document model class provides method C<Build> to build
its own instance with context, hiding boring details of complex construction.

Example:

    PPIx::Augment::DOM::Structure::Block::->Build (
        ... child 0,
        ... child 1,
        ...
    );

Method may return instance of its child:

    # This will return PPIx::Augment::DOM::Statement::Package::V514
    PPIx::Augment::DOM::Statement::Package::->Build (
        namespace => q (Foo),
        block     => ... build block,
    );

=head2 Identify And Classify

Every L<PPIx::Augment> document model class provides (or configures) methods
to identify element (of L<PPI> or L<PPIx::Augment> model) as an element
representing given class.

Related methods:

=over

=item L<Identify|PPIx::Augment::DOM::Element/Identify>

=item L<Identify_Span|PPIx::Augment::DOM::Element/Identify_Span>

=item L<Classify|PPIx::Augment::DOM::Element/Classify>

=item L<classify|PPIx::Augment::DOM::Element/classify>

=item L<ppi_class|PPIx::Augment::DOM::Element/ppi_class>

=back

=head2 PPI Compatibility

L<PPIx::Augment> document model is based on the L<PPI> model but provides
finer resolution.

With L<PPIx::Augment> document model one can:

=over

=item address interpolated code

=item address whitespaces in qw ( )

=item address parts of regular expressions

=item address structure of POD documentation

=back

Related methods:

=over

=item L<Augment|PPIx::Augment::DOM::Element/Augment>

=item L<augment|PPIx::Augment::DOM::Element/augment>

=item L<diminish|PPIx::Augment::DOM::Element/diminish>

=back

=head2 Perl Version

Every change in syntax is reflected in class structure, for example there are classes:

=over

=item L<PPIx::Augment::DOM::Statement::Package::Traditional>

For L<PPIx::Augment> recognized Perl's history starts at v5.10, everything specified
before is named C<Traditional>.

=item L<PPIx::Augment::DOM::Statement::Package::V512>

=item L<PPIx::Augment::DOM::Statement::Package::V514>

=item L<PPIx::Augment::DOM::Token::Number::Octal::Traditional>

=item L<PPIx::Augment::DOM::Token::Number::Octal::V534>

=back

Related methods:

=over

=item L<since_perl|PPIx::Augment::DOM::Element/since_perl>

=item L<until_perl|PPIx::Augment::DOM::Element/until_perl>

=item L<is_available_for|PPIx::Augment::DOM::Element/is_available_for>

=item L<downgrade|PPIx::Augment::DOM::Element/downgrade>

=item L<downgrade_to|PPIx::Augment::DOM::Element/downgrade_to>

=item L<Upgrade|PPIx::Augment::DOM::Element/Upgrade>

=back

=head2 Scope classes

Scope classes transform horizontal relations into vertical.

Scope objects are invisible for methods working with children and elements
so they will not break L<PPI> document structure.

For example:

=over

=item L<PPIx::Augment::DOM::Scope::Namespace>

=item L<PPIx::Augment::DOM::Scope::Variable>

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut

