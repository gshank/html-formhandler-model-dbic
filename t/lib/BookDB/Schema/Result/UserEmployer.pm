package BookDB::Schema::Result::UserEmployer;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_employer");
__PACKAGE__->add_columns(
  "employer_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
  "user_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
);
__PACKAGE__->set_primary_key("employer_id", "user_id");

__PACKAGE__->belongs_to(
    'user',
    'BookDB::Schema::Result::User',
    { user_id => 'user_id' },
);
__PACKAGE__->belongs_to(
    'employer',
    'BookDB::Schema::Result::Employer',
    { employer_id => 'employer_id' },
);


1;
