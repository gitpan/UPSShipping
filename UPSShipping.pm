#!/usr/local/bin/perl

#	Figure UPS shipping
#	12/20/97 Mark Solomon


package Business::UPSShipping;

require 5.003;

BEGIN {
	# set the version for version checking
        $VERSION     = 1.00;
        # if using RCS/CVS, this may be preferred
        # $VERSION = do { my @r = (q$Revision: 2.21 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker
}

1;

sub main::getUPSShipping {

&Usage if ( $#_ < 3 );

my ($product,$origPostal,$destPostal,$weight) = @_;

use LWP::Simple;

my $ups_cgi = 'http://www.ups.com/using/services/rave/qcostcgi.cgi';
my $workString = "?";
$workString .= "accept_UPS_license_agreement=yes&";
$workString .= "10_action=3&";
$workString .= "13_product=$product&";
$workString .= "15_origPostal=$origPostal&";
$workString .= "19_destPostal=$destPostal&";
$workString .= "23_weight=$weight&";
$workString = "${ups_cgi}${workString}";

return split( '%', get($workString) );

}

sub Usage {
	print STDERR "UPS: Input must be in the following format:\n";
	print STDERR "\tProduct (Shipping) Code, Origin Zip, Dest Zip, Weight (lbs)\n";
	exit(1);
}

END {}

__END__

=head1 NAME

	Business::UPSShipping - A UPS Shipping Cost Module

=head1 SYNOPSIS

    use Business::UPSShipping;

    my $shipping_code = 'GNDCOM';	# Ground Commericial
    my $origin_zip = '23000';
    my $dest_zip = '24000';
    my $weight = '10';			# In pounds

    my @shipping_data = 
        getUPSShipping($shipping_code,$origin_zip,$dest_zip,$weight);
    my $shipping_cost = $shipping_data[10];
    my $ups_zone = $shipping_data[6];

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

=back

=head1 ARGUMENTS

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

	This function returns a list (@LIST) with the following values:

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

=head1 EXAMPLES

	To retreive the shipping of a 'Ground Commercial' Package 
	weighing 25lbs. sent from 23001 to 24002 this package would 
	be called like this:

	  #!/usr/local/bin/perl
	  use Business::UPSShipping;
	  my $shipping = (getUPSShipping('GNDCOM','23001','23002','25'))[10];
  
	Here's nother example:

	  #!/usr/local/bin/perl
	  use Business::UPSShipping;
	  my @shipping = getUPSShipping('GNDCOM',23606,23607,50);
	  print "Shipping is \$$shipping[10]\n";
	  print "UPS Zone is \$$shipping[6]\n";

	Because it might be usefull to get the UPS zone, etc, for
	confirmation, I have the subroutine returning a list.

=head1 AUTHOR

	Mark Solomon <msolomon@seva.net>

	NOTE: UPS is a registered trademark of United Parcel Service.

=cut
