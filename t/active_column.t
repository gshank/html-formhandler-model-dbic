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
{
    package MyApp::Form::Test2;
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
        active_column => 'check_active',
    );
}

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
my $form = MyApp::Form::Test->new( schema => $schema );
my $form2 = MyApp::Form::Test2->new( schema => $schema );

ok( $form );
ok( $form2 );

is( $form->field('genres')->num_options, 3, 'right number of options with column' );
is( $form2->field('genres')->num_options, 3, 'right number of options with method' );


done_testing;

