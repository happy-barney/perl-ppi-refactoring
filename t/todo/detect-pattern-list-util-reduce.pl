sub total_mass {
	my $total_mass = 0;
	foreach my $item (@$items) {
        $total_mass += $item->mass * $item->quantity;
	}

	return $total_mass;
}

