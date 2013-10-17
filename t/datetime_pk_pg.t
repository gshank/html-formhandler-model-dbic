use strict;
use warnings;
use Test::Most;
use Test::FailWarnings;
use DateTime;

use lib './t';
use lib 't/lib';

my ($dsn, $dbuser, $dbpass) = @ENV{map { "DBICTEST_PG_${_}" } qw/DSN USER PASS/};

# Need some env variables for the Pg connection. On linux easily configure psql like this:
#
# # 1) start postgres if not running
# service postgresql start # or
# /etc/init.d/postgresql start
# # 2) add a db with your username
# sudo su - postgres
# dropdb yourusername # ok if doesnt exist
# createdb yourusername
#
# # Run this test with env vars:
# DBICTEST_PG_DSN=dbi:Pg:dbname=yourusername DBICTEST_PG_USER=yourusername DBICTEST_PG_PASS="" prove -v -l t/datetime_pk_pg.t


plan skip_all => 'Set $ENV{DBICTEST_PG_DSN}, _USER and _PASS to run this test'
  unless ($dsn && $dbuser);

use_ok('HTML::FormHandler::Field::DateTime');
my $field = HTML::FormHandler::Field::DateTime->new( name => 'test_field' );
ok( defined $field, 'new() called' );

{
    package
        TempSchema::Book;

    use strict;
    use warnings;

    use base qw/DBIx::Class::Core/;

    __PACKAGE__->load_components(qw/InflateColumn::DateTime/);

    __PACKAGE__->table('book');

    __PACKAGE__->add_columns(
        id => { data_type => 'serial'  },
        title => { data_type => 'text' },
    );

    __PACKAGE__->set_primary_key('id');

    __PACKAGE__->has_many(
        "presentations",
        "TempSchema::BookPresentation",
        { "foreign.book" => "self.id" }
    );

    __PACKAGE__->many_to_many(
        "presenters",
        "presentations",
        "presenter"
    );

    package
        TempSchema::Presenter;

    use strict;
    use warnings;

    use base qw/DBIx::Class::Core/;

    __PACKAGE__->load_components(qw/InflateColumn::DateTime/);

    __PACKAGE__->table('presenter');

    __PACKAGE__->add_columns(
        name => { data_type => 'text'  },
    );

    __PACKAGE__->set_primary_key('name');

    __PACKAGE__->has_many(
        "presentations",
        "TempSchema::BookPresentation",
        { "foreign.presenter" => "self.name" }
    );

    __PACKAGE__->many_to_many(
        "books",
        "presentations",
        "book"
    );

    package
        TempSchema::BookPresentation;

    use strict;
    use warnings;

    use base qw/DBIx::Class::Core/;

    __PACKAGE__->load_components(qw/InflateColumn::DateTime/);

    __PACKAGE__->table('book_presentation');

    __PACKAGE__->add_columns(
        book => { data_type => 'integer'  },
        presenter => { data_type => 'text'  },
        date => { data_type => 'date' },
        title => { data_type => 'text' }
    );

    __PACKAGE__->set_primary_key(qw/book presenter date/);

    __PACKAGE__->belongs_to(
        "presenter",
        "TempSchema::Presenter",
        { name => "presenter" }
    );

    __PACKAGE__->belongs_to(
        "book",
        "TempSchema::Book",
        { id => "book" }
    );

    package
        TempSchema;

    use strict;
    use warnings;

    use base 'DBIx::Class::Schema';

    __PACKAGE__->load_classes("Book", "Presenter", "BookPresentation");

}

isa_ok( my $schema = TempSchema->connect($dsn, $dbuser, $dbpass, { AutoCommit => 1 }), "TempSchema" );
ok( my $dbh = $schema->storage->dbh, "dbh" );

## setup the tables
{
    local $SIG{__WARN__} = sub {};

    $dbh->do('DROP TABLE IF EXISTS book_presentation');
    $dbh->do('DROP TABLE IF EXISTS book');
    $dbh->do('DROP TABLE IF EXISTS presenter');

    $dbh->do(qq[
        CREATE TABLE book
        (
          title text not null,
          id serial primary key
        );
    ],{ RaiseError => 1, PrintError => 1 });

    $dbh->do(qq[
        CREATE TABLE presenter
        (
          name text primary key
        );
    ],{ RaiseError => 1, PrintError => 1 });

    $dbh->do(qq[
        CREATE TABLE book_presentation
        (
          book integer references book not null,
          presenter text references presenter not null,
          date date not null,
          title text not null,
          primary key (book, presenter, date)
        );
    ],{ RaiseError => 1, PrintError => 1 });
}



isa_ok( my $book_a = $schema->resultset("Book")->create( { title => "Book A" } ),
        "DBIx::Class::Row", "a created book"
    );

isa_ok( my $book_b = $schema->resultset("Book")->create( { title => "Book B" } ),
        "DBIx::Class::Row", "another created book"
    );

isa_ok( my $presenter_1 = $schema->resultset("Presenter")->create( { name => "Dude 1" } ),
        "DBIx::Class::Row", "a registered presenter"
    );

my $pres_a = $book_a->create_related( "presentations",
                                    {
                                        presenter => "Dude 1",
                                        title => "Speech on the fabulous Book A",
                                        date => "2013-10-16",
                                    }
                                );

isa_ok( $pres_a, "DBIx::Class::Row", "the presentation of book a" );

my $pres_b = $book_b->create_related( "presentations",
                                    {
                                        presenter => "Dude 1",
                                        title => "Speech on the fabulous Book A",
                                        date => "2013-10-16",
                                    }
                                );

isa_ok( $pres_b, "DBIx::Class::Row", "the presentation of book b" );

is( scalar($presenter_1->presentations), 2, "presenter now has a given number of talks" );

## empty it:
lives_ok {
    $schema->resultset("BookPresentation")->delete;
    $schema->resultset("Presenter")->delete;
    $schema->resultset("Book")->delete;
} "the database can be emptied";

## now create data with form handler:


{
    package BookForm;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

    has_field 'title'                   => ( type => 'Text' );

    has_field 'presentations'           => ( type => 'Repeatable' );
    has_field 'presentations.presenter' => ( type => 'Text' );
    has_field 'presentations.date'      => ( type => 'Date' );
    has_field 'presentations.title'     => ( type => 'Text' );

}

## Create a book using the form

isa_ok( my $book_c = $schema->resultset("Book")->new_result({}),
        "DBIx::Class::Row",
        "book without data" );
isa_ok( my $form = BookForm->new, "BookForm", "the HFH" );

$form->process( item => $book_c, params => { title => "Book C" } );
ok( $book_c->in_storage, "Book's db status after processing" );

## Create a new presentor - not using a form.

isa_ok( my $presenter_2 = $schema->resultset("Presenter")->create( { name => "Dude 2" } ),
        "DBIx::Class::Row", "a new registered presenter"
    );

## make sure both the book and presenter doesnt have any presentations

is( $book_c->presentations, 0, "book c has no presentations" );
is( $presenter_2->presentations, 0, "dude 2 has no presentations" );

## Edit the book, add a presentation

my $form2 = BookForm->new; ## assume ok
$form2->process( item => $book_c );

is( $form2->field("title")->value, "Book C", "Book loaded in form" );

## simulate a submit, with added presenter

warning_is {
    $form2->process( item => $book_c, params => {
        title => "Book C", # unchanged
        "presentations.0.presenter" => "Dude 2",
        "presentations.0.date" => "2013-10-16", ## date in the far future
        "presentations.0.title" => "The incredible Book C!",
    });
} undef, "An infinity date can be stored as a PK without warnings";

ok( $form2->validated, "form is valid" );

## both book and presenter now have a presentation
is( $book_c->presentations, 1, "book c has a presentation" );
is( $presenter_2->presentations, 1, "dude 2 has a presentation" );

done_testing;

eval { $schema->storage->dbh_do(
    sub {
        $_[1]->do("DROP TABLE book_presentation");
        $_[1]->do("DROP TABLE presenter");
        $_[1]->do("DROP TABLE book");
    }
)};
