package HTML::FormHandler::TraitFor::Model::DBIC;

# ABSTRACT: model role that interfaces with DBIx::Class

use Moose::Role;

use Carp;
use DBIx::Class::ResultClass::HashRefInflator;
use DBIx::Class::ResultSet::RecursiveUpdate;
use Scalar::Util ('blessed');

our $VERSION = '0.26';

=head1 SYNOPSIS

Subclass your form from HTML::FormHandler::Model::DBIC:

    package MyApp::Form::User;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

or apply as a role to FormHandler class:

   package MyApp::Form::User;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::TraitFor::Model::DBIC';

=head1 DESCRIPTION

This is a separate L<DBIx::Class> model role for L<HTML::FormHandler>.
It will handle normal DBIC column accessors and a number of DBIC relationships.
It will save form fields automatically to the database. The distribution contains a form
generator (L<HTML::FormHandler::Generator::DBIC>). An example application can
be found on github at http://github.com/gshank/formhandler-example.

L<HTML::FormHandler::TraitFor::DBICFields> can be used to auto-generate forms
from a DBIC result.

    my $book = $schema->resultset('Book')->find(1);
    my $form = HTML::FormHandler::Model::DBIC->new_with_traits(
       traits => ['HTML::FormHandler::TraitFor::DBICFields'],
       field_list => [ 'submit' => { type => 'Submit', value => 'Save', order => 99 } ],
       item => $book );

This model supports using DBIx::Class result_source accessors just as
if they were standard columns.
Forms that need to do custom updating usually will subclass or use an 'around'
method modifier on the 'update_model' method.

There are two ways to get a valid DBIC model. The first way is to set:

   item_id (primary key)
   item_class (source name)
   schema

The 'item_class' is usually set in the form class:

    # Associate this form with a DBIx::Class result class
    has '+item_class' => ( default => 'User' ); # 'User' is the DBIC source_name

The 'item_id' and 'schema' must be passed in when the form is used in your
controller.

   $form->process( item_id => $id, schema => $c->model('DB')->schema,
                   params => $c->req->params );

If the item_id is not defined, then a new record will be created.

The second way is to pass in a DBIx::Class row, or 'item';

   $form->process( item => $row, params => $c->req->params );

The 'item_id', 'item_class', and 'schema' will be derived from the 'item'.
For a new row (such as on a 'create' ), you can use new_result:

   my $item = $c->model('DB::Book')->new_result({});
   $form->process( item => $item, params => $c->req->params );

The accessor names of the fields in your form should match column, relationship,
or accessor names in your DBIx::Class result source. Usually the field name
and accessor are the same, but they may be different.

=head1 DBIC Relationships

=head2 belongs_to

Single Select fields will handle 'belongs_to' relationships, where the related
table is used to construct a selection list from the database.

=head2 many_to_many

Multiple Select fields use a 'many_to_many' pseudo-relation to retrieve the
selection list from the database.

   has_field 'roles' => (
      type => 'Multiple',
      label_column => 'role',
   );

You need to supply 'label_column' to indicate which column should be used as label.

A Compound field can represent a single relation. A Repeatable field will map onto a multiple
relationship.

More information is available from:

L<HTML::FormHandler>

L<HTML::FormHandler::Manual>

L<HTML::FormHandler::Field>

=head1 METHODS

=head2 schema

Stores the schema that is either passed in, created from
the model name in the controller, or created from the
Catalyst context and the item_class in the plugin.

=head2 validate_model

The place to put validation that requires database-specific lookups.
Subclass this method in your form. Validation of unique fields is
called from this method.

=head2 update_model

Updates the database. If you want to do some extra
database processing (such as updating a related table) this is the
method to subclass in your form.

This routine allows the use of non-database (non-column, non-relationship)
accessors in your result source class. It identifies form fields as column,
relationship, select, multiple, or other. Column and other fields are
processed and update is called on the row. Then relationships are processed.

If the row doesn't exist (no primary key or row object was passed in), then
a row is created.

=head2 lookup_options

This method is used with "Single" and "Multiple" field select lists
("single", "filter", and "multi" relationships).
It returns an array reference of key/value pairs for the column passed in.
The column name defined in $field->label_column will be used as the label.
The default label_column is "name".  The labels are sorted by Perl's cmp sort.

If there is an "active" column then only active values are included, except
if the form (item) has currently selected the inactive item.  This allows
existing records that reference inactive items to still have those as valid select
options.  The inactive labels are formatted with brackets to indicate in the select
list that they are inactive.

The active column name is determined by calling:
    $active_col = $form->can( 'active_column' )
        ? $form->active_column
        : $field->active_column;

This allows setting the name of the active column globally if
your tables are consistantly named (all lookup tables have the same
column name to indicate they are active), or on a per-field basis.

The column to use for sorting the list is specified with "sort_column".
The currently selected values in a Multiple list are grouped at the top
(by the Multiple field class).

=head2 init_value

This method sets a field's initial value. it is set when values are
initially loaded from an item, init_object or field defaults.

=head2 validate_unique

For fields that are marked "unique", checks the database for uniqueness.
The unique constraints registered in the DBIC result source (see
L<DBIx::Class::ResultSource/add_unique_constraint>) will also be inspected
for uniqueness unless the field's 'unique' attribute is set to false.
Alternatively, you can use the C<unique_constraints>
attribute to limit uniqueness checking to only a select group of unique
constraints.  Error messages can be specified in the C<unique_messages>
attribute.  Here's an example where you might want to specify a unique
widget name for a given department:

   has '+unique_constraints' => ( default => sub { ['department_widget_name'] } );
   has '+unique_messages' => (
      default => sub {
         { department_widget_name => "Please choose a unique widget name for this department" };
      }
   );

=head2 source

Returns a DBIx::Class::ResultSource object for this Result Class.

=head2 resultset

This method returns a resultset from the "item_class" specified
in the form (C<< $schema->resultset( $form->item_class ) >>)

=head1 Attributes

=over

=item schema

=item source_name

=item unique_constraints

=item unique_messages

=item ru_flags

L<DBIx::Class::ResultSet::RecursiveUpdate> is used to interface with L<DBIx::Class>.
By default, the flag 'unknown_params_ok' is passed in. The 'ru_flags' attribute is
a hashref, and also provides 'set_ru_flag'.

=back

=cut

has 'schema' => ( is => 'rw', );
has 'source_name' => (
    isa     => 'Str',
    is      => 'rw',
    lazy    => 1,
    builder => 'build_source_name'
);

has unique_constraints => (
    is         => 'ro',
    isa        => 'ArrayRef',
    lazy_build => 1,
);

sub _build_unique_constraints {
    my $self = shift;
    return [ grep { $_ ne 'primary' }
            $self->resultset->result_source->unique_constraint_names ];
}

has unique_messages => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 'ru_flags' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => ['Hash'],
    builder => '_build_ru_flags',
    handles => { set_ru_flag => 'set', }
);

sub _build_ru_flags {
    { unknown_params_ok => 1 };
}

sub validate_model {
    my ($self) = @_;
    return unless $self->validate_unique;
    return 1;
}

sub clear_model {
    my $self = shift;
    $self->item(undef);
    $self->item_id(undef);
}

sub update_model {
    my $self   = shift;
    my $item   = $self->item;
    my $source = $self->source;

    warn "HFH: update_model for ", $self->name, "\n" if $self->verbose;

    #warn "fif: " . Dumper ( $self->fif ); use Data::Dumper;
    my %update_params = (
        resultset => $self->resultset,
        updates   => $self->values,
        %{ $self->ru_flags },
    );
    $update_params{object} = $self->item if $self->item;
    my $new_item;

    # perform update in a transaction, since RecursiveUpdate may do multiple
    # updates if there are compound or multiple fields
    $self->schema->txn_do(
        sub {
            $new_item = DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
                %update_params);
            $new_item->discard_changes;
        }
    );
    $self->item($new_item) if $new_item;
    return $self->item;
}

# undocumented because this is going to be replaced
# by a better method
sub guess_field_type {
    my ( $self, $column ) = @_;
    my $source = $self->source;
    my @return;

    #  TODO: Should be able to use $source->column_info

    # Is it a direct has_a relationship?
    if (
        $source->has_relationship($column) &&
        ( $source->relationship_info($column)->{attrs}->{accessor} eq 'single' ||
            $source->relationship_info($column)->{attrs}->{accessor} eq 'filter' )
        )
    {
        my $f_class = $source->related_class($column);
        @return =
            $f_class->isa('DateTime') ? ('DateTime') :
                                        ('Select');
    }

    # Else is it has_many?
    elsif ( $source->has_relationship($column) &&
        $source->relationship_info($column)->{attrs}->{accessor} eq 'multi' )
    {
        @return = ('Multiple');
    }
    elsif ( $column =~ /_time$/ )    # ends in time, must be time value
    {
        @return = ('DateTime');
    }
    else                             # default: Text
    {
        @return = ('Text');
    }

    return wantarray ? @return : $return[0];
}

sub lookup_options {
    my ( $self, $field, $accessor_path ) = @_;

    return unless $self->schema;
    my $self_source = $self->get_source($accessor_path);

    my $accessor = $field->accessor;

    # if this field doesn't refer to a foreign key, return
    my $f_class;
    my $source;

    # belongs_to single select
    if ( $self_source->has_relationship($accessor) ) {
        $f_class = $self_source->related_class($accessor);
        $source  = $self->schema->source($f_class);
    }
    else {

        # check for many_to_many multiple select
        my $resultset = $self_source->resultset;
        my $new_result = $resultset->new_result( {} );
        if ( $new_result && $new_result->can("add_to_$accessor") ) {
            $source = $new_result->$accessor->result_source;
        }
    }
    return unless $source;

    my $label_column = $field->label_column;
    return
        unless ( $source->has_column($label_column) ||
        $source->result_class->can($label_column) );

    my $active_col = $self->active_column || $field->active_column;
    $active_col = '' unless $source->has_column($active_col);
    my $sort_col = $field->sort_column;
    my ($primary_key) = $source->primary_columns;

    # if no sort_column and label_column is a source method, not a real column, must
    # use some other column for sort. There's probably some other column that should
    # be specified, but this will prevent breakage
    if ( !defined $sort_col ) {
        $sort_col = $source->has_column($label_column) ? $label_column : $primary_key;
    }

    # If there's an active column, only select active OR items already selected
    my $criteria = {};
    if ($active_col) {
        my @or = ( $active_col => 1 );

        # But also include any existing non-active
        push @or, ( "$primary_key" => $field->init_value )
            if $self->item && defined $field->init_value;
        $criteria->{'-or'} = \@or;
    }

    # get an array of row objects
    my @rows =
        $self->schema->resultset( $source->source_name )
        ->search( $criteria, { order_by => $sort_col } )->all;
    my @options;
    foreach my $row (@rows) {
        my $label = $row->$label_column;
        next unless defined $label;    # this means there's an invalid value
        push @options, $row->id, $active_col && !$row->$active_col ? "[ $label ]" : "$label";
    }
    return \@options;
}

sub init_value {
    my ( $self, $field, $value ) = @_;
    if ( ref $value eq 'ARRAY' ) {
        $value = [ map { $self->_fix_value( $field, $_ ) } @$value ];
    }
    else {
        $value = $self->_fix_value( $field, $value );
    }
    $field->init_value($value);
    $field->value($value);
}

sub _fix_value {
    my ( $self, $field, $value ) = @_;
    if ( blessed $value && $value->isa('DBIx::Class') ) {
        return $value->id;
    }
    return $value;
}

sub _get_related_source {
    my ( $self, $source, $name ) = @_;

    if ( $source->has_relationship($name) ) {
        return $source->related_source($name);
    }

    # many to many case
    my $row = $source->resultset->new( {} );
    if ( $row->can($name) and
        $row->can( 'add_to_' . $name ) and
        $row->can( 'set_' . $name ) )
    {
        return $row->$name->result_source;
    }
    return;
}

# this needs to be rewritten to be called at the field level
# right now it will only work on fields immediately contained
# by the form
sub validate_unique {
    my ($self) = @_;

    my $rs          = $self->resultset;
    my $found_error = 0;
    my $fields      = $self->fields;

    my @id_clause = ();
    @id_clause = _id_clause( $rs, $self->item_id ) if defined $self->item;

    my $value = $self->value;
    for my $field (@$fields) {
        next unless $field->unique;
        next if ( $field->is_inactive || !$field->has_result );
        next if $field->has_errors;
        my $value = $field->value;
        next unless defined $value;
        my $accessor = $field->accessor;

        my $count = $rs->search( { $accessor => $value, @id_clause } )->count;
        next if $count < 1;
        my $field_error = $field->get_message('unique') || $field->unique_message || 'Duplicate value for [_1]';
        $field->add_error( $field_error, $field->loc_label );
        $found_error++;
    }

    # validate unique constraints in the model
    for my $constraint ( @{ $self->unique_constraints } ) {
        my @columns = $rs->result_source->unique_constraint_columns($constraint);

        # check for matching field in the form
        my $field;
        for my $col (@columns) {
            ($field) = grep { $_->accessor eq $col } @$fields;
            last if $field;
        }
        next unless defined $field;
        next if ( $field->has_unique );    # already handled or don't do

        my @values = map {
            exists( $value->{$_} ) ? $value->{$_} : undef ||
                ( $self->item ? $self->item->get_column($_) : undef )
        } @columns;

        next
            if @columns !=
                @values; # don't check unique constraints for which we don't have all the values
        next
            if grep { !defined $_ } @values;   # don't check unique constraints with NULL values

        my %where;
        @where{@columns} = @values;
        my $count = $rs->search( \%where )->search( {@id_clause} )->count;
        next if $count < 1;

        my $field_error = $self->unique_message_for_constraint($constraint);
        $field->add_error( $field_error, $constraint );
        $found_error++;
    }

    return $found_error;
}

sub unique_message_for_constraint {
    my $self       = shift;
    my $constraint = shift;

    return $self->unique_messages->{$constraint} ||=
        "Duplicate value for [_1] unique constraint";
}

sub _id_clause {
    my ( $resultset, $id ) = @_;

    my @pks = $resultset->result_source->primary_columns;
    my %clause;
    # multiple primary key
    if ( scalar @pks > 1 ) {
        die "multiple primary key invalid" if ref $id ne 'ARRAY';
        my $cond = $id->[0];
        my @phrase;
        foreach my $col ( keys %$cond ) {
            $clause{$col} = { '!=' => $cond->{$col} };
        }
    }
    else {
        %clause = ( $pks[0] => { '!=' => $id } );
    }
    return %clause;
}

sub build_item {
    my $self = shift;

    my $item_id = $self->item_id or return;
    my $item = $self->resultset->find( ref $item_id eq 'ARRAY' ? @{$item_id} : $item_id );
    $self->item_id(undef) unless $item;
    return $item;
}

sub set_item {
    my ( $self, $item ) = @_;
    return unless $item;

    # when the item (DBIC row) is set, set the item_id, item_class
    # and schema from the item
    my @primary_columns = $item->result_source->primary_columns;
    my $item_id;
    if ( @primary_columns == 1 ) {
        $item_id = $item->get_column( $primary_columns[0] );
    }
    elsif ( @primary_columns > 1 ) {
        my @pks = map {  $_ => $item->get_column($_) } @primary_columns;
        $item_id = [ { @pks }, { key => 'primary' } ];
    }
    if ($item_id) {
        $self->item_id($item_id);
    }
    else {
        $self->clear_item_id;
    }
    $self->item_class( $item->result_source->source_name );
    $self->schema( $item->result_source->schema );
}

sub set_item_id {
    my ( $self, $item_id ) = @_;

    # if a new item_id has been set
    # clear an existing item
    if ( defined $self->item ) {
        $self->clear_item
            if (
            !defined $item_id ||
            ( ref $item_id eq 'ARRAY' &&
                join( '', @{$item_id} ) ne join( '', $self->item->id ) ) ||
            ( ref \$item_id eq 'SCALAR' &&
                $item_id ne $self->item->id )
            );
    }
}

sub build_source_name {
    my $self = shift;
    return $self->item_class;
}

sub source {
    my ( $self, $f_class ) = @_;
    return $self->schema->source( $self->source_name || $self->item_class );
}

sub resultset {
    my ( $self, $f_class ) = @_;
    die "You must supply a schema for your FormHandler form"
        unless $self->schema;
    return $self->schema->resultset( $self->source_name || $self->item_class );
}

sub get_source {
    my ( $self, $accessor_path ) = @_;
    return unless $self->schema;
    my $source = $self->source;
    return $source unless $accessor_path;
    my @accessors = split /\./, $accessor_path;
    for my $accessor (@accessors) {
        $source = $self->_get_related_source( $source, $accessor );
        die "unable to get source for $accessor" unless $source;
    }
    return $source;
}

use namespace::autoclean;
1;
