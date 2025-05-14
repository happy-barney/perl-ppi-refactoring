
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_ppi_document q (should parse fixture 'multiline-signature.pl')
	=> document => fixture (q (multiline-signature.pl))
	=> expect   => expect_ppi_document (
		expect_ppi_token_whitespace (qq (\n)),
		expect_ppi_statement_package (
			expect_ppi_token_word       (q (package)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_token_word       (q (Foo)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_structure_block (
				expect_ppi_token_whitespace (qq (\n)),
				expect_ppi_token_whitespace (qq (\t)),

				expect_ppi_statement_sub    (
					expect_ppi_token_word       (q (sub)),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_word       (q (foo)),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_prototype  (qq ((\n\t\t\$bar,\n\t\t\$baz\n\t))),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_structure_block (
						expect_ppi_token_whitespace (qq (\n)),
						expect_ppi_token_whitespace (qq (\t)),
					),
				),
				expect_ppi_token_whitespace (qq (\n)),
			),
		),
		expect_ppi_token_whitespace (qq (\n)),
	);

assume_ppi_document q (should parse fixture 'multiple-packages.pl')
	=> document => fixture (q (multiple-packages.pl))
	=> expect   => expect_ppi_document (
		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_statement_package (
			expect_ppi_token_word       (q (package)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_token_word       (q (Foo)),
			expect_ppi_token_structure  (q (;)),
		),

		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_statement         (
			expect_ppi_token_word       (q (foo)),
			expect_ppi_token_structure  (q (;)),
		),

		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_statement_package (
			expect_ppi_token_word       (q (package)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_token_word       (q (Bar)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_structure_block (
				expect_ppi_token_whitespace  (qq (\n)),
				expect_ppi_token_whitespace  (qq (\t)),
				expect_ppi_statement (
					expect_ppi_token_word       (q (bar)),
					expect_ppi_token_structure  (q (;)),
				),

				expect_ppi_token_whitespace  (qq (\n)),
				expect_ppi_token_whitespace  (qq (\n\t)),
				expect_ppi_statement_package (
					expect_ppi_token_word       (q (package)),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_word       (q (Bar::Baz)),
					expect_ppi_token_structure  (q (;)),
				),


				expect_ppi_token_whitespace  (qq (\n)),
				expect_ppi_token_whitespace  (qq (\t)),
				expect_ppi_statement         (
					expect_ppi_token_word       (q (bar_baz)),
					expect_ppi_token_structure  (q (;)),
				),

				expect_ppi_token_whitespace (qq (\n)),
			),
		),
		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_statement         (
			expect_ppi_token_word       (q (foo_foo)),
			expect_ppi_token_structure  (q (;)),
		),

		expect_ppi_token_whitespace  (qq (\n)),
		expect_ppi_token_whitespace  (qq (\n)),
	);

assume_ppi_document q (should parse fixture 'simple-document.pl')
	=> document => fixture (q (simple-document.pl))
	=> expect   => expect_ppi_document (
		expect_ppi_statement (
			expect_ppi_token_number    (q (1)),
			expect_ppi_token_structure (q (;)),
		),
		expect_ppi_token_whitespace (qq (\n)),
	);

assume_ppi_document q (should parse fixture 'ternary-and-heredoc.pl')
	=> document => fixture (q (ternary-and-heredoc.pl))
	=> expect   => expect_ppi_document (
		expect_ppi_token_whitespace (qq (\n)),

		expect_ppi_statement_package (
			expect_ppi_token_word       (q (package)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_token_word       (q (Foo)),
			expect_ppi_token_structure  (q (;)),
		),
		expect_ppi_token_whitespace (qq (\n)),
		expect_ppi_token_whitespace (qq (\n)),

		expect_ppi_statement_sub (
			expect_ppi_token_word       (q (sub)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_token_word       (q (foo)),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_token_prototype  (q (($bar))),
			expect_ppi_token_whitespace (q ( )),
			expect_ppi_structure_block (
				expect_ppi_token_whitespace (qq (\n)),
				expect_ppi_token_whitespace (qq (\t)),
				expect_ppi_statement (
					expect_ppi_token_symbol     (q ($bar)),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_operator   (q (?)),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_heredoc    (), #q (>>'TRUE')), #, { heredoc => qq (true\n) }),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_operator   (q (:)),
					expect_ppi_token_whitespace (q ( )),
					expect_ppi_token_heredoc    (), #q (>>'FALSE')), #, { heredoc => qq (false\n) }),
					expect_ppi_token_structure  (q (;)),
				),
				expect_ppi_token_whitespace (qq (\n)),
			),
		),
		expect_ppi_token_whitespace (qq (\n)),
	);

had_no_warnings;
done_testing;
