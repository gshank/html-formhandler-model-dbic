use strict;
use warnings;
use Test::More;
use Data::Dumper;

use lib 't/lib';
use BookDB::Schema;
use_ok('BookDB::Form::Author');
my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');
my $author = $schema->resultset('Author')->find(1);

my $form = BookDB::Form::Author->new;

ok( $form, 'form built' );

$form->process( item => $author, params => {});

my @options = $form->field('books.0.genres')->options;
is(scalar @options, 6, 'got right number of genre options' );

my $fif = $form->fif;
diag( Dumper($fif) );


done_testing;
