#!/usr/bin/perl
package form_generator;
# ABSTRACT: form generator
use strict;
use warnings;

use HTML::FormHandler::Generator::DBIC;
use lib ('lib');

my $generator = HTML::FormHandler::Generator::DBIC::Cmd->new_with_options();

print $generator->generate_form;

