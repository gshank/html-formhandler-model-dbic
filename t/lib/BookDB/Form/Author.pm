package BookDB::Form::Author;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+item_class' => ( default => 'Author' );

has_field 'last_name' => ( type => 'Text', required => 1 );
has_field 'first_name' => ( type => 'Text', required => 1 );
has_field 'country' => ( type => 'Text' );
has_field 'birthdate' => ( type => 'DateTime' );
has_field 'books' => ( type => 'Repeatable' );
has_field 'books.contains' => ( type => '+BookDB::Form::Field::Book' );

no HTML::FormHandler::Moose;
1;
