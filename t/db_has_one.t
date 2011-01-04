use strict;
use warnings;

use Test::More;
use lib 't/lib';

use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
my $user = $schema->resultset('User')->find(1);

{
    package Options::Field;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'options_id' => ( type => 'PrimaryKey' );
    has_field 'option_one';
    has_field 'option_two';
    has_field 'option_three';
}

{
   package Form::User;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has_field 'user_name';
   has_field 'occupation';

   has_field 'options' => ( type => '+Options::Field' );

}

my $form = Form::User->new;
ok( $form, 'get db form');
$form->process( item => $user, params => {} );

my $expected = {
    user_name => 'jdoe',
    occupation => 'management',
    options => {
        options_id => 1,
        option_one => 'blue',
        option_two => 'red',
        option_three => 'green',
    }
};

is_deeply( $form->value, $expected, 'got expected values' );

$expected->{options}->{option_one} = 'yellow';
$form->process( item => $user, params => $expected );
is_deeply( $form->value, $expected, 'got changed expected values' );
$user->discard_changes;

my $option_one = $user->options->option_one;
is( $option_one, 'yellow', 'user options changed' );

$expected->{options}->{option_one} = 'blue';
$form->process( item => $user, params => $expected );


done_testing;
