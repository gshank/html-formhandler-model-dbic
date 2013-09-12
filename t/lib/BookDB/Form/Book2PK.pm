package BookDB::Form::Book2PK;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

with 'HTML::FormHandler::Widget::Theme::Bootstrap';

=head1 NAME

Form object for the Book Controller

=head1 SYNOPSIS

Form used for book/add and book/edit actions

=head1 DESCRIPTION

Catalyst Form.

=cut

has '+item_class'        => ( default => 'Book2PK' );

has_field 'title' => (
    type             => 'Text',
    required         => 1,
    required_message => 'A book must have a title.',
    label            => 'Title',
);

has_field 'publisher' => (
    type  => 'Text',
    label => 'Publisher',
);

# has_many relationship pointing to mapping table
has_field 'isbn' => (
    type     => 'Text',
    label    => 'ISBN',
    unique   => 1,
    required => 1,
);
has_field 'year' => (
    type        => 'Integer',
    range_start => '1900',
    range_end   => '2020',
    label       => 'Year',
    required    => 1,
);
has_field 'pages' => (
    type  => 'Integer',
    label => 'Pages',
);

has_field submit => ( type => 'Submit', value => 'Update', element_class => ['btn'] );

sub validate_year {
    my ( $self, $field ) = @_;
    $field->add_error('Invalid year')
      if ( ( $field->value > 3000 ) || ( $field->value < 1600 ) );
}

=head1 AUTHOR

Gerda Shank

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
1;
