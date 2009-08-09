use strict;
use warnings;
use Test::More;
use lib 't/lib';

BEGIN {
   eval "use Template";
   plan skip_all => 'Template' if $@;
}

use_ok( 'HTML::FormHandler::Generator::DBIC' );

use_ok( 'BookDB::Schema');

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $generator = HTML::FormHandler::Generator::DBIC->new( schema => $schema, rs_name => 'User' );
ok( $generator, 'Generator created' );

my $form_code = $generator->generate_form();

ok( $form_code, 'form code generated' );
#warn $form_code;
eval $form_code;
ok( !$@, 'Form code compiles' ) or warn $@;
ok( UserForm->new, 'Form creation works' );

done_testing;
