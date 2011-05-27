use 5.12.0;
use warnings;

use Test::More;
use Test::Fatal;
use Try::Tiny;

use lib 't/lib';
use Test::TagHive;

use Data::TagHive;

set_taghive( Data::TagHive->new );

taghive->add_tag('fauxbox.type:by-seat.seats:17');

has_tag($_) for qw(
  fauxbox
  fauxbox.type
  fauxbox.type:by-seat
  fauxbox.type:by-seat.seats
  fauxbox.type:by-seat.seats:17
);

hasnt_tag($_) for qw(
  pobox
  fauxbox.type:by-seat.seats:92
);

{
  my $error = exception { taghive->add_tag('fauxbox.type:by-usage') };
  ok($error, "we can't add a tag with a conflicting value");
  like($error, qr/conflict at \Qfauxbox.type\E\b/, "...we get expected error");
}

{
  my $error = exception { taghive->add_tag('fauxbox.type:by-usage.seats:17') };
  ok($error, "we can't add a tag with a conflicting value");
  like($error, qr/conflict at \Qfauxbox.type\E\b/, "...we get expected error");
}

{
  my $error = exception { taghive->add_tag('fauxbox:foo'); };
  ok($error, "we can't add a tag with a value when there was no value");
  like($error, qr/conflict at fauxbox\b/, "...we get expected error");
}

{
  my $error = exception { taghive->add_tag('fauxbox.type.xyz'); };
  ok($error, "can't add descend with no value where one is already present");
  like($error, qr/conflict at \Qfauxbox.type\E\b/, "...we get expected error");
}

for my $method (qw(add_tag has_tag)) {
  my $error = exception { taghive->$method('not a tag!'); };
  ok($error, "can't pass invalid tag to $method");
  like($error, qr/invalid tagstr/, "...we get expected error");
}

done_testing;
