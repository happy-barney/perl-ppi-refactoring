
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw (:no_end_test had_no_warnings);

use_ok q (PPIx::Augment);
use_ok q (PPIx::Augment::Augmentation);
use_ok q (PPIx::Augment::Augmentation::PPI::Comment);
use_ok q (PPIx::Augment::Augmentation::PPI::Defined_Or_Regex);
use_ok q (PPIx::Augment::Augmentation::PPI::Magic_Cast);
use_ok q (PPIx::Augment::Augmentation::PPI::Newline_Spaces);
use_ok q (PPIx::Augment::DOM::Element);
use_ok q (PPIx::Augment::DOM::No_Element);
use_ok q (PPIx::Augment::Declare::Augmentation);
use_ok q (PPIx::Augment::Document);
use_ok q (PPIx::Augment::Internals);
use_ok q (PPIx::Augment::Internals::Exporter);
use_ok q (PPIx::Augment::Utils);
use_ok q (PPIx::Augment::Utils);

had_no_warnings;
done_testing;
