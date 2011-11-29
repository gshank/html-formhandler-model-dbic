package BookDB::Schema::Result::Options;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("options");

__PACKAGE__->add_columns(
  "options_id",
  {
    data_type => "smallint",
    default_value => undef,
    is_auto_increment => 1,
    is_nullable => 0,
    size => 38,
  },
  "option_one",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "option_two",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "option_three",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "user_id",
  {
    data_type => "INTEGER",
    is_nullable => 0,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("options_id");
__PACKAGE__->add_unique_constraint(
  "unique_user_id",
  ["user_id"],
);
__PACKAGE__->belongs_to(
    'user',
    'BookDB::Schema::Result::User',
    { user_id => 'user_id' },
);

1;
