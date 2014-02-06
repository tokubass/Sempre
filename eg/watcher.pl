use strict;
use warnings;
use utf8;
use Sempre::Bot;
use Encode;

my $bot = Sempre::Bot->new(
    tags => [qw/ public unruly /],
);

$bot->action(sub {
    my $post = shift;
    warn Encode::encode_utf8($post->{text}) . "\n";
});

$bot->run();
