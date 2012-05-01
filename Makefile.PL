use strict;
use warnings;
use inc::Module::Install;

author   'Vladimir Timofeev <vovkasm@gmail.com>';
license  'perl';
all_from 'lib/LibEvent.pm';

test_requires 'Test::More' => 0.88;

use_xshelper;
cc_warnings;

cc_include_paths qw(include);
cc_src_paths qw(src);
cc_libs qw(event);

WriteAll;
