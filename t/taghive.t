use 5.12.0;
use warnings;

use Test::More;
use Test::Fatal;
use Try::Tiny;

use Data::TagHive;

my $taghive = Data::TagHive->new;

$taghive->add('fauxbox.type:by-seat.seats:17');

my @has = qw(
  fauxbox
  fauxbox.type
  fauxbox.type:by-seat
  fauxbox.type:by-seat.seats
  fauxbox.type:by-seat.seats:17
);

for my $str (@has) {
  ok($taghive->has_tag($str), "has $str");
}

my @hasnt = qw(
  pobox
  fauxbox.type:by-seat.seats:92
);

for my $str (@hasnt) {
  ok(! $taghive->has_tag($str), "hasn't $str");
}

{
  my $error = exception { $taghive->add('fauxbox.type:by-usage') };
  ok($error, "we can't add a tag with a conflicting value");
  like($error, qr/conflict at \Qfauxbox.type\E\b/, "...we get expected error");
}

{
  my $error = exception { $taghive->add('fauxbox.type:by-usage.seats:17') };
  ok($error, "we can't add a tag with a conflicting value");
  like($error, qr/conflict at \Qfauxbox.type\E\b/, "...we get expected error");
}

done_testing;
