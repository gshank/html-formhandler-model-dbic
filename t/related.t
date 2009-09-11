use strict;
use warnings;

use Test::More;
use lib 't/lib';

use BookDB::Form::User;
use BookDB::Schema;

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');

my $form = BookDB::Form::User->new( schema => $schema );

$form->process( item_id => 1, schema => $schema );

ok( $form->field('employers.0.name'), 'field exists');

done_testing;
exit;

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
$form->process($params);
END { $form->item->delete }
ok( $form->validated, 'related form validated');
$form->process($params);
ok( $form->validated, 'second pass validated');

my $user = $form->item;
is( $user->user_name, 'Joe Smith', 'created item');
is( $schema->resultset('UserEmployer')->search({ user_id => $user->id  })->count, 1,
    'the right number of employers' );

ok( $form->item->employer, 'employer has been created' );

my $employer = {
   name => "Acme Software",
   category => "Computers",
   country => "United Kingdom"
};
is_deeply( $form->field('employer')->value, $employer, 'value is correct' );
$params->{opt_in} = 0;
$params->{license} = 0;
$params->{$_} = '' for qw/ country fav_book fav_cat /;
TODO: {
   local $TODO = 'fix fif to not create empty array for repeatable';
   is_deeply( $form->fif, $params, 'fif is correct' );
}

$form->process( item => $user );
is_deeply( $form->field('employer')->value, $employer, 'value correct when loaded from db' );

done_testing;
