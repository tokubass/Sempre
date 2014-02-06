package Sempre;
use 5.008005;
use strict;
use warnings;
use parent 'Exporter';

use Carp;
use AnyEvent;
use Sempre::Bot;

our $VERSION = "0.01";
our @EXPORT = qw/
    bot
    image
    tags
    post_tags
    action
    run
    token_only
/;
our $BOT;
our $UNRULY; 

sub bot {
    my ($name, $code) = @_;

    my ($image, $token_only, @tags, @post_tags, @action);

    my $dest_class = caller();
    no strict 'refs';
    local *{"$dest_class\::image"}      = sub ($) { $image      = shift };
    local *{"$dest_class\::tags"}       = sub (@) { @tags       = @_ };
    local *{"$dest_class\::post_tags"}  = sub (@) { @post_tags  = @_ };
    local *{"$dest_class\::token_only"} = sub (@) { $token_only = shift || 0 };
    local *{"$dest_class\::action"}     = sub (@) { push @action, [ @_ ] };

    $code->();

    my $bot = Sempre::Bot->new(
        name       => $name,
        image      => $image,
        token_only => $token_only,
        tags       => \@tags,
        post_tags  => \@post_tags,
    );
    $bot->action(@{$_}) for @action;
    $bot->init;
    
    push @{$BOT}, $bot;
}

sub run {
    my $cv = AnyEvent->condvar;
    $cv->recv;
}

1;

__END__

sub message {
    my $self = shift;
    push @{$self->{message_action}}, [ @_ ];
}

sub _post {
    my ($self, $word) = @_;
    return unless defined $word;

    $word .= ' ' . join(' ', map { '#' . uc $_ } @{$self->{post_tags}});
    $self->{unruly}->post($word);
}


sub _call {
    my ($self, $sub_ref, @params) = @_;
    my $retval = $sub_ref->(@params);
  
    return if ref($retval) ne 'HASH';
    return unless defined $retval;

    $self->_post($retval->{post}) if exists $retval->{post};
}

1;

__END__

=encoding utf-8

=head1 NAME

Sempre - Yancha's bot framework using Unruly

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Sempre is Yancha's bot framework.

=head1 LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

papix E<lt>mail@papix.netE<gt>

=cut

