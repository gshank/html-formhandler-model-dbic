package BookDB::Schema::Result::Genre;

use strict;
use warnings;

use base 'DBIx::Class';

BookDB::Schema::Result::Genre->load_components("Core");
BookDB::Schema::Result::Genre->table("genre");
BookDB::Schema::Result::Genre->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "is_active",
  { data_type => 'INTEGER', is_nullable => 1 },
);
BookDB::Schema::Result::Genre->set_primary_key("id");
BookDB::Schema::Result::Genre->has_many(
  "books_genres",
  "BookDB::Schema::Result::BooksGenres",
  { "foreign.genre_id" => "self.id" },
);
BookDB::Schema::Result::Genre->many_to_many(
  books => 'books_genres', 'book'
);


1;
