use 5.12.0;
use warnings;

use Test::More;
use Test::Fatal;
use Try::Tiny;

use Data::TagHive;

sub taghive {
  my $taghive = Data::TagHive->new;

  $taghive->add_tag('fauxbox.type:by-seat.seats:17');
  $taghive->add_tag('fauxbox.type:by-seat.aeron');
  $taghive->add_tag('fauxbox.type:by-seat.xyzzy');

  return $taghive;
}

subtest "leaf deletion" => sub {
  my $taghive = taghive;

  $taghive->delete_tag('fauxbox.type:by-seat.xyzzy');

  ok( ! $taghive->has_tag('fauxbox.type:by-seat.xyzzy'), "deletion works" );

  ok( $taghive->has_tag('fauxbox.type:by-seat.aeron'), "aeron still there");
  ok( $taghive->has_tag('fauxbox.type:by-seat.seats:17'), "seats:17 still there");
  ok( $taghive->has_tag('fauxbox.type:by-seat'), "type:by-seat still there");
};

done_testing;
