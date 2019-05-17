package BookDB::Form::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use DateTime;

has '+item_class' => ( default => 'User');

has_field 'user_name' => ( unique => 1 );
has_field 'fav_cat' => ( label => 'Category' );
has_field 'fav_book' => ( label => 'Favorite Book' );
has_field 'occupation';
has_field 'country' => ( type => 'Select' );
has_field 'license' => ( type => 'Select' );
has_field 'opt_in' => ( type => 'Checkbox' );
has_field 'birthdate' => ( type => 'DateTime' );
has_field 'birthdate.year' => ( type => 'Text', );
has_field 'birthdate.month' => ( type => 'Text', );
has_field 'birthdate.day' => ( type => 'Text', );

has_field 'employers' => ( type => 'Repeatable' );
has_field 'employers.employer_id' => ( type => 'PrimaryKey' );
has_field 'employers.name';
has_field 'employers.category';
has_field 'employers.country';

has_field 'addresses' => ( type => 'Repeatable' );
has_field 'addresses.address_id' => ( type => 'PrimaryKey' );
has_field 'addresses.street';
has_field 'addresses.city';
has_field 'addresses.country' => ( type => 'Select' );

sub options_opt_in
{
   return (
      0 => 'Send no emails',
      1 => 'Send related emails'
   );
}

sub init_value_license
{
   my ( $self, $field, $item ) = @_;

   return 0 unless $item && $item->license_id && $item->license_id != 0;
   return $item->license_id;

}
sub validate_occupation
{
   my ( $self, $field ) = @_;
   if ( $field->value eq 'layabout' )
   {
      $field->add_error('No layabouts allowed');
   }
}

no HTML::FormHandler::Moose;
1;
