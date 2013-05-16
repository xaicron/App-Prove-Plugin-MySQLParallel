package App::Prove::Plugin::MySQLParallel;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use JSON qw(encode_json decode_json);
use File::Slurp qw(read_file write_file);
use File::Temp qw(tempdir);

use IPC::Open3 ();
use TAP::Parser::Iterator::Process ();

my $TEMPDIR = tempdir CLEANUP => 1;

sub load {
    my ($class, $prove) = @_;

    my $sandbox_home = $ENV{TEST_MYSQL_SANDBOX_HOME};
    unless ($sandbox_home) {
        die '$ENV{TEST_MYSQL_SANDBOX_HOME} must be specified';
    }

    my $config = decode_json scalar read_file "$sandbox_home/default_connection.json";
    my $connections = [];
    for my $node (keys %$config) {
        $config->{ $node }{username} =~ s/\@.*//;
        push @$connections, {
            socket   => $config->{ $node }{socket},
            username => $config->{ $node }{username},
            password => $config->{ $node }{password},
        };
    }

    $prove->{app_prove}->jobs(scalar @$connections);

    # Hook prepare fork
    my $open3 = \&IPC::Open3::open3;
    no warnings 'redefine';
    *IPC::Open3::open3 = sub {
        my $conn = shift @$connections || die 'oops!';
        $ENV{TEST_MYSQL_SOCK} = $conn->{socket};
        $ENV{TEST_MYSQL_USER} = $conn->{username};
        $ENV{TEST_MYSQL_PASS} = $conn->{password};
        $ENV{TEST_MYSQL_PORT} = $conn->{port};
        $ENV{TEST_MYSQL_HOST} = $conn->{host};

        my $pid = $open3->(@_);
        write_file "$TEMPDIR/$pid", encode_json $conn;
        return $pid;
    };

    # Hook after fork
    my $finish = \&TAP::Parser::Iterator::Process::_finish;
    *TAP::Parser::Iterator::Process::_finish = sub {
        my $self = $finish->(@_);
        return $self unless $self->{pid};

        push @$connections, decode_json scalar read_file "$TEMPDIR/$self->{pid}";
        return $self;
    };

    return 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

App::Prove::Plugin::MySQLParallel - execute parallel testing by number of MySQL's nodes.

=head1 SYNOPSIS

    env TEST_MYSQL_SANDBOX_HOME=$HOME/sandboxes/multi_msb_5_1_69 prove -PMySQLParallel -lrc t

=head1 DESCRIPTION

App::Prove::Plugin::MySQLParallel is a execute parallel testing by number of MySQL's nodes of L<< MySQL::Sandbox >>.

=head1 SETUP

Installing L<< MySQL::Sandbox >>.

    $ cpanm MySQL::Sandbox

Make multiple instances.

    $ make_multiple_sandbox --how_many_nodes=4 5.1.69

Optional: if you want use Q4M, C<< log_bin >> to trun off.

    $ cd ~/sandboxes/multi_msb_5_1_69
    $ perl -pi -lne 's/^log-bin=.*//' node*/my*.cnf
    $ ./restart_all

=head1 HOW TO USE

App::Prove::Plugin::MySQLParallel is set environment variable before runngin each test.
You can use the following values:

    $ENV{TEST_MYSQL_SOCK}
    $ENV{TEST_MYSQL_USER}
    $ENV{TEST_MYSQL_PASS}

For example in your test

    my $dbh = DBI->connect(
        "DBI:mysql:database=$dbname;mysql_socket=$ENV{TEST_MYSQL_SOCK}",
        $ENV{TEST_MYSQL_USER},
        $ENV{TEST_MYSQL_PASS},
    );

=head1 LICENSE

Copyright (C) xaicron.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

xaicron E<lt>xaicron@gmail.comE<gt>

=cut

