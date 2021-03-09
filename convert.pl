#!/usr/bin/perl
use strict;
use Socket;
use warnings;
use feature qw( say );

# NOTE: Maxmind package below only available on Linux.
use MaxMind::DB::Writer::Tree;

sub long2ip {
	return inet_ntoa(pack("N*", shift));
}

my $filename = 'PX10-Lite.mmdb';

my %types = (
	'is_anonymous' => 'boolean',
	'is_anonymous_vpn' => 'boolean',
	'is_hosting_provider' => 'boolean',
	'is_public_proxy' => 'boolean',
	'is_residential_proxy' => 'boolean',
	'is_tor_exit_node' => 'boolean',
);

my $tree = MaxMind::DB::Writer::Tree->new(

	database_type => 'GeoIP2-Anonymous-IP', # DO NOT CHANGE COZ MAXMIND API LOOKING FOR THIS STRING

	# "description" is a hashref where the keys are language names and the
	# values are descriptions of the database in that language.
	description =>
		{ en => 'IP2Proxy PX10 Data' },

	# "ip_version" can be either 4 or 6
	ip_version => 4,

	# add a callback to validate data going in to the database
	map_key_type_callback => sub { $types{ $_[0] } },

	# "record_size" is the record size in bits.  Either 24, 28 or 32.
	record_size => 32,
);

open IN, "<IP2PROXY-LITE-PX10.CSV" or die;

while (<IN>)
{
	my $line = $_;
	$line =~ s/[\r\r]+//;
	
	if ($line =~ /^"([^"]+)","([^"]+)","([^"]+)","([^"]+)","[^"]+","[^"]+","[^"]+","[^"]+","[^"]+","([^"]+)","[^"]+","[^"]+","[^"]+","[^"]+"$/)
	{
		my $first_ip = long2ip($1);
		my $last_ip = long2ip($2);
		my $proxy_type = $3;
		my $country_code = $4;
		my $usage_type = $5;
		
		my %data;
		
		if (($country_code ne '-') && ($proxy_type ne '-') && ($proxy_type ne 'DCH') && ($proxy_type ne 'SES'))
		{
			$data{'is_anonymous'} = 1;
		}
		else
		{
			$data{'is_anonymous'} = 0;
		}
		
		if ($proxy_type eq 'VPN')
		{
			$data{'is_anonymous_vpn'} = 1;
		}
		else
		{
			$data{'is_anonymous_vpn'} = 0;
		}
		
		if ($usage_type eq 'DCH')
		{
			$data{'is_hosting_provider'} = 1;
		}
		else
		{
			$data{'is_hosting_provider'} = 0;
		}
		
		if ($proxy_type eq 'PUB')
		{
			$data{'is_public_proxy'} = 1;
		}
		else
		{
			$data{'is_public_proxy'} = 0;
		}
		
		if ($proxy_type eq 'RES')
		{
			$data{'is_residential_proxy'} = 1;
		}
		else
		{
			$data{'is_residential_proxy'} = 0;
		}
		
		if ($proxy_type eq 'TOR')
		{
			$data{'is_tor_exit_node'} = 1;
		}
		else
		{
			$data{'is_tor_exit_node'} = 0;
		}
		
		$tree->insert_range( $first_ip, $last_ip, \%data );
	}
}
close IN;

# Write the database to disk.
open my $fh, '>:raw', $filename;
$tree->write_tree( $fh );
close $fh;

say "$filename has now been created";