package HTML::FormHandler::Model::DBIC;

use Moose;
extends 'HTML::FormHandler';
use Carp;
use DBIx::Class::ResultClass::HashRefInflator;
use DBIx::Class::ResultSet::RecursiveUpdate;
use Scalar::Util qw(blessed);

our $VERSION = '0.05001';

=head1 NAME

HTML::FormHandler::Model::DBIC - Model class for FormHandler using DBIx::Class

=head1 SYNOPSIS

Subclass your form from HTML::FormHandler::Model::DBIC:

    package MyApp:Form::User;

    use Moose;
    extends 'HTML::FormHandler::Model::DBIC';

=head1 DESCRIPTION

This is a separate L<DBIx::Class> model class for L<HTML::FormHandler>. In addition
it contains an example application (execute with t/script/bookdb_server.pl) and a form
generator (L<HTML::FormHandler::Generator::DBIC>).

It will handle normal DBIC column accessors and a number of DBIC relationships.
Single Select fields will handle 'belongs_to' relationships, where the related
table is used to construct a list of choices. Multiple Select fields use a 
many_to_many pseudo-relation to create the select list. A Compound field can
represent a single relation. A Repeatable field will map onto a multiple
relationship. 

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

=head1 DESCRIPTION

This DBIC model for HTML::FormHandler will save form fields automatically to
the database, will retrieve selection lists from the database
(with type => 'Select' and a fieldname containing a belongs_to relationship,
or type => 'Multiple' and a many_to_many relationship),
and will save the selected values (one value for 'Select', multiple
values in a mapping table for a 'Multiple' field).

This model supports using DBIx::Class result_source accessors just as
if they were standard columns. 
Since the forms that use this model are subclasses of it, you can subclass
any of the subroutines to provide custom functionality.

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

This method sets a field's value (for $field->value).

This method is not called if a method "init_value_$field_name" is found
in the form class - that method is called instead.

=head2 validate_unique

For fields that are marked "unique", checks the database for uniqueness.

=head2 source

Returns a DBIx::Class::ResultSource object for this Result Class.

=head2 resultset

This method returns a resultset from the "item_class" specified
in the form (C<< $schema->resultset( $form->item_class ) >>)

=cut

has 'schema' => (
   is      => 'rw',
);
has 'source_name' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   builder => 'build_source_name'
);

sub validate_model
{
   my ($self) = @_;
   return unless $self->validate_unique;
   return 1;
}

sub clear_model
{
   my $self = shift;
   $self->item(undef);
   $self->item_id(undef);
}

sub update_model
{
    my $self = shift;
    my $item   = $self->item;
    my $source = $self->source;

    warn "HFH: update_model for ", $self->name, "\n" if $self->verbose;
    #warn "fif: " . Dumper ( $self->fif ); use Data::Dumper;
    my %update_params = (
        resultset => $self->resultset,
        updates => $self->values,
    );
    $update_params{ object } = $self->item if $self->item;
    my $new_item = DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update( %update_params );
    $new_item->discard_changes;
    $self->item($new_item);
    return $new_item;
}

# undocumented because this is going to be replaced
# by a better method
sub guess_field_type
{
   my ( $self, $column ) = @_;
   my $source = $self->source;
   my @return;

   #  TODO: Should be able to use $source->column_info

   # Is it a direct has_a relationship?
   if (
      $source->has_relationship($column)
      && (  $source->relationship_info($column)->{attrs}->{accessor} eq 'single'
         || $source->relationship_info($column)->{attrs}->{accessor} eq 'filter' )
      )
   {
      my $f_class = $source->related_class($column);
      @return =
         $f_class->isa('DateTime')
         ? ('DateTime')
         : ('Select');
   }
   # Else is it has_many?
   elsif ( $source->has_relationship($column)
      && $source->relationship_info($column)->{attrs}->{accessor} eq 'multi' )
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



# this needs to be rewritten to be called at the field level
# right now it will only work on fields immediately contained
# by the form
sub validate_unique
{
   my ($self) = @_;

   my $rs          = $self->resultset;
   my $found_error = 0;

   for my $field ( @{$self->fields} )
   {
      next unless $field->unique;
      next if $field->has_errors;
      my $value = $field->value;
      next unless defined $value;
      my $accessor   = $field->accessor;

      my @id_clause = ();
      @id_clause = _id_clause( $rs, $self->item_id ) if defined $self->item;
      my $count = $rs->search( { $accessor => $value, @id_clause } )->count;
      next if $count < 1;
      my $field_error = $field->unique_message || 'Duplicate value for ' . $field->label;
      $field->add_error( $field_error );
      $found_error++;
   }

   return $found_error;
}

sub _id_clause {
    my( $resultset, $id ) = @_;
    my @pks = $resultset->result_source->primary_columns;
    my @ids;
    if( ref $id eq 'ARRAY' ){
        @ids = @$id;
    }
    else{
        @ids = ( $id );
    }
    my %result;
    for my $i ( $#ids ){
        $result{$pks[$i]} = { '!=' => $ids[$i] };
    }
    return %result;
}

sub build_item
{
   my $self = shift;

   my $item_id = $self->item_id or return;
   my $item = $self->resultset->find( ref $item_id eq 'ARRAY' ?
                @{$item_id} : $item_id);
   $self->item_id(undef) unless $item;
   return $item;
}

sub set_item
{
   my ( $self, $item ) = @_;
   return unless $item;
   # when the item (DBIC row) is set, set the item_id, item_class
   # and schema from the item
   if( $item->id )
   { $self->item_id($item->id); }
   else
   { $self->clear_item_id; }
   $self->item_class( $item->result_source->source_name );
   $self->schema( $item->result_source->schema );
}

sub set_item_id
{
   my ( $self, $item_id ) = @_;
   # if a new item_id has been set
   # clear an existing item
   if( defined $self->item )
   {
      $self->clear_item
         if( !defined $item_id ||
             (ref $item_id eq 'ARRAY' &&
              join('', @{$item_id}) ne join('', $self->item->id)) ||
             (ref \$item_id eq 'SCALAR' &&
              $item_id ne $self->item->id));
   }
}


sub build_source_name
{
   my $self = shift;
   return $self->item_class;
}


sub source
{
   my ( $self, $f_class ) = @_;
   return $self->schema->source( $self->source_name || $self->item_class );
}

sub resultset
{
   my ( $self, $f_class ) = @_;
   die "You must supply a schema for your FormHandler form" unless $self->schema;
   return $self->schema->resultset( $self->source_name || $self->item_class );
}


sub model_new_field_hook
{
    my( $self, $class, $field_attr ) = @_;
    my @traits = $field_attr->{traits} ? @{$field_attr->{traits}} : ();

    if( $class->DOES( 'HTML::FormHandler::Field' ) ) {
        push @traits, 'HTML::FormHandler::Model::DBIC::Field';
    }   
    if( $class->DOES( 'HTML::FormHandler::Field::Select' ) ) {
        push @traits, 'HTML::FormHandler::Model::DBIC::Field::Select';
    }   
    elsif( $class->DOES( 'HTML::FormHandler::Field::Compound' ) ) {
        push @traits, 'HTML::FormHandler::Model::DBIC::Field::Compound';
    }
    $field_attr->{traits} = \@traits if @traits;
    if( 
        $class->DOES( 'HTML::FormHandler::Field::Select' ) 
        || $class->DOES( 'HTML::FormHandler::Field::Compound' )
    ){
        return unless $self->schema;
        my $related_source;
        my $name = $field_attr->{accessor} || $field_attr->{name};
        if( $self->source->has_relationship( $name ) ){
            $related_source = $self->source->related_source( $name );
        }
        # many to many case
        my $row = $self->source->resultset->new({});
        if ( $row->can( $name ) and $row->can( 'add_to_' . $name ) and $row->can( 'set_' . $name ) ){
            $related_source = $row->$name->result_source;
        }
        $field_attr->{resultset} = $related_source->resultset if $related_source;
    }
}

{
    package  HTML::FormHandler::Model::DBIC::Field;
    use Moose::Role;

    sub init_value_with_fix
    {
       my ( $self, $value ) = @_;
       if( ref $value eq 'ARRAY' ){
           $value = [ map { $self->_fix_value( $_ ) } @$value ];
       }
       else{
           $value = $self->_fix_value( $value );
       }
       $self->init_value($value);
       $self->value($value);
    }

    sub _fix_value
    {
       my ( $self, $value ) = @_;
       if( blessed $value && $value->isa('DBIx::Class') ){
           return $value->id;
       }
       return $value;
    }
}


{
    package  HTML::FormHandler::Model::DBIC::Field::Select;
    use Moose::Role;
    
    has resultset => ( isa => 'DBIx::Class::ResultSet', is => 'rw' );

    sub lookup_options
    {
       my ( $self, ) = @_;

       return unless $self->resultset;
       my $source;
       $source = $self->resultset->result_source;

       my $label_column = $self->label_column;
       return unless $source->has_column($label_column);

       my $active_col = $self->form->active_column || $self->active_column;
       $active_col = '' unless $source->has_column($active_col);
       my $sort_col = $self->sort_column;
       $sort_col = defined $sort_col && $source->has_column($sort_col) ? $sort_col : $label_column;

       my ($primary_key) = $source->primary_columns;

       # If there's an active column, only select active OR items already selected
       my $criteria = {};
       if ($active_col)
       {
          my @or = ( $active_col => 1 );

          # But also include any existing non-active
          push @or, ( "$primary_key" => $self->init_value )
             if $self->form->item && defined $self->init_value;
          $criteria->{'-or'} = \@or;
       }

       # get an array of row objects
       my @rows =
          $self->resultset->search( $criteria, { order_by => $sort_col } )->all;
       my @options;
       foreach my $row (@rows)
       {
          my $label = $row->$label_column;
          next unless $label;   # this means there's an invalid value
          push @options, $row->id, $active_col && !$row->$active_col ? "[ $label ]" : "$label";
       }
       return \@options;
    }

}

{
    package  HTML::FormHandler::Model::DBIC::Field::Compound;
    use Moose::Role;

    has resultset => ( isa => 'DBIx::Class::ResultSet', is => 'rw' );

    sub model_new_field_hook
    {
        my( $self, $class, $field_attr ) = @_;
        return unless $self->resultset;
        my @traits = $field_attr->{traits} ? @{$field_attr->{traits}} : ();

        if( $class->DOES( 'HTML::FormHandler::Field' ) ) {
            push @traits, 'HTML::FormHandler::Model::DBIC::Field';
        }   
        if( $class->DOES( 'HTML::FormHandler::Field::Select' ) ) {
            push @traits, 'HTML::FormHandler::Model::DBIC::Field::Select';
        }   
        elsif( $class->DOES( 'HTML::FormHandler::Field::Compound' ) ) {
            push @traits, 'HTML::FormHandler::Model::DBIC::Field::Compound';
        }
        $field_attr->{traits} = \@traits if @traits;
        if( 
            $class->DOES( 'HTML::FormHandler::Field::Select' ) 
            || $class->DOES( 'HTML::FormHandler::Field::Compound' )
        ){
            my $source = $self->resultset->result_source;
            my $related_source;
            my $name = $field_attr->{accessor} || $field_attr->{name};
            if( $source->has_relationship( $name ) ){
                $related_source = $source->related_source( $name );
            }
            # many to many case
            my $row = $source->resultset->new({});
            if ( $row->can( $name ) and $row->can( 'add_to_' . $name ) and $row->can( 'set_' . $name ) ){
                $related_source = $row->$name->result_source;
            }
            $field_attr->{resultset} = $related_source->resultset if $related_source;
        }
    }
}

=head1 SUPPORT

See L<HTML::FormHandler>

=head1 AUTHORS

Gerda Shank (gshank), gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
