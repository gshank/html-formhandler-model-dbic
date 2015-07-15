package HTML::FormHandler::Generator::DBIC;
# ABSTRACT: form generator for DBIC

use Moose;
use DBIx::Class;
use Template;

=head1 SYNOPSIS

   form_generator.pl --rs_name=Book --schema_name=BookDB::Schema::DB
            --db_dsn=dbi:SQLite:t/db/book.db > BookForm.pm

=head1 DESCRIPTION

Options:

  rs_name       -- Resultset Name
  schema_name   -- Schema Name
  db_dsn        -- dsn connect info
  class_prefix  -- [OPTIONAL] Prefix for generated classes (Default: '')
  label         -- [OPTIONAL] Flag to toggle generation of form labels (Default: 0)
  label_column  -- [OPTIONAL] Flag to toggle generation of dummy form labels_columns for type: 'select' (Default: 0)


This package should be considered still experimental since the output,
of the generated classes will be changed from time to time.  This should
not impact the main usage for this module that we had in mind, that is
generating the initial version of a FormHandler form class, copying
it to the project and modifying it.

This script is installed into the system with the rest of FormHandler.

=cut

has db_dsn => (
    is => 'ro',
    isa => 'Str',
);

has db_user => (
    is => 'ro',
    isa => 'Str',
);

has db_password => (
    is => 'ro',
    isa => 'Str',
);

has 'schema_name' => (
    is  => 'ro',
    isa => 'Str',
);

has 'rs_name' => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

has 'schema' => (
    is  => 'rw',
    lazy_build => 1,
    isa => 'DBIx::Class::Schema',
    required => 1,
);

sub _build_schema {
    my $self = shift;
    my $schema_name = $self->schema_name;
    eval "require $schema_name";
    die $@ if $@;
    return $schema_name->connect( $self->db_dsn, $self->db_user, $self->db_password, );
}

has 'tt' => (
    is => 'ro',
    default => sub { Template->new() },
);

has 'label' => (
    is  => 'ro',
    isa => 'Bool',
    default => 0,
);

has 'label_column' => (
    is  => 'ro',
    isa => 'Bool',
    default => 0,
);

has 'class_prefix' => (
    is => 'ro',
    isa => 'Str',
);

has 'style' => (
    is => 'ro'
);

has 'm2m' => (
    is => 'ro',
);

has 'packages' => (
   traits     => ['Hash'],
   isa        => 'HashRef[Str]',
   is         => 'rw',
   default    => sub { {} },
   auto_deref => 1,
   handles   => {
       used_packages => 'keys',
       _add_package => 'set'
   },
);
sub add_package {
    my ( $self, $package ) = @_;
    $self->_add_package( $package, 1 );
}

has 'field_classes' => (
   traits     => ['Hash'],
   isa        => 'HashRef[HashRef]',
   is         => 'rw',
   default    => sub { {} },
   auto_deref => 1,
   handles   => {
       list_field_classes => 'keys',
       get_field_class_data => 'get',
       exists_field_class => 'exists',
       set_field_class_data => 'set',
   },
);

my $form_template = <<'END';
# Generated automatically with HTML::FormHandler::Generator::DBIC
# Using following commandline:
# form_generator.pl --rs_name=[% rs_name %][% IF label==1 %] --label[% END %][% IF label_column==1 %] --label_column[% END %] --schema_name=[% schema_name %][% IF class_prefix != '' %] --class_prefix=[% class_prefix %][% END %] --db_dsn=[% db_dsn %]
{
    package [% config.class %]Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    use namespace::autoclean;
[% FOR package = self.used_packages %]
    use [% package %];
[% END %]

    has '+item_class' => ( default => '[% rs_name %]' );

    [% FOR field = config.fields -%]
[% field %]
    [% END -%]
has_field 'submit' => ( widget => 'Submit', [% IF label==1 %]label =>'Submit'[% END %]);

    __PACKAGE__->meta->make_immutable;
    no HTML::FormHandler::Moose;
}
[% FOR field_class = self.list_field_classes %]
[% SET cf = self.get_field_class_data( field_class ) %]
{
    package [% cf.class %]Field;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';
    use namespace::autoclean;

    [% FOR field = cf.fields -%]
[% field %]
    [% END %]
    __PACKAGE__->meta->make_immutable;
    no HTML::FormHandler::Moose;
}
[% END %]

END

sub generate_form {
    my ( $self ) = @_;
    my $config = $self->get_config;
    my $output;
    # warn Dumper( $config ); use Data::Dumper;
    my $tmpl_params = {
        self => $self,
        config => $config,
        rs_name => $self->rs_name,
        label => $self->label,
        label_column => $self->label_column,
        schema_name => $self->schema_name,
        class_prefix => $self->class_prefix,
        db_dsn => $self->db_dsn,
    };
    $tmpl_params->{single} = 1 if defined $self->style && $self->style eq 'single';
    $self->tt->process( \$form_template, $tmpl_params, \$output )
                   || die $self->tt->error(), "\n";
    return $output;
}

sub _strip_class {
    my $fullclass = shift;
    my @parts     = split /::/, $fullclass;
    my $class     = pop @parts;
    return $class;
}

sub get_config {
    my( $self ) = @_;
    my $config = $self->get_elements ( $self->rs_name, 0, );
#    push @{$config->{fields}}, {
#        type => 'submit',
#        name => 'foo',
#    };
    my $target_class = $self->rs_name;
    $target_class = $self->class_prefix . '::' . $self->rs_name if $self->class_prefix;
    $config->{class} = $target_class;
    return $config;
}



sub m2m_for_class {
    my( $self, $class ) = @_;
    return if not $self->m2m;
    return if not $self->m2m->{$class};
    return @{$self->m2m->{$class}};
}

my %types = (
    text      => 'TextArea',
    int       => 'Integer',
    integer   => 'Integer',
    num       => 'Number',
    number    => 'Number',
    numeric   => 'Number',
);

sub field_def {
    my( $self, $name, $info ) = @_;
    my $output = '';
    $output .= "has_field '$name' => ( ";
    if( lc $info->{data_type} eq 'date' or lc $info->{data_type} eq 'datetime' ){
        $self->add_package( 'DateTime' );
        $output .= <<'END';

            type => 'Compound',
            apply => [
                {
                    transform => sub{ DateTime->new( $_[0] ) },
                    message => "Not a valid DateTime",
                }
            ],
        );
END
        $output .= "        has_field '$name.$_';" for qw( year month day );
        return $output;
    }
    my $type = $types{ $info->{data_type} } || 'Text';
    $type = 'TextArea' if defined($info->{size}) && $info->{size} > 60;
    $output .= "type => '$type', ";
    $output .= "size => $info->{size}, " if $type eq 'Text' && $info->{size};
    $output .= 'required => 1, ' if not $info->{is_nullable};
    $output .= "label => '".$name."', " if $self->label;
    return $output . ');';
}

sub get_elements {
    my( $self, $class, $level, @exclude ) = @_;
    my $source = $self->schema->source( $class );
    my %primary_columns = map {$_ => 1} $source->primary_columns;
    my @fields;
    my @fieldsets;
    for my $rel( $source->relationships ) {
        next if grep { $_ eq $rel } @exclude;
        next if grep { $_->[1] eq $rel } $self->m2m_for_class($class);
        my $info = $source->relationship_info($rel);
        push @exclude, get_self_cols( $info->{cond} );
        my $rel_class = _strip_class( $info->{class} );
        my $elem_conf;
        if ( ! ( $info->{attrs}{accessor} eq 'multi' ) ) {
            my $field = "has_field '$rel' => ( type => 'Select', ";
            $field .= "label => '".$rel."', " if $self->label;
            $field .= "label_column => 'TO_BE_DONE', " if $self->label_column;
            $field .= ");";
            push @fields, $field;
        }
        elsif( $level < 1 ) {
            my @new_exclude = get_foreign_cols ( $info->{cond} );
            my $config = $self->get_elements ( $rel_class, 1, );
            my $target_class = $rel_class;
            $target_class = $self->class_prefix . '::' . $rel_class if $self->class_prefix;
            $config->{class} = $target_class;
            $config->{name} = $rel;
            $self->set_field_class_data( $target_class => $config ) if !$self->exists_field_class( $target_class );
            my $field_def = '';
            if( defined $self->style && $self->style eq 'single' ){
                $field_def .= '# ';
            }
            $field_def .= "has_field '$rel' => ( type => '+${target_class}Field', );";
            push @fields, $field_def;
        }
    }
    for my $col ( $source->columns ) {
        my $new_element = { name => $col };
        my $info = $source->column_info($col);
        if( $primary_columns{$col}
            && (
                $info->{is_auto_increment}
                # in SQLite integer primary key is computed automatically just like auto increment
                || $self->is_SQLite_auto_pk( $source, $info )
            )
        ){
            # for PK in the root use item_id, here only PKs for related rows
            unshift @fields, "has_field '$col' => ( type => 'Hidden' );" if $level > 1;
        }
        else{
            next if grep { $_ eq $col } @exclude;
            unshift @fields, $self->field_def( $col, $info );
       }
    }
    for my $many( $self->m2m_for_class($class) ){
        unshift @fields, "has_field '$many->[0]' => ( type => 'Select', multiple => 1 );"
    }
    return { fields => \@fields };
}

sub is_SQLite_auto_pk{
    my ( $self, $source, $info ) = @_;
    return if $self->schema->storage->sqlt_type ne 'SQLite';
    return if ! grep $info->{data_type}, qw/INTEGER Integer integer INT Int int/;
    my @pks = $source->primary_columns;
    return if scalar @pks > 1;
    return 1;
}

sub get_foreign_cols{
    my $cond = shift;
    my @cols;
    if ( ref $cond eq 'ARRAY' ){
        for my $c1 ( @$cond ){
            push @cols, get_foreign_cols( $c1 );
        }
    }
    elsif ( ref $cond eq 'HASH' ){
        for my $key ( keys %{$cond} ){
            if( $key =~ /foreign\.(.*)/ ){
                push @cols, $1;
            }
        }
    }
    return @cols;
}

sub get_self_cols{
    my $cond = shift;
    my @cols;
    if ( ref $cond eq 'ARRAY' ){
        for my $c1 ( @$cond ){
            push @cols, get_self_cols( $c1 );
        }
    }
    elsif ( ref $cond eq 'HASH' ){
        for my $key ( values %{$cond} ){
            if( $key =~ /self\.(.*)/ ){
                push @cols, $1;
            }
        }
    }
    return @cols;
}

{
    package HTML::FormHandler::Generator::DBIC::Cmd;
    use Moose;
    extends 'HTML::FormHandler::Generator::DBIC';
         with 'MooseX::Getopt';
    has '+db_dsn'      => ( required => 1 );
    has '+schema_name' => ( required => 1 );
    has '+schema' => ( metaclass => 'NoGetopt' );
    has '+tt' => ( metaclass => 'NoGetopt' );
    has '+m2m' => ( metaclass => 'NoGetopt' );
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
