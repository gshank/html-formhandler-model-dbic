package BookDB::Schema::Result::Book;

use Moose;

use base 'DBIx::Class';

# following attribute is non useful, since it does
# nothing that persists, but shows how you could
# do something more complicated
has 'comment' => ( isa => 'Str|Undef', is => 'rw',
  trigger => \&set_extra );

sub set_extra
{
   my ($self, $value) = @_;
   $self->extra($value);
}


BookDB::Schema::Result::Book->load_components("Core");
BookDB::Schema::Result::Book->table("book");
BookDB::Schema::Result::Book->add_columns(
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
  "format",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "borrower",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "borrowed",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "owner",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "extra",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);
BookDB::Schema::Result::Book->set_primary_key("id");
BookDB::Schema::Result::Book->belongs_to(
  "format",
  "BookDB::Schema::Result::Format",
  { id => "format" },
);
BookDB::Schema::Result::Book->belongs_to(
  "borrower",
  "BookDB::Schema::Result::Borrower",
  { id => "borrower" },
);
BookDB::Schema::Result::Book->belongs_to(
  "owner",
  "BookDB::Schema::Result::User",
  { user_id => "owner" },
);
BookDB::Schema::Result::Book->has_many(
  "books_genres",
  "BookDB::Schema::Result::BooksGenres",
  { "foreign.book_id" => "self.id" },
);
BookDB::Schema::Result::Book->many_to_many(
  genres => 'books_genres', 'genre'
);
__PACKAGE__->has_many(
  "book_authors",
  "BookDB::Schema::Result::AuthorBooks",
  { "foreign.book_id" => "self.id" },
);
__PACKAGE__->many_to_many(
  authors => 'book_authors', 'author'
);
__PACKAGE__->add_unique_constraint( 'isbn' => ['isbn'] );

sub author_list {
    my $self = shift;
    my @authors = $self->authors->all;
    my @author_names;
    foreach my $author (@authors) {
        push @author_names, $author->name;
    }
    return join(', ', @author_names);
}

1;
