use 5.12.0;
use warnings;

package Data::TagHive;
# ABSTRACT: hierarchical tags with values

use Carp;

sub new {
  my ($class) = @_;

  return bless { state => {} } => $class;
}

my $tagname_re  = qr{ [a-z] [-a-z0-9_]* }x;
my $tagvalue_re = qr{ [-a-z0-9_]+ }x;
my $tagpair_re  = qr{ $tagname_re (?::$tagvalue_re)? }x;
my $tagstr_re   = qr{ \A $tagpair_re (?:\.$tagpair_re)* \z }x;

sub _assert_tagstr {
  my ($self, $tagstr) = @_;
  croak "invalid tagstr <$tagstr>" unless $tagstr =~ $tagstr_re;
}

sub _tag_pairs {
  my ($self, $tagstr) = @_;

  $self->_assert_tagstr($tagstr);

  my @tags = map { my @pair = split /:/, $_; $#pair = 1; \@pair }
             split /\./, $tagstr;

  return @tags;
}

sub __differ {
  my ($x, $y) = @_;

  return 1 if defined $x xor defined $y;
  return unless defined $x;

  return $x ne $y;
}

sub add_tag {
  my ($self, $tagstr) = @_;

  my $state = $self->{state};

  my @tags  = $self->all_tags;
  my @pairs = $self->_tag_pairs($tagstr);

  my $stem = '';

  while (my $pair = shift @pairs) {
    $stem .= '.' if length $stem;

    my $key   = $stem . $pair->[0];
    my $value = length($pair->[1]) ? $pair->[1] : undef;

    CONFLICT: {
      if (exists $state->{ $key }) {
        my $existing = $state->{ $key };

        # Easiest cases: if they're both undef, or are eq, no conflict.
        last CONFLICT unless __differ($value, $existing);

        # Easist conflict case: we want to set tag:value1 but tag:value2 is
        # already set.  No matter whether there are descendants on either side,
        # this is a
        # conflict.
        croak "can't add <$tagstr> to taghive; conflict at $key"
          if defined $value and defined $existing and $value ne $existing;


        my $more_to_set = defined($value)         || @pairs;
        my $more_exists = defined($state->{$key}) || grep { /\A\Q$key./ } @tags;

        croak "can't add <$tagstr> to taghive; conflict at $key"
          if $more_to_set and $more_exists;
      }
    }


    $state->{ $key } = $value;

    $stem = defined $value ? "$key:$value" : $key;

    $state->{$stem} = undef;
  }
}

sub has_tag {
  my ($self, $tagstr) = @_;

  my $state = $self->{state};

  $self->_assert_tagstr($tagstr);
  return 1 if exists $state->{$tagstr};
  return;
}

sub delete_tag {
  my ($self, $tagstr) = @_;

  $self->_assert_tagstr($tagstr);

  my $state = $self->{state};
  my @keys  = grep { /\A$tagstr(?:$|[.:])/ } keys %$state;
  delete @$state{ @keys };

  if ($tagstr =~ s/:($tagvalue_re)\z//) {
    delete $state->{ $tagstr } if $state->{$tagstr} // '' eq $1;
  }
}

sub all_tags {
  my ($self) = @_;
  return keys %{ $self->{state} };
}

1;
