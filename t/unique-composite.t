use Test::More;
use lib 't/lib';

use_ok( 'BookDB::Form::Book');

use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $duplicate = $schema->resultset('Book')->find(1);

my $form = BookDB::Form::Book->new(item_id => undef, schema => $schema, unique_messages => { foo => 'a unique constraint error message'} );

ok( !$form->process, 'Empty data' );

# This is munging up the equivalent of param data from a form
my $params = {
    'title' => $duplicate->title,
    'author' => $duplicate->author,
    'isbn'   => 'This is a unique value',
    'publisher' => $duplicate->publisher
};

ok( !$form->process( $params ), 'duplicate author/title fails validation' );

my $error = $form->field('author')->errors->[0];

is( $error, 'Duplicate value for author_title unique constraint', 'error message for duplicate unique constraint value');

is($form->unique_message_for_constraint('author_title'), $error, 'unique constraint message saved');
is($form->unique_message_for_constraint('foo'), 'a unique constraint error message', 'unique constraint accepted in constructor');
done_testing;
