
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { fixture q (accessor-for-children.pl) };

assume_ppi q (expected PPI structure of fixture document)
	=> expect   => expect_document (
		expect_token_comment (qq (# leading comment\n)),

		expect_statement_null (
			expect_token_semicolon,
		),
		expect_token_newline,

		expect_statement (
			expect_structure_list (
				expect_token_whitespace (q ( )),
				expect_statement_expression (
					expect_token_number     (q (1)),
					expect_token_operator   (q (,)),
					expect_token_whitespace (q (  )),
					expect_token_number     (q (2)),
				),
				expect_token_whitespace (q (   )),
			),
			expect_token_semicolon,
		),
		expect_token_newline,

		expect_statement (
			expect_token_number     (q (3)),
			expect_token_semicolon,
		),
		expect_token_newline,

		expect_token_comment (qq (# trailing comment\n)),
	);

had_no_warnings;
done_testing;
