use strict;
use warnings;
use Test::More;
use lib 't/lib';

use_ok('HTML::FormHandler::Model::DBIC');
use_ok('HTML::FormHandler::TraitFor::DBICFields');
use_ok('HTML::FormHandler::Model::DBIC::TypeMap');

use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');

ok($schema, 'get schema');

my $book = $schema->resultset('Book')->find(1);
my $form = HTML::FormHandler::Model::DBIC->new_with_traits(
   traits => ['HTML::FormHandler::TraitFor::DBICFields'],
   field_list => [ 'submit' => { type => 'Submit', value => 'Save', order => 99 } ],
   item => $book );
ok( $form, 'get form');
ok( $form->can('build_type_map'), 'trait applied' );
is( $form->num_fields, 11, 'right number of fields' );

my $title_field = $form->field('title');
ok( $title_field, 'title field exists');
my $publisher_field = $form->field('publisher');
ok( $publisher_field, 'author field exists');

ok( $title_field->value eq 'Harry Potter and the Order of the Phoenix', 'get title from form');
is( $title_field->temp, 'testing', 'got field def from extra' );

$form = HTML::FormHandler::Model::DBIC->new_with_traits(
    traits => ['HTML::FormHandler::TraitFor::DBICFields'],
    includes => ['title', 'publisher' ],
    field_list => [ 'submit' => { type => 'Submit', value => 'Save', order => 99 } ],
    item => $book );
ok( $form, 'get form' );
is( $form->num_fields, 3, 'right number of fields' );

done_testing;
