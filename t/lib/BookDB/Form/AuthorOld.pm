package BookDB::Form::AuthorOld;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+item_class' => ( default => 'AuthorOld' );

has_field 'last_name' => ( type => 'Text', required => 1 );
has_field 'first_name' => ( type => 'Text', required => 1 );
has_field 'country' => ( type => 'Text' );
has_field 'birthdate' => ( type => 'DateTime' );
has_field 'foo';
has_field 'bar';

no HTML::FormHandler::Moose;
1;
