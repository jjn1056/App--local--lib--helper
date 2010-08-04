package App::local::lib::helper;

use strict;
use warnings;
use File::Spec;

our $VERSION = '0.01';

sub run {
    my ($class, %opts) = @_;
    my $local_lib_helper = __PACKAGE__->new(%opts);
    return $local_lib_helper->create_local_lib_helper;
}
   
sub new {
    my ($class, %opts) = @_;
    return bless {
        which_perl => $ENV{LOCALLIB_WHICH_PERL} || $^X,
        local_lib_target => $ENV{LOCALLIB_TARGET} || undef,
        helper_name => $ENV{LOCALLIB_HELPER_NAME} || 'localenv',
        helper_permissions => $ENV{LOCALLIB_HELPER_PERMISSIONS} || '0755',
    }, $class;
}

sub create_local_lib_helper {
    my $self = shift;
  
    if (my $target = $self->{local_lib_target}) {
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

sub has_local_lib_inc {
    my ($self, $target) = @_;    
    return eval {
        require local::lib;
        local::lib->import($target);
        1;
    }
}

sub _create_local_lib_helper {
    my ($self, $target) = @_;
    $self->diag("My target local::lib is $target");
    if($self->has_local_lib_inc($target)) {
        my $lib = File::Spec->catdir($target, 'lib', 'perl5');
        my $bin = File::Spec->catdir($target, 'bin', $self->{helper_name});
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
    } else {
        $self->diag('There is no local::lib found in the include path!');
        $self->diag('@INC is: ', "\n", map { "\t$_\n"} @INC);
    }
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
    exit 0;
}

1;

=head1 NAME

App::local::lib::helper - Functionality to build a L<local::lib> helper script

=head1 SYNOPSIS

    use App::local::lib::helper;
    App::local::lib::helper->run(%opts);

=head1 DESCRIPTION

This is an object with provide the functionality to create a L<local::lib>
'helper' script in either the currently loaded L<local::lib> enviroment or in
a target directory of choice.

You should see the POD for the helper script as well as the script which is
using this class.  You probably won't use this class directly.

=cut


