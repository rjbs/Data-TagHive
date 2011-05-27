use 5.12.0;
use warnings;

use Test::More;
use Test::Fatal;
use Try::Tiny;

use lib 't/lib';
use Test::TagHive;

sub _init_taghive {
  new_taghive;

  taghive->add_tag('fauxbox.type:by-seat.seats:17');
  taghive->add_tag('fauxbox.type:by-seat.aeron');
  taghive->add_tag('fauxbox.type:by-seat.xyzzy');
}

subtest "leaf deletion" => sub {
  _init_taghive;

  taghive->delete_tag('fauxbox.type:by-seat.xyzzy');

  hasnt_tag('fauxbox.type:by-seat.xyzzy');
  has_tag('fauxbox.type:by-seat.aeron');
  has_tag('fauxbox.type:by-seat.seats:17');
  has_tag('fauxbox.type:by-seat');
};

done_testing;
