package App::local::lib::helper;

use strict;
use warnings;
use File::Spec;

use 5.008008;
our $VERSION = '0.01';

sub run {
    my ($class, %opts) = @_;
    my $local_lib_helper = __PACKAGE__->new(%opts);
    return $local_lib_helper->create_local_lib_helper;
}

sub _diag {
    my $self = shift @_;
    print STDERR @_, "\n";
}

sub diag {
    shift->_diag(@_);
}

sub error {
    shift->_diag(@_);
    die "Exiting with Errors";
}
   
sub new {
    my ($class, %opts) = @_;
    return bless \%opts, $class;
}

sub create_local_lib_helper {
    my $self = shift;
    if (my $target = $self->{target}) {
        return $self->_create_local_lib_helper($target);
    } elsif ($self->has_local_lib_env) {
        my ($install_base, $target) =
            map {split '=', $_} 
            grep { m/^INSTALL_BASE/ }
            split ' ', $ENV{PERL_MM_OPT};
        return $self->_create_local_lib_helper($target);
    }
    
    $self->diag(<<DIAG);
  !
  ! You are not installing the helper script while in a local::lib context nor
  ! have you specified the local::lib target directory via the --local_lib
  ! commandline option.  I don't know how to install the helper script.
  !
DIAG
}

sub has_local_lib_env {
    my $self = shift @_;
    if(
        $ENV{PERL_MM_OPT} and 
        ($ENV{MODULEBUILDRC} or $ENV{PERL_MB_OPT})
    ) {
        return 1;
    } else {
        return;
    }
}

sub _create_local_lib_helper {
    my ($self, $target) = @_;
    $self->diag("My target local::lib is $target");
    my $lib = File::Spec->catdir($target, 'lib', 'perl5');
    my $bin = File::Spec->catdir($target, 'bin');
    unless(-e $bin) {
        mkdir $bin;
    }
    my $bin = File::Spec->catdir($bin, $self->{helper_name});
    open(my $bin_fh, '>', $bin)
      or $self->error("Can't open $bin", $!);

    print $bin_fh <<"END";
#!$self->{which_perl}

use strict;
use warnings;

use lib '$lib';
use local::lib '$target';

unless ( caller ) {
    if ( \@ARGV ) {
        exec \@ARGV;
    }
}

1;
END

    close($bin_fh);
    chmod oct($self->{helper_permissions}), $bin;
    return $bin;
}

1;

=head1 NAME

App::local::lib::helper - Make it easy to run code against a L<local::lib>

=head1 SYNOPSIS

    use App::local::lib::helper;
    App::local::lib::helper->run(%opts);

=head1 DESCRIPTION

This is an object which provide the functionality to create a L<local::lib>
'helper' script in either the currently loaded L<local::lib> environment or in
a target directory of choice.  By default the script is called 'localenv' and
can be used to invoke a command under the L<local::lib> which it was built
against.  For example, assume you build a L<local::lib> like so:

    cpanm -L ~/mylib App::local::lib::helper

This creates a directory "~/mylib" and installs L<App::local::lib::helper> and
a utility script into "~/mylib/bin".  Now, if you want to invoke a perl 
application and use libs installed into "~/mylib", you can do so like:

    ~/mylib/bin/locallib perl [SOME COMMAND]

The command C<locallib> will make sure the same L<local:lib> that was active
when L<App::local::lib::helper> was originally installed is again installed
into the environment before executing the commands passed in @ARGV.  Upon
completing the command, the %ENV is restored so that you can use this to fire
off an application against a specific L<local::lib> without needing to deal
with the details of how to activate the L<local::lib> or how to make sure
your %ENV stays clean.

The arguments given to C<locallib> don't need to be a perl application.  For
example, I often like to open a sub shell under a particular L<local::lib>
managed directory.

    ~/mylib/bin/locallib bash

Now, if I do:

    perl -V

I'll see that ~/mylib has been added to @INC.  Additionally, "~/mylib/bin" will
have been added to $PATH, so that any command line perl applications installed
into the L<local::lib> (such as C<ack> or C<cpanm>) can be accessed easily.

Another example usage would be when you want to install an application from
CPAN, install it and all its dependencies to a single directory root and 
then run it without a lot of effort.  For example:

    cpanm -L ~/gitalyst-libs Gitalist App::local::lib::helper
    ~/gitalyst-libs/bin/localenv gitalyst-server.pl

And presto! Your cpan installed application is running, fully self-contained to
one root directory all under regular user privileges.

L<local::lib> does all the real work, but I find this to be the easiest way to
run given code against a L<local::lib> root.  

=head1 OPTIONS

This class supports the following options.

=over 4

=item which_perl

This should be the path to the perl binary that the L<local::lib> is built
against. This defaults to the path of the perl binary under which we are
currently running.  You should probably leave this one alone :)

=item target

This is the target directory for the L<local::lib> you want to build the helper
script against.  By default it will attempt to detect the currently running
L<local::lib> and use that.  If we can't detect a running L<local::lib> and
this option is undef, we die with a message.

=item helper_name

This is the name of the helper utility script.  It defaults to 'localenv'.

=item helper_permissions

These are the permissions the the helper utility script is set to.  By default
we set the equivilent of 'chmod 755 [HELPER SCRIPT]'

=back

=head1 AUTHOR

John Napiorkowski C< <<jjnapiork@cpan.org>> >

=head1 COPYRIGHT & LICENSE

Copyright 2010, John Napiorkowski

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut


