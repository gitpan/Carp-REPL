#!perl
use strict;
use warnings;
use Test::More tests => 37;
use Test::Expect;

expect_run
(
    command => 'perl -Ilib -MCarp::REPL t/scripts/04-scope.pl',
    prompt  => '$ ',
    quit    => 'exit',
);

expect_send('1 + 1');
expect_like(qr/\b2\b/, 'in the REPL');

expect_send('$pre_lexical');
expect_like(qr/\balpha\b/);

expect_send('$pre_global_safe');
expect_like(qr/\bsheep\b/);

expect_send('$inner_lexical');
expect_like(qr/\bparking\b/);

expect_send('$inner_global');
expect_like(qr/\bto\b/);

expect_send('$pre_global');
expect_like(qr/\bshadow stabbing\b/);

expect_send('$post_global');
TODO:
{
    local $TODO = 'I expected this to work!';
    expect_like(qr/\bgo\b/);
}

expect_send('$main::post_global');
expect_like(qr/\bgo\b/);

expect_send('$post_local');
expect_like(qr/\brequires explicit package name\b/);

expect_send('$postcall_local');
expect_like(qr/\brequires explicit package name\b/);

expect_send('$postcall_global');
expect_like(qr/\brequires explicit package name\b/);

expect_send('$other_lexical');
expect_like(qr/\brequires explicit package name\b/);

expect_send('$other_global');
TODO:
{
    local $TODO = 'I expected this to work!';
    expect_like(qr/\blong jacket\b/);
}

expect_send('$main::other_global');
expect_like(qr/\blong jacket\b/);

expect_send('$birds');
expect_like(qr/\brequires explicit package name\b/);

expect_send('$window');
expect_like(qr/\brequires explicit package name\b/);

expect_send('$Mr::Mastodon::Farm::birds');
expect_like(qr/\bfall\b/);

expect_send('$Mr::Mastodon::Farm::window');
expect_is('$Mr::Mastodon::Farm::window', 'output was exactly what we gave to the repl, meaning the output was undef');

