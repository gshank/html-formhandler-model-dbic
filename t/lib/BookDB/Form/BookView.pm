package BookDB::Form::BookView;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use DateTime;


has '+item_class' => ( default => 'Book' );

has_field 'borrower' => ( type => 'Select' );
has_field 'borrowed';


# List for the "view" part of this form. These are not updated
# Not a standard form method. Convenience function
sub view_list {
    my @fields = ('title', 'author', 'genre', 'publisher', 'isbn', 'format', 'pages', 'year');

    return wantarray ? @fields : \@fields;
}

sub init_value_borrowed
{
    my ($self, $field) = @_;
    return DateTime->now( time_zone => 'local')->ymd;
}

1;
