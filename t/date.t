use strict;
use warnings;
use Test::Exception;
use Test::More;

use lib './t';
use lib 't/lib';

use BookDB::Schema;
use_ok('HTML::FormHandler::Field::Date');
my $field = HTML::FormHandler::Field::Date->new( name => 'test_field' );
ok( defined $field, 'new() called' );

{

package UserForm;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

has_field 'birthdate'      => ( type => 'Date' );
}

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');


{
    my $user = $schema->resultset('User')->first;
    my $form = UserForm->new( item => $user );
    ok( $form, 'Form with Date field loaded from the db' );
}

{
    my $user = $schema->resultset('User')->new_result(
        { birthdate => DateTime->now } );
    my $form = UserForm->new( );
    lives_ok { $form->process( item => $user, params => {} ) }
        'Form with newly created Date field with date';
}

{
    my $user = $schema->resultset('User')->new_result( {} );
    my $form = UserForm->new( );
    lives_ok { $form->process( item => $user, params => {} ) }
        'Form with newly created Date field without date';
}

done_testing;
