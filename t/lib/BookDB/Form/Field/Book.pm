package BookDB::Form::Field::Book;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has_field 'id' => (
    type => 'PrimaryKey',
);

has_field 'title' => (
    type             => 'Text',
    required         => 1,
    required_message => 'A book must have a title.',
    label            => 'Title',
);
has_field 'authors' => (
    type  => 'Multiple',
    label => 'Authors',
);

has_field 'user_updated' => (
    type => 'Boolean'
);

# has_many relationship pointing to mapping table
has_field 'genres' => (
    type         => 'Multiple',
    label        => 'Genres',
    label_column => 'name',
);
has_field 'isbn' => (
    type   => 'Text',
    label  => 'ISBN',
    unique => 1,
);
has_field 'publisher' => (
    type  => 'Text',
    label => 'Publisher',
);
has_field 'format' => (
    type  => 'Select',
    label => 'Format',
);
has_field 'year' => (
    type        => 'Integer',
    range_start => '1900',
    range_end   => '2020',
    label       => 'Year',
);
has_field 'pages' => (
    type  => 'Integer',
    label => 'Pages',
);
has_field 'comment' => (
    type  => 'Text',
);

has_field submit => ( type => 'Submit', value => 'Update' );

sub validate {
    my $self = shift;

    my $year_field = $self->field('year');
    $year_field->add_error('Invalid year')
      if ( ( $year_field->value > 3000 ) || ( $year_field->value < 1600 ) );
}

__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
1;
