# Configuration loading module.
# Loads projects properties files into memory.
# Lines starting with # are considered comments.
# Author: Badr Zarhri <badr.zarhri@corporate-groupe.com>
# 04-Nov-2015, Created the module -- Badr

package CS::Project;

use v5.10;
use strict;
use warnings;
use POSIX qw"strftime";
use Time::Local;

sub new {
	my $self = shift;
	my $type = ref($self) || $self;
	my $config_file = shift;
	my $logger = shift;

	my @options = qw(Name Flux Query_Dir);
	my $res;
	print "$config_file";
	open IN, "<", $config_file or $logger->fatal("Could not open configuration file: $config_file $!");
	while(<IN>) {
		chomp;
		next if /^\s*#/;
		next unless /=/;
		@_ = split /=/;
		$res->{$_[0]} = $_[1] || '';
		print '$res';

	}
	close IN;

	foreach my $option (@options) {
		$logger->fatal("$option not present in $config_file exiting ...") unless defined $res->{$option};
	}
	$res->{'Logger'} = $logger;

	$res->{'Flux'} = [split ',', $res->{'Flux'}];

	return bless $res, $type;
}
new();

sub next_day {
	my $self = shift;
	
	open IN, '<', 'Data/'.$self->{'Name'}.'.txt' or return undef;

	$_ = <IN>;
	chomp;
	my $el = $_;

	my $year = substr($el,0,4);
	my $month = substr($el,4,2);
	my $day = substr($el,6,2);

	my $time = timelocal('00','00',"00",$day,$month-1,$year);

	my ($S, $M, $H, $d, $m, $Y) = localtime($time+86400);
	$m += 1;
	$Y += 1900;
	my $dt = sprintf("%04d%02d%02d", $Y,$m, $d);
	
	close IN;
	return $dt;
}

sub set_day {
	my $self = shift;
	my $logger = $self->{'Logger'};
	my $day = shift;

	$logger->debug("Updating Data/".$self->{'Name'}.".txt with $day");
	open OUT, '>', 'Data/'.$self->{'Name'}.'.txt' or $logger->fatal("Error updating Data/".$self->{'Name'}.'.txt');
	say OUT $day;
	close OUT;
}

1;
