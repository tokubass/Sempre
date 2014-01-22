package Sempre;
use 5.008005;
use strict;
use warnings;

use Unruly;
our $VERSION = "0.01";

sub new {
    my ($class, %opts) = @_;

    bless {
        id          => 0,
        name        => $opts{name}      || 'Semper',
        image       => $opts{image}     || undef,
        post_tags   => $opts{post_tags} || [qw/ public /],
        tags        => exists $opts{tags}
            ? { map { $_ => 1 } @{$opts{tags}} }
            : { public => 1 },
    }, $class;
}

sub run {
    my $self = shift;

    $self->{unruly} ||= Unruly->new(
        url  => 'http://yancha.hachiojipm.org',
        tags => $self->{tags},
    );

    my $cv = AnyEvent->condvar;

    $self->{unruly}->run(sub {
        my ($client, $socket) = @_;
        $socket->on('user message', sub {
            return $self->_user_message($_[1]);
        });
        $socket->on('announcement', sub {
            return $self->_announcement($_[1]);
        });
    });

    $cv->recv;
}

sub message {
    my $self = shift;
    push @{$self->{message_action}}, [ @_ ];
}

sub _login {
    my ($self, $image) = @_;
    $image ||= $self->{image};
    $self->{unruly}->login($self->{name}, { image => $image });
}

sub _post {
    my ($self, $word) = @_;
    return unless defined $word;

    $word .= ' ' . join(' ', map { '#' . uc $_ } @{$self->{post_tags}});
    $self->{unruly}->post($word);
}

sub _user_message {
    my ($self, $post) = @_;

    # xxx
    return if $post->{is_message_log} || $self->{id} > $post->{id}; # PlusPlus and other.
    $self->{id} = $post->{id};
    
    for my $action (@{$self->{message_action}}) {
        $self->_user_message_run($post => @{$action});
    }
}

sub _user_message_run {
    my ($self, $post, @action) = @_;
    my $sub_ref = pop @action;
    my $cond    = shift @action; 
    
    return if ref($sub_ref) ne 'CODE';
    return $self->_call($sub_ref, $post) unless defined $cond;

    if (ref($cond) eq 'HASH') {
        return if exists $cond->{text} && $post->{text} !~ /$cond->{text}/;
        return if exists $cond->{nick} && $post->{nickname} !~ /$cond->{nick}/;
    } else {
        return if $post->{text} !~ /$cond/;
    }
    return $self->_call($sub_ref, $post);
}

sub _call {
    my ($self, $sub_ref, @params) = @_;
    my $retval = $sub_ref->(@params);
    
    if (exists $retval->{image}) {
        $self->_login($retval->{image});
    } else {
        $self->_login;
    }
    if (exists $retval->{post}) {
        $self->_post($retval->{post});
    }
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
        return 'こころちゃんって言うなー!';
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

