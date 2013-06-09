use strict;
use warnings;
use Test::More;
use Test::Exception;

use lib './t';
use lib 't/lib';

use BookDB::Schema;
use_ok('HTML::FormHandler::Field::DateTime');
my $field = HTML::FormHandler::Field::DateTime->new( name => 'test_field' );
ok( defined $field, 'new() called' );

{
    package UserForm;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

    has_field 'birthdate'      => ( type => 'DateTime' );
    has_field 'birthdate.year' => ( type => 'Year' );
}

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');

{
    my $user = $schema->resultset('User')->first;
    my $form = UserForm->new( item => $user );
    ok( $form, 'Form with DateTime field loaded from the db' );
}

{
    my $user = $schema->resultset('User')->new_result( {} );
    my $form = UserForm->new( );
    lives_ok { $form->process( item => $user, params => {} ) }
        'Form with newly created DateTime field';
}

done_testing;
