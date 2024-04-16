
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw (:no_end_test had_no_warnings);

use_ok q (PPIx::Augment);
use_ok q (PPIx::Augment::Augmentation);
use_ok q (PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces);
use_ok q (PPIx::Augment::Document);
use_ok q (PPIx::Augment::No_Element);
use_ok q (PPIx::Augment::Utils);
use_ok q (PPIx::Augment::Utils::Exporter);

had_no_warnings;
done_testing;
