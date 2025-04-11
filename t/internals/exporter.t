
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

require PPIx::Augment::Internals::Exporter;

note <<'';
	PPIx::Augment::Internals::Exporter's attributes simplifies declaration
	of what is exported and what is not

subtest q (when importing PPIx::Augment::Internals::Exporter) => sub {
	package Testing::Exporter::Use {
		use PPIx::Augment::Internals::Exporter;

		sub foo                         :Exported(tag1,tag2);
		sub bar                         :Exportable(tag1);
		sub baz                         :Exportable;
	}

	it q (should populate @ISA variable)
		=> got    => \ @Testing::Exporter::Use::ISA
		=> expect => [
			PPIx::Augment::Internals::Exporter::,
		];

	it q (should populate @EXPORT variable)
		=> got    => \ @Testing::Exporter::Use::EXPORT
		=> expect => [
			q (foo),
		];

	it q (should populate @EXPORT_OK variable)
		=> got    => \ @Testing::Exporter::Use::EXPORT_OK
		=> expect => [
			q (foo),
			q (bar),
			q (baz),
		];

	it q (should populate %EXPORT_TAGS variable)
		=> got    => \ %Testing::Exporter::Use::EXPORT_TAGS
		=> expect => {
			tag1    => [qw [foo bar]],
			tag2    => [qw [foo]],
			default => [qw [foo]],
			all     => [qw[ foo bar baz]],
		};
};

subtest q (when extending PPIx::Augment::Internals::Exporter) => sub {
	package Testing::Exporter::Extend {
		BEGIN { our @ISA = qw (PPIx::Augment::Internals::Exporter); }

		sub foo                         :Exported(tag1,tag2);
		sub bar                         :Exportable(tag1);
		sub baz                         :Exportable;
	}

	it q (shouldn't modify @ISA variable)
		=> got    => \ @Testing::Exporter::Extend::ISA
		=> expect => [
			PPIx::Augment::Internals::Exporter::,
		];

	it q (should populate @EXPORT variable)
		=> got    => \ @Testing::Exporter::Extend::EXPORT
		=> expect => [
			q (foo),
		];

	it q (should populate @EXPORT_OK variable)
		=> got    => \ @Testing::Exporter::Extend::EXPORT_OK
		=> expect => [
			q (foo),
			q (bar),
			q (baz),
		];

	it q (should populate %EXPORT_TAGS variable)
		=> got    => \ %Testing::Exporter::Extend::EXPORT_TAGS
		=> expect => {
			tag1    => [qw [foo bar]],
			tag2    => [qw [foo]],
			default => [qw [foo]],
			all     => [qw[ foo bar baz]],
		};
};

had_no_warnings;
done_testing;

