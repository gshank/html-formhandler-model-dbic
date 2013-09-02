use strict;
use warnings;
use Test::More;
use lib 't/lib';
use BookDB::Schema;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

    has '+item_class' => ( default => 'Book' );
    has_field 'title' => (
        type             => 'Text',
        required         => 1,
    );

    # has_many relationship pointing to mapping table
    has_field 'genres' => (
        type         => 'Multiple',
        label_column => 'name',
        active_column => 'is_active',
    );
}

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
my $form = MyApp::Form::Test->new( schema => $schema );

ok( $form );

is( $form->field('genres')->num_options, 3, 'right number of options' );

done_testing;

