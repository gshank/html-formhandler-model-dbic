package HTML::FormHandler::TraitFor::DBICFields;
# ABSTRACT: role to get fields from DBIx::Class result source

use Moose::Role;
requires ('source', 'schema');
use HTML::FormHandler::Model::DBIC::TypeMap;

=head1 SYNOPSIS

This is a role to pull fields from a DBIx::Class result source. Requires
existence of a 'source' attribute.

This feature is new. It doesn't handle relationships yet, and the
interfaces are still subject to change.

  my $form = HTML::FormHandler::Model::DBIC->new_with_traits(
      traits => ['HTML::FormHandler::TraitFor::DBICFields'],
      item => $book
  );

=cut

has 'fields_from_model' => ( is => 'ro', default => 1 );

has 'include' => ( is => 'ro',
    traits => ['Array'],
    isa => 'ArrayRef[Str]',
    default => sub {[]},
    handles => {
       all_includes => 'elements',
       has_includes => 'count',
    }
);
has 'exclude' => ( is => 'ro',
    traits => ['Array'],
    isa => 'ArrayRef[Str]',
    default => sub {[]},
    handles => {
       has_excludes => 'count',
    }
);
has 'rels' => ( is => 'ro',
    traits => ['Array'],
    isa => 'ArrayRef[Str]',
    default => sub {[]},
    handles => {
       has_rels => 'count',
    }
);
has 'type_map_class' => ( is => 'ro', isa => 'Str',
     default => 'HTML::FormHandler::Model::DBIC::TypeMap' );
has 'type_map_args' => ( is => 'ro', isa => 'HashRef', default => sub {{}} );
has 'type_map' => ( is => 'ro', lazy => 1, builder => 'build_type_map',
    handles => ['type_for_column', 'type_for_rel'],
);
sub build_type_map {
    my $self = shift;
    my $class = $self->type_map_class;
    return $class->new( $self->type_map_args );
}

sub model_fields {
    my $self = shift;
    my $fields = $self->get_fields( $self->source_name, 0, @{$self->exclude} );
    return $fields;
}

sub get_fields {
    my( $self, $class, $level, @exclude ) = @_;

    my $source = $self->schema->source( $class );
    my %primary_columns = map {$_ => 1} $source->primary_columns;
    my @fields;
    my @columns = $self->has_includes ? $self->all_includes : $source->columns;
    for my $col ( @columns ) {
        next if grep { $_ eq $col } @exclude;
        my $info = $source->column_info($col);
        my @field;
        if( $primary_columns{$col} &&
            ( $info->{is_auto_increment} || $self->is_SQLite_auto_pk( $source, $info ))){
            # for PK in the root use item_id, here only PKs for related rows
            push @field, ( $col => { type => 'Hidden' } ) if $level > 1;
        }
        else{
            unshift @field, ( $col => $self->type_for_column( $info ) );
       }
       push @fields, @field;
    }
    return \@fields;
}

# in SQLite integer primary key is computed automatically just like auto increment
sub is_SQLite_auto_pk {
    my ( $self, $source, $info ) = @_;
    return if $self->schema->storage->sqlt_type ne 'SQLite';
    return if ( ! lc( $info->{data_type} ) =~ /^int/ );
    my @pks = $source->primary_columns;
    return if scalar @pks > 1;
    return 1;
}

# not yet implemented
sub field_for_rel {
    my ( $self, $name, $info ) = @_;
=pod

    for my $rel( $source->relationships ) {
        next if grep { $_ eq $rel } @exclude;
        next if grep { $_->[1] eq $rel } $self->m2m_for_class($class);
        my $info = $source->relationship_info($rel);
        push @exclude, get_self_cols( $info->{cond} );
        my $rel_class = _strip_class( $info->{class} );
        my $elem_conf;
        if ( ! ( $info->{attrs}{accessor} eq 'multi' ) ) {
            push @fields, "has_field '$rel' => ( type => 'Select', );"
        }
        elsif( $level < 1 ) {
            my @new_exclude = get_foreign_cols ( $info->{cond} );
            my $config = $self->get_fields ( $rel_class, 1, );
            my $target_class = $rel_class;
            $target_class = $self->class_prefix . '::' . $rel_class if $self->class_prefix;
            $config->{class} = $target_class;
            $config->{name} = $rel;
#           $self->set_field_class_data( $target_class => $config ) if !$self->exists_field_class( $target_class );
            my $field_def = '';
#           if( defined $self->style && $self->style eq 'single' ){
#               $field_def .= '# ';
#           }
            $field_def .= "has_field '$rel' => ( type => '+${target_class}Field', );";
            push @fields, $field_def;
        }
    }

=cut

}

1;
