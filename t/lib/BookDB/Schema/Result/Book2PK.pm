package BookDB::Schema::Result::Book2PK;

use Moose;
use MIME::Base64;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("book2pk");
__PACKAGE__->add_columns(
  "libraryid",
  { data_type => "INTEGER", is_nullable => 0, default_value => 1, size => undef },
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "isbn",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 100,
    extra => { field_def => { type => 'TextArea', size => '64', temp => 'testing' } },
  },
  "publisher",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "pages",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "year",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("libraryid", "id");
__PACKAGE__->add_unique_constraint( 'isbn' => ['libraryid', 'isbn'] );

1;
