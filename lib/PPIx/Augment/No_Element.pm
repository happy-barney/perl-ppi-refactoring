
use v5.14;
use warnings;

package PPIx::Augment::No_Element {

	use PPI;

	use overload q (bool) => \ &PPI::Util::FALSE;
	use overload q ("")   => \ &content;
	use overload q (==)   => \ &PPI::Util::FALSE;
	use overload q (!=)   => \ &PPI::Util::FALSE;
	use overload q (eq)   => \ &PPI::Util::FALSE;
	use overload q (ne)   => \ &PPI::Util::FALSE;

	sub new {
		bless {}, ref $_[0] || $_[0];
	}

	sub ancestor_of         { PPI::Util::FALSE }
	sub child               { shift->new }
	sub children            { () }
	sub class               { goto &PPI::Element::class }
	sub contains            { PPI::Util::FALSE }
	sub content             { q () }
	sub descendant_of       { PPI::Util::FALSE }
	sub document            { shift->new }
	sub elements            { () }
	sub find                { PPI::Util::FALSE }
	sub find_any            { PPI::Util::FALSE }
	sub find_first          { shift->new }
	sub first_element       { shift->new }
	sub first_token         { shift->new }
	sub last_element        { shift->new }
	sub last_token          { shift->new }
	sub next_sibling        { shift->new }
	sub parent              { shift->new }
	sub previous_sibling    { shift->new }
	sub prune               { 0 }
	sub remove_child        { shift->new }
	sub replace_child       { shift->new }
	sub schild              { shift->new }
	sub schildren           { () }
	sub set_content         { shift->new }
	sub significant         { PPI::Util::FALSE }
	sub snext_sibling       { shift->new }
	sub sprevious_sibling   { shift->new }
	sub statement           { shift->new }
	sub tokens              { };;
	sub top                 { shift->new }

	1;
}

__END__
