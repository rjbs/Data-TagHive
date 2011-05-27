use 5.12.0;
use warnings;

package Data::TagHive;
use Carp;

sub new {
  my ($class) = @_;

  return bless { state => {} } => $class;
}

my $tagname_re  = qr{ [a-z] [-a-z0-9_]* }x;
my $tagvalue_re = qr{ [-a-z0-9_]+ }x;
my $tagpair_re  = qr{ $tagname_re (?::$tagvalue_re)? }x;
my $tagstr_re   = qr{ \A $tagpair_re (?:\.$tagpair_re)* \z }x;

sub _tag_pairs {
  my ($self, $tagstr) = @_;

  croak "invalid tagstr <$tagstr>" unless $tagstr =~ $tagstr_re;
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

sub add {
  my ($self, $tagstr) = @_;

  my $state = $self->{state};

  my $stem = '';
  for my $pair ($self->_tag_pairs($tagstr)) {
    $stem .= '.' if length $stem;

    my $key   = $stem . $pair->[0];
    my $value = length($pair->[1]) ? $pair->[1] : undef;

    croak "can't add <$tagstr> to taghive; conflict at $key"
      if exists $state->{ $key } and __differ($value, $state->{$key});

    $state->{ $key } = $value;

    $stem = defined $value ? "$key:$value" : $key;
  }
}

sub has_tag {
  my ($self, $tagstr) = @_;

  my $state = $self->{state};

  croak "invalid tagstr <$tagstr>" unless $tagstr =~ $tagstr_re;
  return 1 if exists $state->{$tagstr};

  return unless $tagstr =~ s/:($tagvalue_re)\z//;
  my $value = $1;

  return unless exists $state->{$tagstr};

  return 1 if ! defined $state->{$tagstr};
  return 1 if $state->{$tagstr} eq $value;

  return;
}

1;
