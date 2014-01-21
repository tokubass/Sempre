package Sempre;
use 5.008005;
use strict;
use warnings;

use Unruly;
our $VERSION = "0.01";

sub new {
    my ($class, %opts) = @_;
    bless {
        unruly      => undef,
        id          => 0,
        post_action => [],
        read_action => [],
        name        => $opts{name} || 'Semper',
        image       => $opts{image} || undef,
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
    $self->{unruly}->login($self->{name}, { image => $self->{image} });

    my $cv = AnyEvent->condvar;

    $self->{unruly}->run(sub {
        my ($client, $socket) = @_;
        $socket->on('user message', sub {
            my $post = $_[1];
    
            return if $post->{is_message_log} || $self->{id} > $post->{id}; # PlusPlus and other.
            $self->{id} = $post->{id};
       
            for my $action (@{$self->{post_action}}) {
                my $word = $self->_run($post => $action);
                $self->_post($word);
            }
            for my $action (@{$self->{read_action}}) {
                $self->_run($post => $action);
            }
        });
    });

    $cv->recv;
}

sub post {
    my $self = shift;
    push @{$self->{post_action}}, [ @_ ];
}

sub read {
    my $self = shift;
    push @{$self->{read_action}}, [ @_ ];
}

sub _run {
    my ($self, $post => $action) = @_;
    my ($cond, $sub_ref) = @{$action};
    $cond = ref($cond) eq 'REGEXP' ? $cond : qr/$cond/;
    
    return ref($sub_ref) eq 'CODE' && $post->{text} =~ $cond
        ? $sub_ref->($post)
        : undef;
}

sub _post {
    my ($self, $word) = @_;
    return unless defined $word;

    $word .= ' ' . join(' ', map { '#' . uc $_ } @{$self->{post_tags}});
    $self->{unruly}->post($word);
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

