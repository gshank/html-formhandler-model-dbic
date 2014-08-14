use Test::More;
use lib 't/lib';

use_ok( 'BookDB::Form::Book');
use_ok( 'BookDB::Schema');

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $bad = {
    'title' => "Another Silly Test Book",
    'year' => '1590',
    'pages' => '101',
};

my $book = $schema->resultset('Book')->create( $bad );
END { $book->delete }

my $form = BookDB::Form::Book->new( item => $book );

ok( !$form->db_validate, 'Bad db data doesn\'t validate' );

$bad->{year} = 1999;
my $validated = $form->process( $bad );
ok( $validated, 'now form validates' );

$form->update_model;
$book = $form->item;
is( $book->year, 1999, 'book has been updated with correct data' );

done_testing;
