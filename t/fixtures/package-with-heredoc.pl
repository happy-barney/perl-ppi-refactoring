
package Foo;

heredoc <<'END';
	Heredoc here
END

package Bar {
	heredoc <<'END';
	Heredoc here
END

}

package Baz {
	package Baz::Baz;

	heredoc <<'END';
	Heredoc here
END
}
