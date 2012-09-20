use Test::More;
use lib 't/lib';

use_ok( 'BookDB::Form::Book');

use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $duplicate_isbn = $schema->resultset('Book')->find(1)->isbn;

my $form = BookDB::Form::Book->new(item_id => undef, schema => $schema);

ok( !$form->process, 'Empty data' );

# This is munging up the equivalent of param data from a form
my $params = {
    'title' => 'How to Test Perl Form Processors',
    'author' => 'I.M. Author',
    'isbn'   => $duplicate_isbn,
    'publisher' => 'EreWhon Publishing',
};

ok( !$form->process( $params ), 'duplicate isbn fails validation' );

my $error = $form->field('isbn')->errors->[0];

is( $error, 'Duplicate value for ISBN', 'error message for duplicate');

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has '+item_class' => ( default => 'Book' );

   sub field_list {
        [
            title     => {
               type => 'Text',
               required => 1,
            },
            author    => 'Text',
            isbn => {
               type => 'Text',
               unique => 1,
               unique_message => 'Duplicate ISBN number',
            }
        ]
   }
}

my $form2 = My::Form->new( item_id => undef, schema => $schema );

ok( ! $form2->process( $params ), 'duplicate isbn again' );

@errors = $form2->field('isbn')->all_errors;

is( $errors[0], 'Duplicate ISBN number', 'field error message for duplicate');

# Tests for fields that are inactive
my $item = $schema->resultset('Book')->new({});
ok ( $form->process( item => $item, params => $params, inactive => ['isbn'] ),
    'no uniqueness check on inactive fields' );
$item->delete if $item->in_storage; # Cleanup insert

done_testing;
