use strict;
use warnings;
use Test::More;
use lib 't/lib';
 
use_ok( 'HTML::FormHandler' );
use_ok( 'BookDB::Form::Book' );
use_ok( 'BookDB::Schema' );
my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok( $schema, 'get db schema' );
 
# Empty form loaded for user to populate, with format options listed
my $form1 = page_request( {} );
ok( !$form1->validated, 'not validated because it is a new empty form' );
 
my $form2 = page_request( { format => '' } );
ok( !$form2->validated, 'submitted, but with errors' );
 
my $params = {
    title     => 'The Definitive Guide to Catalyst',
    author    => 'Kieren; Trout, Matt Diment',
    genres    => [6,2],
    isbn      => 1430223650,
    publisher => 'APRESS',
    format    => '',
    year      => 2009,
    pages     => 360,
    comment   => '',
};
 
# Valid submission, without a format set.
my $form3 = page_request( $params );
ok( $form3->validated, 'no format - submitted and valid' );
 
# Check the book was stored, which isn't really essential for this test.
# And delete it, so that we can re-insert it in the next step.
my $rs = $schema->resultset('Book');
my @matches = $rs->search( { isbn => $params->{isbn} } )->all;
is( @matches, 1, 'Found the submitted book in the db' );
$_->delete for @matches;
@matches = $rs->search( { isbn => $params->{isbn} } )->all;
is( @matches, 0, 'Deleted book from the db' );
 
# Valid submission, with a format set.
$params->{format} = 1;
my $form4 = page_request( $params );
ok( $form4->validated, 'format = 1, submitted and valid' );

$form4->item->delete;
 
sub page_request {
    my $params = shift;
 
    my $form = BookDB::Form::Book->new( schema => $schema );
    ok( $form, 'no param new' );
    $form->process( item_id => undef, params => $params );
    my $options = $form->field( 'format' )->options;
    is( @$options, 6, 'Format options loaded from the model' );
    return $form;
}

done_testing;
