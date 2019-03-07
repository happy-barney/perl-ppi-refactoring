
use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::Warnings;

use PPI::Dumper;
use HPB::PPIx::Refactoring;

sub expect_lookup {
	my ($title, %params) = @_;

	my $snippet = PPI::Document->new (\ $params{snippet});

	my @got = HPB::PPIx::Utils::ppix_find ($snippet, $params{lookup});
	my @expect = map { ref $_ ? $_ : methods (content => $_) } @{ $params{expect} };

	cmp_deeply
		\ @got,
		\ @expect,
		$title
		or do {
			PPI::Dumper->new ($snippet)->print
		}
}

sub expect_invoke {
	my ($title, %params) = @_;

	my $snippet = PPI::Document->new (\ $params{snippet});

	HPB::PPIx::Utils::ppix_invoke (
		element => $snippet,
		where   => $params{lookup},
		invoke  => $params{invoke},
	);

	is
		$snippet->serialize,
		$params{expect},
		$title
		;
}

sub expect_transformation {
	my ($title, %params) = @_;

	my $snippet = PPI::Document->new (\ $params{snippet});
	$params{transformation}->($snippet, $params{argument});

	is
		$snippet->serialize,
		$params{expect},
		$title
		;
}

expect_lookup "lookup_function_call without name should find all function calls" => (
	lookup => lookup_function_call,
	snippet => <<'SNIPPET',

		$uri = $self->Tools::ChangeId::idToProfileUri( $uid );
		$uri = Tools::ChangeId::idToProfileUri( $uid );
		$uri = Tools::ChangeId::idToProfile( $uid );
SNIPPET
	expect => [
		methods (
			content => 'Tools::ChangeId::idToProfileUri',
			line_number => 3,
		),
		methods (
			content => 'Tools::ChangeId::idToProfile',
			line_number => 4,
		),
	],
);

expect_lookup "lookup_function_call with name should find fully qualified token" => (
	lookup => lookup_function_call ('Tools::ChangeId::idToProfileUri'),
	snippet => <<'SNIPPET',

		$uri = $self->Tools::ChangeId::idToProfileUri( $uid );
		$uri = Tools::ChangeId::idToProfileUri( $uid );
		$uri = Tools::ChangeId::idToProfile( $uid );
SNIPPET
	expect => [
		'Tools::ChangeId::idToProfileUri'
	],
);

expect_invoke "invoke_replace_with_uri_for should replace idtoprofileuri" => (
	lookup => lookup_function_call ('Tools::ChangeId::idToProfileUri'),
	invoke => invoke_replace_with_uri_for ('uri_for_account_profile', 'profile_id'),

	snippet => <<'SNIPPET',

	Tools::ChangeId::idToProfileUri($userUID);
	Tools::ChangeId::idToProfileUri($varitem->{user});
	Tools::ChangeId::idToProfileUri( $grantee_id );
SNIPPET
	expect => <<'EXPECT',

	$self->uri_for_account_profile( profile_id => $userUID );
	$self->uri_for_account_profile( profile_id => $varitem->{user} );
	$self->uri_for_account_profile( profile_id => $grantee_id );
EXPECT
);

expect_transformation "eliminate lazy builder as lonely parameter" => (
	transformation => \& eliminate_property_as_argument,
	argument => 'c3',
	snippet => <<'SNIPPET',

		$self->_about ($self->c3);

		sub _about {
			my ($self, $C3) = @_;
		}
SNIPPET
	expect => <<'EXPECT',

		$self->_about;

		sub _about {
			my ($self) = @_;
			my $C3 = $self->c3;
		}
EXPECT
);

expect_transformation "eliminate lazy builder as first parameter" => (
	transformation => \& eliminate_property_as_argument,
	argument => 'c3',
	snippet => <<'SNIPPET',

		$self->_about ($self->c3, $self->current_user_uid);

		sub _about {
			my ($self, $C3, $user_id) = @_;
		}
SNIPPET
	expect => <<'EXPECT',

		$self->_about ($self->current_user_uid);

		sub _about {
			my ($self, $user_id) = @_;
			my $C3 = $self->c3;
		}
EXPECT
);

expect_transformation "eliminate lazy builder as second parameter" => (
	transformation => \& eliminate_property_as_argument,
	argument => 'c3',
	snippet => <<'SNIPPET',

		$self->_check_user_is_enabled_in_project( $project_id, $self->c3 );

		sub _check_user_is_enabled_in_project {
			my ($self, $project_id, $C3) = @_;
		}
SNIPPET
	expect => <<'EXPECT',

		$self->_check_user_is_enabled_in_project( $project_id );

		sub _check_user_is_enabled_in_project {
			my ($self, $project_id) = @_;
			my $C3 = $self->c3;
		}
EXPECT
);

expect_transformation "eliminate lazy builder with additional spaces" => (
	transformation => \& eliminate_property_as_argument,
	argument => 'c3',
	snippet => <<'SNIPPET',

		$self->_check_user_is_enabled_in_project( $project_id, $self->c3 );

		sub _check_user_is_enabled_in_project {
			my ( $self, $project_id, $C3 ) = @_;
		}
SNIPPET
	expect => <<'EXPECT',

		$self->_check_user_is_enabled_in_project( $project_id );

		sub _check_user_is_enabled_in_project {
			my ( $self, $project_id ) = @_;
			my $C3 = $self->c3;
		}
EXPECT
);

expect_transformation "eliminate property variables" => (
	transformation => \& eliminate_property_variables,
	argument => 'c3',
	snippet => <<'SNIPPET',

		$C3->foo;

		sub _check_user_is_enabled_in_project {
			my $C3 = $self->c3;
			my $C3user = $self->c3->user;

			$C3->foo ($C3->bar, $C3user);
		}
SNIPPET
	expect => <<'EXPECT',

		$C3->foo;

		sub _check_user_is_enabled_in_project {
			my $C3user = $self->c3->user;

			$self->c3->foo ($self->c3->bar, $C3user);
		}
EXPECT
);

done_testing;

__END__

expect_transformation "eliminate lazy builder with method call" => (
	transformation => \& eliminate_property_as_argument,
	argument => 'c3',
	snippet => <<'SNIPPET',
$self->about ($self->c3->user, $self->current_user_uid);

sub _about {
	my ($self, $C3, $user_id) = @_;
}
SNIPPET
	expect => <<'EXPECT',
$self->about ($self->c3);

sub _about {
	my ($self, $C3) = @_;
	my $C3 = $self->c3->user;
}
EXPECT
);

done_testing;

__END__

Snippets to test

=head1

$self->about ($self->foo, $self->c3);
sub about {
	my ($self, $foo, $c3) = @_;
}
