use Test::More;
use lib 't/lib';

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::AuthorOld');

use_ok( 'BookDB::Schema');

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $pk = ['J.K.', 'Rowling'];
my $authors = $schema->resultset('AuthorOld');
my $author = $schema->resultset('AuthorOld')->find( @{$pk} );
ok( $author, 'get author from db' );
is( $author->country_iso, 'GB', 'correct value in author');

my $form = BookDB::Form::AuthorOld->new(item_id => $pk, schema => $schema);
ok( $form, 'get form with multiple primary key' );
is( $form->item->country_iso, 'GB', 'got right row');

my $pk_hashref = { last_name => 'Rowling', first_name => 'J.K.' };
$author = $schema->resultset('AuthorOld')->find( $pk_hashref );
ok( $author, 'get author from db with hashref');

$form = BookDB::Form::AuthorOld->new(item_id => $pk_hashref, schema => $schema);
ok( $form, 'get form with array of hashref primary key' );
is( $form->item->country_iso, 'GB', 'got right row');

my $pk_hashlist = [{ last_name => 'Rowling', first_name => 'J.K.' },
                   { key => 'primary' }];
$author = $schema->resultset('AuthorOld')->find( @{$pk_hashlist} );
ok( $author, 'get author from db with hashref');

$form = BookDB::Form::AuthorOld->new(item_id => $pk_hashlist, schema => $schema);
ok( $form, 'get form with array of hashref primary key' );
is( $form->item->country_iso, 'GB', 'got right row');

$form = BookDB::Form::AuthorOld->new( item => $author );
ok( $form, 'got form with only item passed in' );
is_deeply( $form->item_id, $pk_hashlist, 'got primary key' );

done_testing;
