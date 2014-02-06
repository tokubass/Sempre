use strict;
use warnings;
use utf8;
use Sempre;
use Encode;

bot 'KokoroChan' => sub {
    image     'http://pyazo.hachiojipm.org/image/iIiLNsbaqwuExX8W139033898032943.png';
    tags      qw/ public unruly /;
    post_tags qw/ public /;
    action    qr/(こころ|小衣)(ちゃ|た)ーん/ => sub {
        my $post = shift;
        return { post => 'こころちゃんって言うなー!' };
    };
    action    '父さんだけに倒産' => sub {
        my $post = shift;
        return { post => 'くうきよめー' };
    };
};

run();
