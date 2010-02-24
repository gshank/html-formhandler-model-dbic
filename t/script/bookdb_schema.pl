#!/usr/bin/env perl
use strict;
use warnings;

use lib ('t/lib');
use BookDB::Schema;

use DBIx::Class::Schema::Loader ('make_schema_at');
make_schema_at(
    'BookDB::Schema',
    {
        debug          => 1,
        dump_directory => './lib',
    },
    [ 'dbi:SLite:t/db/book.db' ],
);

