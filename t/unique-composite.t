use Test::More;
use lib 't/lib';

use_ok( 'BookDB::Form::AuthorOld');

use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $duplicate = $schema->resultset('AuthorOld')->first;

my $form = BookDB::Form::AuthorOld->new(item_id => undef, schema => $schema, unique_messages => { foo => 'a unique constraint error message'} );

ok( !$form->process, 'Empty data' );

# This is munging up the equivalent of param data from a form
my $params = {
    'first_name' => "Jane", 
    'last_name' => "Doe", 
    'foo'   => $duplicate->foo, 
    'bar' => $duplicate->bar, 
};

ok( !$form->process( $params ), 'duplicate foo/bar fails validation' );

my $error = $form->field('foo')->errors->[0];

is( $error, 'Duplicate value for author_foo_bar unique constraint', 'error message for duplicate unique index');

is($form->unique_message_for_constraint('author_foo_bar'), 'Duplicate value for [_1] unique constraint', 'unique constraint message saved');
is($form->unique_message_for_constraint('foo'), 'a unique constraint error message', 'unique constraint accepted in constructor');
done_testing;
