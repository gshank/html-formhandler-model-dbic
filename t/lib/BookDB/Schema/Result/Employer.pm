package BookDB::Schema::Result::Employer;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("employer");
__PACKAGE__->add_columns(
  "employer_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
  "name",
  { data_type => "VARCHAR", is_nullable => 0, size => 32 },
  "category",
  "country",
  { data_type => "VARCHAR", is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("employer_id");

__PACKAGE__->many_to_many(
    'users' => 'user_employer',
    'user',
);

__PACKAGE__->has_many(
    'user_employer',
    'BookDB::Schema::Result::UserEmployer',
    { 'foreign.employer_id' => 'self.employer_id' },
);

1;
