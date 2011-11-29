BEGIN TRANSACTION;
CREATE TABLE user (
   user_id INTEGER PRIMARY KEY,
   user_name VARCHAR(32),
   fav_cat VARCHAR(32),
   fav_book VARCHAR(32),
   occupation VARCHAR(32),
   country_iso char(2),
   birthdate DATETIME,
   opt_in INTEGER,
   license_id INTEGER
);
INSERT INTO "user" VALUES ( 1, 'jdoe', 'Sci-Fi', 'Necronomicon', 'management', 'US', '1970-04-23 21:06:00', 0, 3 );
INSERT INTO "user" VALUES ( 2, 'muffet', 'Fantasy', 'Cooking Fungi', 'none', 'GB', '1983-10-24 22:22:22', 0, 2 );
INSERT INTO "user" VALUES ( 3, 'sam', 'Technical', 'Higher Order Perl', 'programmer', 'US', '1973-05-24 22:22:22', 1, 3 );
INSERT INTO "user" VALUES ( 4, 'jsw', 'Historical', 'History of the World', 'unemployed', 'RU', '1965-03-24 22:22:22', 0, 4 );
INSERT INTO "user" VALUES ( 5, 'plax', 'Sci-Fi', 'Fungibility', 'editor', 'PL', '1977-10-24 22:22:22', 1, 1 );

CREATE TABLE options (
    options_id INTEGER PRIMARY KEY,
    option_one VARCHAR(32),
    option_two VARCHAR(32),
    option_three VARCHAR(32),
    user_id INTEGER
);
INSERT INTO "options" VALUES (1, 'blue', 'red', 'green', 1);
INSERT INTO "options" VALUES (2, 'orange', 'purple', 'yellow', 2);
INSERT INTO "options" VALUES (3, 'green', 'sky blue', 'fuchsia', 3);
INSERT INTO "options" VALUES (4, 'turquoise', 'teal', 'pumpkin', 4);
INSERT INTO "options" VALUES (5, 'gray', 'brown', 'black', 5);

CREATE table licenses (
   license_id INTEGER,
   name VARCHAR(32),
   label VARCHAR(32),
   active INTEGER
);
INSERT INTO "licenses" VALUES (1, "Perl Artistic", "Perl Artistic License", 1  );
INSERT INTO "licenses" VALUES (2, "GPL", "GNU General Public License", 1 );
INSERT INTO "licenses" VALUES (3, "LGPL", "GNU Lesser Public License", 1 );
INSERT INTO "licenses" VALUES (4, "Creative Commons", "Creative Commons Attribution license", 1 );

CREATE TABLE user_employer (
   user_id INTEGER,
   employer_id INTEGER
);

INSERT INTO "user_employer" VALUES ( 1, 1 );
INSERT INTO "user_employer" VALUES ( 1, 2 );
INSERT INTO "user_employer" VALUES ( 1, 3 );
INSERT INTO "user_employer" VALUES ( 2, 4 );
INSERT INTO "user_employer" VALUES ( 4, 3 );

CREATE TABLE employer (
   employer_id INTEGER PRIMARY KEY,
   name VARCHAR(32),
   category VARCHAR(32),
   country VARCHAR(24)
);

INSERT INTO "employer" VALUES ( 1, "Best Perl", "Perl", "US" );
INSERT INTO "employer" VALUES ( 2, "Worst Perl", "Programming", "UK" );
INSERT INTO "employer" VALUES ( 3, "Convoluted PHP", "Programming", "DE" );
INSERT INTO "employer" VALUES ( 4, "Contractor Heaven", "Losing", "DE" );


CREATE TABLE address (
   address_id INTEGER PRIMARY KEY,
   user_id INTEGER,
   street VARCHAR(32),
   city VARCHAR(32),
   country_iso char(2)
);
INSERT INTO "address" VALUES (1, 1, "101 Main St", "Middle City", "GK");
INSERT INTO "address" VALUES (2, 1, "99 Elm St", "DownTown", "UT");
INSERT INTO "address" VALUES (3, 1, "1023 Side Ave", "Santa Lola", "GF");
INSERT INTO "address" VALUES (4, 2, "142 Main St", "Middle City", "GK");
INSERT INTO "address" VALUES (5, 2, "399 Cherry Park", "Jimsville", "UT");
INSERT INTO "address" VALUES (6, 3, "991 Star St", "Nowhere City", "GK");

CREATE TABLE book (
    id INTEGER PRIMARY KEY,
    isbn varchar(100),
    title varchar(100),
    publisher varchar(100),
    pages int,
    year int,
    format int REFERENCES format,
    genre int REFERENCES genre,
    borrower int REFERENCES borrower,
    borrowed varchar(100),
    owner int REFERENCES user,
    extra varchar(100)
);

CREATE INDEX book_idx_borrower ON book (borrower);
CREATE INDEX book_idx_format ON book (format);
CREATE INDEX book_idx_owner ON book (owner);
CREATE UNIQUE INDEX isbn ON book (isbn);

INSERT INTO "book" VALUES(1, '0-7475-5100-6', 'Harry Potter and the Order of the Phoenix', 'Boomsbury', 766, 2001, 1, 5, 1, '', 2, '');
INSERT INTO "book" VALUES(2, '9 788256006199', 'Idioten', 'Interbook', 303, 1901, 2, 3, 2, '2004-00-10', 2, '');
INSERT INTO "book" VALUES(3, '434012386', 'The Confusion', 'Heinemann', 345, 2002, 2, NULL, 2, '2009-01-16', 1, '');
INSERT INTO "book" VALUES(4, '782128254', 'The Complete Java 2 Certification Study Guide: Programmer''s and Developers Exams (With CD-ROM)', 'Sybex Inc', NULL, 1999, NULL, NULL, NULL, NULL, 3, '');
INSERT INTO "book" VALUES(5, '123-1234-0-123', 'Winnie The Pooh', 'Houghton Mifflin', 345, 1935, 2, NULL, 4, '2008-11-14', 5, '');
INSERT INTO "book" VALUES(6, '0-596-10092-2', 'Perl Testing: A Developer''s Notebook', 'O''Reilly', 182, 2005, 3, NULL, 2, '2009-01-16', 3, '');
INSERT INTO "book" VALUES(7, '0-7475-8134-6', 'Harry Potter and the Last Gasp', 'Boomsbury', 801, 2005, 1, 5, 1, '', 2, '');

CREATE TABLE author (
   author_id INTEGER PRIMARY KEY,
   first_name VARCHAR(100),
   last_name VARCHAR(100),
   country_iso char(2),
   birthdate DATETIME
);
INSERT INTO "author" VALUES (1, "J.K.", "Rowling", "GB", "2003-01-16 00:00:00" );
INSERT INTO "author" VALUES (2, "Fyodor", "Dostoyevsky", "RU", "1821-11-11 00:00:00" );
INSERT INTO "author" VALUES (3, "Neil", "Stephenson", "US", "1959-10-31 00:00:00" );
INSERT INTO "author" VALUES (4, "Simon", "Roberts", "UK", "1975-05-01 00:00:00" );
INSERT INTO "author" VALUES (5, "Philip", "Heller", "US", "1976-01-01 00:00:00" );
INSERT INTO "author" VALUES (6, "Michael", "Ernest", "UK", "1970-10-01 00:00:00" );
INSERT INTO "author" VALUES (7, "A.A.", "Milne", "UK", "1904-08-09 00:00:00" );
INSERT INTO "author" values (8, "", "chromatic", "UK", "1969-10-01 00:00:00" );
INSERT INTO "author" values (9, "Ian", "Langworth", "UK", "1971-12-22 00:00:00" );


CREATE TABLE author_books (
    author_id INTEGER,
    book_id INTEGER,
    PRIMARY KEY (author_id, book_id)
);

INSERT INTO author_books (author_id, book_id) VALUES (1, 1);
INSERT INTO author_books (author_id, book_id) VALUES (1, 7);
INSERT INTO author_books (author_id, book_id) VALUES (2, 2);
INSERT INTO author_books (author_id, book_id) VALUES (3, 3);
INSERT INTO author_books (author_id, book_id) VALUES (4, 4);
INSERT INTO author_books (author_id, book_id) VALUES (5, 4);
INSERT INTO author_books (author_id, book_id) VALUES (6, 4);
INSERT INTO author_books (author_id, book_id) VALUES (7, 5);

CREATE TABLE borrower (
    id INTEGER PRIMARY KEY,
    name varchar(100),
    phone varchar(20),
    url varchar(100),
    email varchar(100),
    active integer
);
INSERT INTO "borrower" VALUES(1, 'In Shelf', NULL, '', '', 0);
INSERT INTO "borrower" VALUES(2, 'Ole Øyvind Hove', '23 23 14 97', 'http://thefeed.no/oleo', 'oleo@trenger.ro', 1);
INSERT INTO "borrower" VALUES(3, 'John Doe', '607-222-3333', 'http://www.somewhere.com/', 'john@gmail.com', 1);
INSERT INTO "borrower" VALUES(4, 'Mistress Muffet', '999-000-2222', NULL, 'muffet@tuffet.org', 1);
CREATE TABLE format (
    id INTEGER PRIMARY KEY,
    name varchar(100)
);
INSERT INTO "format" VALUES(1, 'Paperback');
INSERT INTO "format" VALUES(2, 'Hardcover');
INSERT INTO "format" VALUES(3, 'Comic');
INSERT INTO "format" VALUES(4, 'Trade');
INSERT INTO "format" VALUES(5, 'Graphic Novel');
INSERT INTO "format" VALUES(6, 'E-book');
CREATE TABLE books_genres (
   book_id INTEGER REFERENCES book,
   genre_id INTEGER REFERENCES genre,
   primary key (book_id, genre_id)
);
INSERT INTO "books_genres" VALUES(1, 5);
INSERT INTO "books_genres" VALUES(1, 3);
INSERT INTO "books_genres" VALUES(2, 9);
INSERT INTO "books_genres" VALUES(5, 5);
INSERT INTO "books_genres" VALUES(3, 1);
INSERT INTO "books_genres" VALUES(6, 3);
INSERT INTO "books_genres" VALUES(6, 2);
CREATE TABLE genre (
    id INTEGER PRIMARY KEY,
    name varchar(100),
    is_active INTEGER
);
INSERT INTO "genre" VALUES(1, 'Sci-Fi', NULL);
INSERT INTO "genre" VALUES(2, 'Computers', NULL);
INSERT INTO "genre" VALUES(3, 'Mystery', NULL);
INSERT INTO "genre" VALUES(4, 'Historical', NULL);
INSERT INTO "genre" VALUES(5, 'Fantasy', NULL);
INSERT INTO "genre" VALUES(6, 'Technical', NULL);
CREATE TABLE author_old (
   first_name VARCHAR(100),
   last_name VARCHAR(100),
   country_iso char(2),
   birthdate DATETIME,
   foo VARCHAR(24),
   bar VARCHAR(24),
   CONSTRAINT name PRIMARY KEY (first_name, last_name)
);
CREATE UNIQUE INDEX unique_foo_bar ON author_old (foo, bar);
INSERT INTO "author_old" VALUES ("J.K.", "Rowling", "GB", "2003-01-16 00:00:00", 'foo0', 'bar0' );
INSERT INTO "author_old" VALUES ("Fyodor", "Dostoyevsky", "RU", "1821-11-11 00:00:00", 'foo1', 'bar1' );
INSERT INTO "author_old" VALUES ("Neil", "Stephenson", "US", "1959-10-31 00:00:00", 'foo2', 'foo3' );

-- iso_country_list.sql
--
-- This will create and then populate a MySQL table with a list of the names and
-- ISO 3166 codes for countries in existence as of the date below.
--
-- Usage:
--    mysql -u username -ppassword database_name < ./iso_country_list.sql
--
-- For updates to this file, see http://27.org/isocountrylist/
-- For more about ISO 3166, see http://www.iso.ch/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html
--
-- Created by getisocountrylist.pl on Sun Nov  2 14:59:20 2003.
-- Wm. Rhodes <iso_country_list@27.org>
--

CREATE TABLE IF NOT EXISTS country (
  iso CHAR(2) NOT NULL PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  printable_name VARCHAR(80) NOT NULL,
  iso3 CHAR(3),
  numcode SMALLINT
);

DELETE from country;

INSERT INTO country VALUES ('GK','GRAUSTARK','Graustark','GRA','901');
INSERT INTO country VALUES ('UT','UTOPIA','Utopia','UTO','902');
INSERT INTO country VALUES ('GF','GRAND FENWICK','Grand Fenwick','GFK','903');
INSERT INTO country VALUES ('AT','ATLANTIS','Atlantis','ATL','904');
INSERT INTO country VALUES ('AU','AUSTRALIA','Australia','AUS','036');
INSERT INTO country VALUES ('CZ','CZECH REPUBLIC','Czech Republic','CZE','203');
INSERT INTO country VALUES ('DK','DENMARK','Denmark','DNK','208');
INSERT INTO country VALUES ('FR','FRANCE','France','FRA','250');
INSERT INTO country VALUES ('DE','GERMANY','Germany','DEU','276');
INSERT INTO country VALUES ('PL','POLAND','Poland','POL','616');
INSERT INTO country VALUES ('PT','PORTUGAL','Portugal','PRT','620');
INSERT INTO country VALUES ('RO','ROMANIA','Romania','ROM','642');
INSERT INTO country VALUES ('RU','RUSSIAN FEDERATION','Russian Federation','RUS','643');
INSERT INTO country VALUES ('GB','UNITED KINGDOM','United Kingdom','GBR','826');
INSERT INTO country VALUES ('US','UNITED STATES','United States','USA','840');
INSERT INTO country VALUES ('ZW','ZIMBABWE','Zimbabwe','ZWE','716');


--
-- Table: pages
--

CREATE TABLE pages (
  id INTEGER PRIMARY KEY NOT NULL,
  display_value VARCHAR2(30) NOT NULL,
  description VARCHAR2(200),
  modified_date TIMESTAMP(11),
  created_date TIMESTAMP(11) NOT NULL DEFAULT 'systimestamp'
);

--
-- Table: roles_pages
--

CREATE TABLE roles_pages (
  role_fk NUMBER(38) NOT NULL,
  page_fk NUMBER(38) NOT NULL,
  edit_flag NUMBER(38) NOT NULL DEFAULT '0 ',
  created_date TIMESTAMP(11) NOT NULL DEFAULT 'systimestamp',
  PRIMARY KEY (role_fk, page_fk)
);

CREATE INDEX roles_pages_idx_page_fk ON roles_pages (page_fk);

CREATE TABLE roles (
  id INTEGER PRIMARY KEY NOT NULL,
  display_value VARCHAR2(30) NOT NULL,
  description VARCHAR2(200),
  active smallint(38) NOT NULL DEFAULT '1 ',
  modified_date TIMESTAMP(11),
  created_date DATETIME(11) NOT NULL DEFAULT 'systimestamp'
);

CREATE UNIQUE INDEX unique_role ON roles (display_value);

COMMIT;
