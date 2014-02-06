use strict;
use warnings;
use utf8;
use Sempre::Bot;
use AnyEvent;

my $bot = Sempre::Bot->new(
    name      => 'KokoroChan',
    tags      => [qw/ public unruly /],
    image     => 'http://pyazo.hachiojipm.org/image/iIiLNsbaqwuExX8W139033898032943.png',
    post_tags => [qw/ public /],
);

$bot->action(qr/(こころ|小衣)(ちゃ|た)ーん/ => sub {
    my $post = shift;
    return { post => 'こころちゃんって言うなー!' };
});

$bot->action('父さんだけに倒産' => sub {
    my $post = shift;
    return { post => 'くうきよめー' };
});

$bot->run();
