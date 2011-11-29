package BookDB::Schema::Result::AuthorBooks;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("author_books");
__PACKAGE__->add_columns(
  "book_id",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "author_id",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key(('book_id', 'author_id'));

__PACKAGE__->belongs_to(
  "book",
  "BookDB::Schema::Result::Book",
  { id => "book_id" },
);
__PACKAGE__->belongs_to(
  "author",
  "BookDB::Schema::Result::Author",
  { author_id => "author_id" },
);


1;
