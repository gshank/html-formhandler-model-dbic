use strict;
use warnings;

use Test::More;
use lib 't/lib';

use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
my $user = $schema->resultset('User')->find(1);

{
   package Repeatable::Form::User;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has_field 'user_name';
   has_field 'occupation';

   has_field 'addresses' => ( type => 'Repeatable' );
   has_field 'addresses.address_id' => ( type => 'PrimaryKey' );
   has_field 'addresses.street';
   has_field 'addresses.city';
   has_field 'addresses.country' => ( type => 'Select' );

}

my $form = Repeatable::Form::User->new;
ok( $form, 'get db has many form');
ok( !$form->field('addresses')->field('0')->field('country')->has_options,
    'addresses has no options because no schema' );

$form = Repeatable::Form::User->new( item => $user );
ok( $form->field('addresses')->field('0')->field('country')->has_options,
    'addresses has options from new' );

$form->process( item => $user, params => {} );
ok( $form->field('addresses')->field('0')->field('country')->has_options,
    'addresses has options after process' );

# the initial empty element in a repeatable field should
# still be there after 'process'
my $form2 = Repeatable::Form::User->new;
$form2->process( item => $schema->resultset('User')->new_result( {} ),
    params => {} );
ok( $form2->field('addresses')->field('0'),
    'Initial field exists after process' );

my $fif = {
   'addresses.0.city' => 'Middle City',
   'addresses.0.country' => 'GK',
   'addresses.0.address_id' => 1,
   'addresses.0.street' => '101 Main St',
   'addresses.1.city' => 'DownTown',
   'addresses.1.country' => 'UT',
   'addresses.1.address_id' => 2,
   'addresses.1.street' => '99 Elm St',
   'addresses.2.city' => 'Santa Lola',
   'addresses.2.country' => 'GF',
   'addresses.2.address_id' => 3,
   'addresses.2.street' => '1023 Side Ave',
   'occupation' => 'management',
   'user_name' => 'jdoe',
};
my $values = {
   addresses => [
      {
         city => 'Middle City',
         country => 'GK',
         address_id => 1,
         street => '101 Main St',
      },
      {
         city => 'DownTown',
         country => 'UT',
         address_id => 2,
         street => '99 Elm St',
      },
      {
         city => 'Santa Lola',
         country => 'GF',
         address_id => 3,
         street => '1023 Side Ave',
      },
   ],
   'occupation' => 'management',
   'user_name' => 'jdoe',
};

is_deeply( $form->fif, $fif, 'fill in form is correct' );
is_deeply( $form->values,  $values, 'values are correct' );

my $params = {
   user_name => "Joe Smith",
   occupation => "Programmer",
   'addresses.0.street' => "999 Main Street",
   'addresses.0.city' => "Podunk",
   'addresses.0.country' => "UT",
   'addresses.0.address_id' => "1",
   'addresses.1.street' => "333 Valencia Street",
   'addresses.1.city' => "San Franciso",
   'addresses.1.country' => "UT",
   'addresses.1.address_id' => "2",
   'addresses.2.street' => "1101 Maple Street",
   'addresses.2.city' => "Smallville",
   'addresses.2.country' => "AT",
   'addresses.2.address_id' => "3"
};
$form->process($params);
ok( $form->field('addresses')->field('0')->field('country')->has_options,
    'addresses has options' );

ok( $form->validated, 'has_many form validated');
$form->process($params);
ok( $form->validated, 'second pass validated');

$user = $form->item;
is( $user->user_name, 'Joe Smith', 'created item');
is( $schema->resultset('Address')->search({ user_id => $user->id  })->count, 3,
    'the right number of addresses' );

is_deeply( $form->fif, $params, 'fif is correct' );

$form->process($fif);
is( $form->item->search_related( 'addresses', {city => 'Middle City'} )->first->country->printable_name, 'Graustark', 'updated addresses');

$params->{'addresses.3.street'} = "1101 Maple Street";
$params->{'addresses.3.city'} = "Smallville";
$params->{'addresses.3.country'} = "AT";
$params->{'addresses.3.address_id'} = undef;

$form->process($params);
my $new_address = $form->item->search_related('addresses', { address_id => {'>', 3} })->single;
END { $form->item->find_related('addresses', $new_address->id )->delete };
ok( $form->validated, 'validated with new address');
is( $form->field('addresses.3.address_id')->value, $new_address->id, 'id for new row is correct');

# restore row to beginning state
$form->process($values);

done_testing;
