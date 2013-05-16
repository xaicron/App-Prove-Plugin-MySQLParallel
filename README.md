# NAME

App::Prove::Plugin::MySQLParallel - execute parallel testing by number of MySQL's nodes.

# SYNOPSIS

    env TEST_MYSQL_SANDBOX_HOME=$HOME/sandboxes/multi_msb_5_1_69 prove -PMySQLParallel -lrc t

# DESCRIPTION

App::Prove::Plugin::MySQLParallel is a execute parallel testing by number of MySQL's nodes of [MySQL::Sandbox](http://search.cpan.org/perldoc?MySQL::Sandbox).

# SETUP

Installing [MySQL::Sandbox](http://search.cpan.org/perldoc?MySQL::Sandbox).

    $ cpanm MySQL::Sandbox

Make multiple instances.

    $ make_multiple_sandbox --how_many_nodes=4 5.1.69

Optional: if you want use Q4M, `log_bin` to trun off.

    $ cd ~/sandboxes/multi_msb_5_1_69
    $ perl -pi -lne 's/^log-bin=.*//' node*/my*.cnf
    $ ./restart_all

# HOW TO USE

App::Prove::Plugin::MySQLParallel is set environment variable before runngin each test.
You can use the following values:

    $ENV{TEST_MYSQL_SOCK}
    $ENV{TEST_MYSQL_USER}
    $ENV{TEST_MYSQL_PASS}
    $ENV{TEST_MYSQL_PORT}
    $ENV{TEST_MYSQL_HOST}

For example in your test

    my $dbh = DBI->connect(
        "DBI:mysql:database=$dbname;mysql_socket=$ENV{TEST_MYSQL_SOCK}",
        $ENV{TEST_MYSQL_USER},
        $ENV{TEST_MYSQL_PASS},
    );

or

    my $dbh = DBI->connect(
        "DBI:mysql:database=$dbname;host=$ENV{TEST_MYSQL_PORT};port=$ENV{TEST_MYSQL_PORT}",
        $ENV{TEST_MYSQL_USER},
        $ENV{TEST_MYSQL_PASS},
    );

# LICENSE

Copyright (C) xaicron.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

xaicron <xaicron@gmail.com>
