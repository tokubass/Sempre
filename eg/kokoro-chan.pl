use strict;
use warnings;
use utf8;
use Sempre;

my $sp = Sempre->new(
    name      => 'KokoroChan',
    tags      => [qw/ public unruly /],
    image     => 'http://pyazo.hachiojipm.org/image/iIiLNsbaqwuExX8W139033898032943.png',
    post_tags => [qw/ public /],
);

$sp->post(qr/(こころ|小衣)(ちゃ|た)ーん/ => sub {
    my $post = shift;
    return 'こころちゃんって言うなー!';
});

$sp->post('父さんだけに倒産' => sub {
    my $post = shift;
    return 'くうきよめー';
});

$sp->run();
