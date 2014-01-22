# NAME

Sempre - Yancha's bot framework using Unruly

# SYNOPSIS

    use Sempre;

    my $sp = Sempre->new(
        name  => 'KokoroChan',
        tags  => [qw/ public papix /],
        image => 'http://pyazo.hachiojipm.org/image/iIiLNsbaqwuExX8W139033898032943.png',
    );
    

    $sp->post('こころちゃーん' => sub {
        my $post = shift;
        return { post => 'こころちゃんって言うなー!' };
    });

    $sp->run;

# DESCRIPTION

Sempre is Yancha's bot framework.

# LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

papix <mail@papix.net>
