
use v5.14;
use warnings;

package PPIx::Augment::No_Element {

	use PPI;

	use overload 'bool' => \ &PPI::Util::FALSE;
	use overload '""'   => \ &content;
	use overload '=='   => \ &PPI::Util::FALSE;
	use overload '!='   => \ &PPI::Util::FALSE;
	use overload 'eq'   => \ &PPI::Util::FALSE;
	use overload 'ne'   => \ &PPI::Util::FALSE;

	sub new {
		bless {}, ref $_[0] || $_[0];
	}

	sub significant         { PPI::Util::FALSE }
	sub class               { goto &PPI::Element::class }
	sub tokens              { }
	sub content             { q () };
	sub parent              { shift->new };
	sub descendant_of       { PPI::Util::FALSE }
	sub ancestor_of         { PPI::Util::FALSE }
	sub statement           { shift->new }
	sub top                 { shift->new }
	sub document            { shift->new }
	sub next_sibling        { shift->new }
	sub snext_sibling       { shift->new }
	sub previous_sibling    { shift->new }
	sub sprevious_sibling   { shift->new }
	sub first_token         { shift->new }
	sub last_token          { shift->new }
	sub elements            { () }
	sub first_element       { shift->new }
	sub last_element        { shift->new }
	sub children            { () }
	sub schildren           { () }
	sub child               { shift->new }
	sub schild              { shift->new }
	sub contains            { PPI::Util::FALSE }
	sub find                { PPI::Util::FALSE }
	sub find_first          { shift->new }
	sub find_any            { PPI::Util::FALSE }
	sub remove_child        { shift->new }
	sub replace_child       { shift->new }
	sub prune               { 0 }

	1;
}

__END__
