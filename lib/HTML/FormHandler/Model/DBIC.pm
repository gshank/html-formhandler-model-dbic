package HTML::FormHandler::Model::DBIC;
# ABSTRACT: base class that holds DBIC model role

use Moose;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::TraitFor::Model::DBIC';

our $VERSION = '0.12';

use namespace::autoclean;
1;
