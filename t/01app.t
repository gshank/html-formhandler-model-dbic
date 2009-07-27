use Test::More tests => 2;

use_ok( 'HTML::FormHandler::Model::DBIC' );

SKIP: {
   eval "use Template";
   skip "Template Toolkit not installed", 1 if $@;
   use_ok( 'HTML::FormHandler::Generator::DBIC' );
}

