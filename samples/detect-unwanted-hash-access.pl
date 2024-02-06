sub format_station_object (%raw_args) :Exportable(all) {
    state $check = compile_named(
        station   => DbicStation,
        with_description => Optional[Bool],
    );
    my $args = $check->(%raw_args);

    return +{
		slug => $args->{station}->slug,
		name => $args->{station}->name,
		# error: $args is not declared to contain 'description' key
		provided_deref $args->{description}, sub { description => $args->{station}->description },
    };
}
