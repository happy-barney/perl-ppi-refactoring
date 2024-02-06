my $ship
{
	my $ship    = $viewer->current_ship;
	my $station = $viewer->station;

	return $station->name;
}

return $ship;
