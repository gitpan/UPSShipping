#!/usr/local/bin/perl
#
#	Figure UPS shipping 1.3
#	01/07/1998 Mark Solomon
#

package Business::UPSShipping;
use LWP::Simple;
use Carp;
require 5.003;

BEGIN {
	# set the version for version checking
        $VERSION     = 1.30;
        # if using RCS/CVS, this may be preferred
        # $VERSION = do { my @r = (q$Revision: 2.21 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker
}

1;

my %fields = (
	product => undef,
	origin => undef,
	dest => undef,
	weight => undef,
	ups_zone => undef,
	total_shipping => undef,
	raw => undef,
	error => 0,
);

sub new {
	my $that = shift;
	my $class = ref($that) || $that;
	my $self = {
		_permitted => \%fields,
		%fields,
	};
	bless $self, $class;
	# print "\n\nNumber: $#_\n@_\n";
	if ( $#_ == 3 ) {
		$self->product(shift) || $self->product(undef);
		$self->origin(shift) || $self->origin(undef);
		$self->dest(shift) || $self->dest(undef);
		$self->weight(shift) || $self->weight(undef);
	}
	else {
		croak "Wrong contstructor options";
	}
	return $self;
}

sub AUTOLOAD {
	my $self = shift;
	my $type = ref($self) || croak "$self is not an abject";
	my $name = $AUTOLOAD;
	$name =~ s/.*://;	# Strip fully-qualified portion
	unless (exists $self->{_permitted}->{$name} ) {
		croak "Can't access '$name' field in object of class $type";
	}
	if (@_) {
		return $self->{$name} = shift;
	} else {
		return $self->{$name};
	}
}

sub getUPSShipping {
	my $self = shift;
	my $type = ref($self) || croak "$self is not an abject";

	my $ups_cgi = 'http://www.ups.com/using/services/rave/qcostcgi.cgi';
	my $workString = "?";
	$workString .= "accept_UPS_license_agreement=yes&";
	$workString .= "10_action=3&";
	$workString .= "13_product=".$self->product."&";
	$workString .= "15_origPostal=".$self->origin."&";
	$workString .= "19_destPostal=".$self->dest."&";
	$workString .= "23_weight=".$self->weight."&";
	$workString = "${ups_cgi}${workString}";

	my @ret = ();
	my @ret = split( '%', get($workString) );
	$self->raw(\@ret);
	if (! $ret[5]) {
		$self->error($ret[1]);
		return 0;
	}
	else {
		$self->total_shipping($ret[10]);
		$self->ups_zone($ret[6]);
		return 1;
	}
}

END {}

__END__

=head1 NAME

	Business::UPSShipping - A UPS Shipping Cost Module

=head1 SYNOPSIS

    use Business::UPSShipping;

    $ship = new Business::UPSShipping (qw/GNDCOM 23606 23607 50/);
    $ship->getUPSShipping || die "ERROR:\n" . $ship->error,"\n";

    print "Shipping is \$" . $ship->total_shipping . "\n";
    print "UPS Zone is \$" . $ship->ups_zone . "\n";

=head1 DESCRIPTION

	A way of sending four arguments to a module to get 
	shipping charges that can be used in, say, a CGI.

=head1 REQUIREMENTS

	I've tried to keep this package to a minimum, so you'll need:

=over 4

=item *

Perl 5.003 or higher

=item *

LWP Module

=item *

Carp Module

=back 4

=head1 ARGUMENTS

	Construct the shipping object
	Construct the UPSShipping object with the following values in order:
		1. Product code
		2. Origin Zip Code
		3. Destination Zip Code
		4. Weight of Package

=item 1.

	Product Codes:

		  1DM		Next Day Air Early AM
		  1DML		Next Day Air Early AM Letter
		  1DA		Next Day Air
		  1DAL		Next Day Air Letter
		  1DP		Next Day Air Saver
		  1DPL		Next Day Air Saver Letter
		  2DM		2nd Day Air A.M.
		  2DA		2nd Day Air
		  2DML		2nd Day Air A.M. Letter
		  2DAL		2nd Day Air Letter
		  3DS		3 Day Select
		  GNDCOM	Ground Commercial
		  GNDRES	Ground Residential

	In an HTML "option" input it might look like this:

		  <OPTION VALUE="1DM">Next Day Air Early AM
		  <OPTION VALUE="1DML">Next Day Air Early AM Letter
		  <OPTION SELECTED VALUE="1DA">Next Day Air
		  <OPTION VALUE="1DAL">Next Day Air Letter
		  <OPTION VALUE="1DP">Next Day Air Saver
		  <OPTION VALUE="1DPL">Next Day Air Saver Letter
		  <OPTION VALUE="2DM">2nd Day Air A.M.
		  <OPTION VALUE="2DA">2nd Day Air
		  <OPTION VALUE="2DML">2nd Day Air A.M. Letter
		  <OPTION VALUE="2DAL">2nd Day Air Letter
		  <OPTION VALUE="3DS">3 Day Select
		  <OPTION VALUE="GNDCOM">Ground Commercial
		  <OPTION VALUE="GNDRES">Ground Residential

=item 2.
	Origin Zip(tm) Code

		Origin Zip Code as a number or string (NOT +4 Format)

=item 3.
	Destination Zip(tm) Code

		Destination Zip Code as a number or string (NOT +4 Format)

=item 4.
	Weight

		Weight of the package in pounds

=head1 RETURN VALUES

	The raw http get() returns a list with the following values:

	  ##  Desc		Typical Value
	  --  ---------------   -------------
	  0.  Name of server: 	UPSOnLine3
	  1.  Product code:	GNDCOM
	  2.  Orig Postal:	23606
	  3.  Country:		US
	  4.  Dest Postal:	23607
	  5.  Country:		US
	  6.  Shipping Zone:	002
	  7.  Weight (lbs):	50
	  8.  Sub-total Cost:	7.75
	  9.  Addt'l Chrgs:	0.00
	  10. Total Cost:	7.75
	  11. ???:		-1

	If anyone wants these available for some reason, let me know.

=head1 EXAMPLES

	To retreive the shipping of a 'Ground Commercial' Package 
	weighing 25lbs. sent from 23001 to 24002 this package would 
	be called like this:

	  #!/usr/local/bin/perl

	  use Business::UPSShipping;

	  my $ship = new Business::UPSShipping (qw/GNDCOM 23001 23002 25/);
	  my $ship->getUPSShipping || die $ship->error;

	  print "Shipping using Ground Commercial is \$" . $ship->total_shipping . "\n";  
	  print "UPS Zone is " . $ship->ups_zone . "\n";  

	If you have to recompute the shipping later, simply redifine the
	changed value and get the new shipping. 
	The values to change are:
		product		ex.	$ship->product('GNDCOM');
		origin		ex.	$ship->origin('12345');
		dest		ex.	$ship->dest('12345');
		weight		ex.	$ship->weight('50');
	For example, since the above
	example figured for 'Ground Commercial' (GNDCOM) to refigure for
	'2nd Day Air' (2DA):

	  $ship->product('2DA');
	  my $ship->getUPSShipping || die $ship->error;

	  print "Shipping using 2nd Day Air is \$" . $ship->total_shipping . "\n";  
	  print "UPS Zone is " . $ship->ups_zone . "\n";  


=head1 AUTHOR

	Mark Solomon <msolomon@seva.net>
	mailto:msolomon@seva.net
	http://www.seva.net/~msolomon/

	NOTE: UPS is a registered trademark of United Parcel Service.

=cut
