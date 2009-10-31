use strict;
use warnings;

use Test::More;
use lib 't/lib';

use_ok( 'BookDB::Form::User');
use_ok( 'BookDB::Schema');
use_ok( 'BookDB::Form::BookWithOwner' );

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $user = $schema->resultset('User')->find( 1 );

my $form;
my $options;

$form = BookDB::Form::User->new( item => $user );
is( $form->field( 'addresses' )->resultset->result_class, 'BookDB::Schema::Result::Address', 'ResultSet for a has_many'  );
is( $form->field( 'employers' )->resultset->result_class, 'BookDB::Schema::Result::Employer', 'ResultSet for a many_to_many' );
is( $form->field( 'country' )->resultset->result_class, 'BookDB::Schema::Result::Country', 'ResultSet for a belongs_to' );
is( $form->field( 'license' )->resultset->result_class, 'BookDB::Schema::Result::License', 'ResultSet for a belongs_to' );

ok( $form, 'User form created' );
$options = $form->field( 'country' )->options;
is( @$options, 16, 'Options loaded from the model' );

my $fif = $form->fif;
$fif->{country} = 'PL';
# update user with new country
$form->process($fif);
is( $form->item->country_iso, 'PL', 'country updated correctly');
$fif->{country} = 'US';  # change back
$form->process($fif);

$form = BookDB::Form::User->new( schema => $schema, source_name => 'User' );
ok( $form, 'User form created' );
$options = $form->field( 'country' )->options;
is( @$options, 16, 'Options loaded from the model - simple' );

#warn Dumper( $options ); use Data::Dumper;

$form = BookDB::Form::BookWithOwner->new( schema => $schema, source_name => 'Book' );
ok( $form, 'Book with Owner form created' );
$options = $form->field( 'owner' )->field(  'country' )->options;
is( @$options, 16, 'Options loaded from the model - recursive' );
$options = $form->field( 'owner' )->field(  'employers' )->options;
is( @$options, 4, 'Options loaded from the model - many to many - recursive' );

my $book = $schema->resultset('Book')->find(1);
$form = BookDB::Form::BookWithOwner->new( item => $book );
ok( $form, 'Book with Owner form created' );
$options = $form->field( 'owner' )->field(  'country' )->options;
is( $form->field( 'owner' )->field(  'country' )->value, 'GB', 'Select value loaded in a related record');

done_testing;
