#!perl

use strict;
use warnings;

use Test::More;

my $perl = $^X;

plan tests => 3;

prime_namedpipe('namedpipe', 'Changes');

my @output = qx{sh -c "$perl -Mblib t/first-and-last-lines-via-process-pipe.pl namedpipe"};
chomp @output;
is( $output[0], 'Revision history for File-Next' );
is( $output[-1], '    First version, released on an unsuspecting world.' );
is( $?, 0, 'passing a named pipe created by a bash process substitution should yield that filename' );
cleanup_namedpipe('namedpipe');
done_testing();


sub prime_namedpipe {
    use POSIX qw[ mkfifo ];
    my ($pipe_name, $input_file_name) = @_;
    my $pid;

    chomp(my @input = `cat $input_file_name`);

    unlink $pipe_name;
    mkfifo($pipe_name, 0660) or die "Failed to create named pipe:$!\n";
    $pid = fork();
    if ( $pid == 0 ) {
        open my $np, '>', $pipe_name or die "Failed to open named pipe:$!\n";
        for my $c (@input) {
            print $np $c, "\n"; 
        }
        close $np;
        exit 0;
    }
}

sub cleanup_namedpipe {
    my $name = shift;
    unlink $name;
}
