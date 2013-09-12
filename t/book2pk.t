use strict;
use warnings;
use Test::More;
use Test::Exception;
use lib 't/lib';


use_ok( 'BookDB::Form::Book2PK');

use_ok( 'BookDB::Schema');

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');

my $book = $schema->resultset('Book2PK')->find( { libraryid => 1, id => 1 }, { key => 'primary' });
my $form = BookDB::Form::Book2PK->new;
ok( $form );

$form->process( item => $book, params => {} );
my $params = $form->fif;
my $orig_pages = $params->{pages};
$params->{pages} = 500;
lives_ok( sub { $form->process( item => $book, params => $params ) }, 'multiple pk works' );
$book->discard_changes;
is( $book->pages, 500, 'pages changed' );

$params->{pages} = $orig_pages;
$form->process( item => $book, params => $params );


done_testing;
