#!/usr/bin/perl

use Net::LDAPS;
use Config::Simple;
use POSIX;

# Get username/password from file

if ($ARG = shift @ARGV) {
    if (!open (UPFILE, "<$ARG")) {
        print "Could not open username/password file: $ARG\n";
        exit 1;
    }
} else {
    print "No username/password file specified on command line\n";
    exit 1;
}

$username = <UPFILE>;
$password = <UPFILE>;

if (!$username || !$password) {
    print "Username/password not found in file: $ARG\n";
    exit 1;
}

chomp $username;
chomp $password;

close (UPFILE);

# Initialize Auth LDAP
$cfg = new Config::Simple('openvpn-ldaps.conf');
%Config = $cfg->vars();

for $_key ( keys %Config ) {
    #strip the default from keys
    $_old = $_key;
    $_key =~ s/default\.//ig;
    $Config{$_key} = $Config{$_old};
    delete $Config{$_old};
}


my $ldaps = Net::LDAPS->new($Config{host}, %Config ) or die "Coult not create LDAP object because:\n$!";

my $ldapMsg = $ldaps->bind("uid=$username,$Config{basedn}", password => $password);

if ( ! $ldapMsg->is_error ) {
	# successfull authentication
	exit 0;
}else{
    print "Auth '$username' failed\n";
    exit 1;
}
