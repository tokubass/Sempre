use strict;
use warnings;
use utf8;
use Sempre;
use Encode;

my $sp = Sempre->new(
    tags      => [qw/ public unruly /],
);

$sp->message(sub {
    my $post = shift;
    warn Encode::encode_utf8($post->{text}) . "\n";
});

$sp->run();
