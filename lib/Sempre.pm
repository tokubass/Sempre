package Sempre;
use 5.008005;
use strict;
use warnings;

use Carp;
use Unruly;

our $VERSION = "0.01";

sub new {
    my ($class, %opts) = @_;

    my $url = $ENV{PERL_SEMPRE_DEBUG}
        ? $ENV{PERL_SEMPRE_DEBUG}
        : $opts{url};
    Carp::croak "Not found: url" unless defined $url;

    bless {
        id          => 0,
        url         => $url,
        name        => $opts{name}       || 'Semper',
        image       => $opts{image}      || undef,
        post_tags   => $opts{post_tags}  || [qw/ public /],
        token_only  => $opts{token_only} || 1,
        tags        => exists $opts{tags}
            ? { map { $_ => 1 } @{$opts{tags}} }
            : { public => 1 },
    }, $class;
}

sub run {
    my $self = shift;

    $self->{unruly} ||= Unruly->new(
        url        => $self->{url}, 
        tags       => $self->{tags},
        token_only => $self->{token_only}
    );
    $self->{unruly}->login($self->{name}, { image => $self->{image} || undef });
    
    my $cv = AnyEvent->condvar;

    $self->{unruly}->run(sub {
        my ($client, $socket) = @_;
        $socket->on('user message', sub {
            return $self->_user_message($_[1]);
        });
    });

    $cv->recv;
}

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

sub _user_message {
    my ($self, $post) = @_;

    # xxx
    return if $post->{is_message_log} || $self->{id} > $post->{id}; # PlusPlus and other.
    $self->{id} = $post->{id};
    
    for (@{$self->{message_action}}) {
        my @action = @{$_};
        my $sub_ref = pop @action;
        my $cond    = shift @action; 
        next if ref($sub_ref) ne 'CODE';

        if (defined $cond) {
            if (ref($cond) eq 'HASH') {
                next if exists $cond->{text} && $post->{text} !~ /$cond->{text}/;
                next if exists $cond->{name} && $post->{nickname} !~ /$cond->{nick}/;
            } else {
                next if $post->{text} !~ /$cond/;
            }
        }
        $self->_call($sub_ref, $post);
    }
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

