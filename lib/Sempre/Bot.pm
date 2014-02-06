package Sempre::Bot;
use strict;
use warnings;

use Unruly;

sub new {
    my ($class, %opts) = @_;

    my $url = $ENV{PERL_SEMPRE_DEBUG}
        ? $ENV{PERL_SEMPRE_DEBUG}
        : $opts{url};
    Carp::croak "Not found: url" unless defined $url;
   
    my $tags      = exists $opts{tags}
        ? { map { $_ => 1 } @{$opts{tags}} }
        : { public => 1 };
    my $post_tags = $ENV{PERL_SEMPRE_DEBUG}
        ? [qw/ norec /] 
        : $opts{post_tags};

    my $unruly = Unruly->new(
        url        => $url,
        tags       => $tags,
    );
    $unruly->login($opts{name}, { image => $opts{image}, token_only => $opts{token_only} });

    bless {
        current_id => 0,
        unruly     => $unruly, 
        post_tags  => $post_tags,
    }, $class;
}

sub action {
    my ($self, @action) = @_;
    push @{$self->{action}}, \@action;
}

sub init {
    my ($self) = @_;

    $self->{unruly}->run(sub {
        my ($client, $socket) = @_;
        $socket->on('user message', sub {
            return $self->_action($_[1]);
        });
    });
}

sub run {
    my ($self) = @_;
    $self->init;
    my $cv = AnyEvent->condvar;
    $cv->wait;
}

sub _action {
    my ($self, $post) = @_;

    return if $post->{is_message_log} || $self->{current_id} > $post->{id}; # PlusPlus and other.
    $self->{current_id} = $post->{id};

    for (@{$self->{action}}) {
        my @action   = @{$_};
        my $code_ref = pop @action;
        my $cond     = shift @action;
        next if defined $cond && $self->_cond($post, $cond) == 0; 
        
        my $retval = $code_ref->($post);
        next if ! defined $retval || ref $retval ne 'HASH';

        if (exists $retval->{post}) {
            my $word = $retval->{post} . ' ' . join(' ', map { '#' . uc $_ } @{$self->{post_tags}});
            $self->{unruly}->post($word);
        }
    }
}

sub _cond {
    my ($self, $post, $cond) = @_;

    if (ref $cond eq 'HASH') {
        return 0 if exists $cond->{text} && $post->{text} !~ /$cond->{text}/;
        return 0 if exists $cond->{name} && $post->{nickname} !~ /$cond->{nick}/;
    } else {
        return 0 if $post->{text} !~ /$cond/;
    }
    return 1;
}

1;
