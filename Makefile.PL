use strict;
use warnings;
use inc::Module::Install 0.89;

BEGIN {
    if ($Module::Install::AUTHOR) { # Not strictly needed, but reminds idiots like
                                    # me what M::I extensions I need ;)
        require Module::Install::AuthorRequires;
        require Module::Install::AuthorTests;
    }
}

name 'HTML-FormHandler-Model-DBIC';
author 'Gerda Shank';
all_from 'lib/HTML/FormHandler/Model/DBIC.pm';
license 'perl';

repository 'http://github.com/gshank/html-formhandler-model-dbic/tree/master';

# prereqs
requires 'HTML::FormHandler' => '0.27';
requires 'DBIx::Class';
requires 'DBIx::Class::ResultSet::RecursiveUpdate' => '0.010';

# things the tests need
test_requires 'Test::More'      => '0.88';
test_requires 'DateTime::Format::MySQL';
test_requires 'DateTime::Format::W3CDTF' => 0;
test_requires 'DateTime::Format::SQLite';

tests();
author_tests('t/xt');

install_script 'form_generator.pl';
auto_install();

WriteAll();

