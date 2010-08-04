package BookDB::Schema::Result::BooksGenres;

use strict;
use warnings;

use base 'DBIx::Class';

BookDB::Schema::Result::BooksGenres->load_components("Core");
BookDB::Schema::Result::BooksGenres->table("books_genres");
BookDB::Schema::Result::BooksGenres->add_columns(
  "book_id",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "genre_id",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
);
BookDB::Schema::Result::BooksGenres->set_primary_key(('book_id', 'genre_id'));

BookDB::Schema::Result::BooksGenres->belongs_to(
  "book",
  "BookDB::Schema::Result::Book",
  { id => "book_id" },
);
BookDB::Schema::Result::BooksGenres->belongs_to(
  "genre",
  "BookDB::Schema::Result::Genre",
  { id => "genre_id" },
);


1;
