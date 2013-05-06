requires 'perl', '5.008001';
requires 'JSON';
requires 'File::Slurp';
requires 'File::Temp';
requires 'IPC::Open3';
requires 'TAP::Parser::Iterator::Process';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

