use strict;
use warnings;

use Test::More;
use lib 't/lib';

use BookDB::Form::User;
use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
my $user = $schema->resultset('User')->find(1);

my $form = BookDB::Form::User->new;

$form->process( item_id => 1, schema => $schema );

ok( $form->field('employers.0.name'), 'many_to_many field exists');

# addresses is a has_many relationship
# employers is a many_to_many relationship
my $fif = {
    'addresses.0.address_id' => 1,
    'addresses.0.city' => 'Middle City',
    'addresses.0.country' => 'GK',
    'addresses.0.street' => '101 Main St',
    'addresses.1.address_id' => 2,
    'addresses.1.city' => 'DownTown',
    'addresses.1.country' => 'UT',
    'addresses.1.street' => '99 Elm St',
    'addresses.2.address_id' => 3,
    'addresses.2.city' => 'Santa Lola',
    'addresses.2.country' => 'GF',
    'addresses.2.street' => '1023 Side Ave',
    'birthdate.day' => 23,
    'birthdate.month' => 4,
    'birthdate.year' => 1970,
    'country' => 'US',
    'employers.0.employer_id' => 1,
    'employers.0.category' => 'Perl',
    'employers.0.country' => 'US',
    'employers.0.name' => 'Best Perl',
    'employers.1.employer_id' => 2,
    'employers.1.category' => 'Programming',
    'employers.1.country' => 'UK',
    'employers.1.name' => 'Worst Perl',
    'employers.2.employer_id' => 3,
    'employers.2.category' => 'Programming',
    'employers.2.country' => 'DE',
    'employers.2.name' => 'Convoluted PHP',
    'fav_book' => 'Necronomicon',
    'fav_cat' => 'Sci-Fi',
    'license' => 3,
    'occupation' => 'management',
    'opt_in' => 0,
    'user_name' => 'jdoe',
};

is_deeply( $form->fif, $fif, 'fif ok' );;
my $old_emp = $schema->resultset('Employer')->search({name => 'Convoluted PHP'})->single;

$fif->{'employers.2.category'} = 'Maybe Programming';
$form->process($fif);
$old_emp->discard_changes;
is( $old_emp->category, 'Maybe Programming', 'field has been updated' );
$fif->{'employers.2.category'} = "Programming";
$form->process($fif);
$old_emp->discard_changes;
is( $old_emp->category, 'Programming', 'field updated again' );

my $params = {
   user_name => "Joe Smith",
   occupation => "Programmer",
   'birthdate.year' => '1974',
   'birthdate.month' => 4,
   'birthdate.day' => 21,
   'employers.0.name' => "Acme Software",
   'employers.0.category' => "Computers",
   'employers.0.country' => "United Kingdom"
};
$form->process( item_id => undef, params => $params);
my $new_user = $form->item;
my $new_employer = $schema->resultset('Employer')->find(5);
END { 
   $new_user->delete; 
   $new_employer->delete;
}
ok( $form->validated, 'new related row validated');
$fif = {
'birthdate.day' => 21,
'birthdate.month' => 4,
'birthdate.year' => 1974,
'country' => '',
'employers.0.employer_id' => 5,
'employers.0.category' => 'Computers',
'employers.0.country' => 'United Kingdom',
'employers.0.name' => 'Acme Software',
'fav_book' => '',
'fav_cat' => '',
'license' => '',
'occupation' => 'Programmer',
'opt_in' => 0,
'user_name' => 'Joe Smith',
};
is_deeply( $form->fif, $fif, 'fif for new item');
is( $form->item->id, 6, 'new user' );
$new_employer = $schema->resultset('Employer')->find(5);
ok( $new_employer, 'new employer');

my $new_fif = $form->fif;
delete $new_fif->{license}; # removeinit_value 
$form->process($new_fif);
ok( $form->validated, 'second pass validated');

$user = $form->item;
is( $user->user_name, 'Joe Smith', 'created item');
is( $schema->resultset('UserEmployer')->search({ user_id => $user->id  })->count, 1,
    'the right number of employers' );

my $employers = [{
   employer_id => 5,
   name => "Acme Software",
   category => "Computers",
   country => "United Kingdom"
}];
is_deeply( $form->field('employers')->value, $employers, 'value is correct' );
$params->{opt_in} = 0;
$params->{license} = '';
$params->{$_} = '' for qw/ country fav_book fav_cat /;
$params->{'employers.0.employer_id'} = 5;
is_deeply( $form->fif, $params, 'fif is correct' );

$form->process( item => $user );
is_deeply( $form->field('employers')->value, $employers, 'value correct when loaded from db' );

done_testing;
