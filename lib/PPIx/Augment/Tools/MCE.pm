
use v5.14;
use warnings;

package PPIx::Augment::Tools::MCE {
	use MCE;
	use MCE::Queue;
	use Path::Tiny;
	use Path::Iterator::Rule;
	use PerlX::Maybe qw (maybe);
	use Time::HiRes qw (gettimeofday tv_interval);

	use namespace::clean;

	sub new {
		my ($class, %params) = @_;

		my $self = bless {
			sources       => $params{sources} // [],
			worker_queue  => MCE::Queue->new,
			manager_queue => MCE::Queue->new,
			stats         => {},
			find_files    => $params{find_files} // \ &_default_find_files,
			worker        => $params{worker},
			jobs          => $params{jobs} // q (100%),

			pending_count => 1,
			pending       => { terminate => 1 },
			waiting_for   => {},
			stats         => {
				files         => 0,
				jobs          => 0,
			},
		};


		$self->{mce} = MCE->new (
			gather     => $self->{stats},
			task_end   => sub { $self->task_end ($_[1], $_[2]) },
			user_tasks => [ $self->_user_tasks ],
		);

		return $self;
	}

	sub _user_tasks {
		my ($self) = @_;

		my $find_files = $self->{find_files};
		my $worker     = $self->{worker};

		return +( {
			task_name   => q (lookup files),
			max_workers => 1,
			user_func   => sub { $self->$find_files },
		}, {
			task_name   => q (task manager),
			max_workers => 1,
			user_func   => sub { $self->task_manager },
		}, {
			task_name   => q (task worker),
			max_workers => $self->{jobs},
			user_func   => sub { $self->$worker },
		});
	}

	sub task_end {
		my ($self, $task_id, $task_name) = @_;
		say qq (Task [$task_id -- $task_name] completed processing);
	};

	sub run {
		my ($self) = @_;

		$self->{mce}->run
			if $self->{worker};

		my $seconds = int $self->{stats}->{duration} // 0;
		my $minutes = int $seconds / 60;
		my $hours   = int $minutes / 60;
		$seconds = $seconds - $minutes * 60;
		$minutes = $minutes - $hours * 60;

		$seconds = sprintf q (%2d), $seconds;
		$minutes = sprintf q (%2d), $minutes;

		my $duration = qq ($seconds seconds);
		$duration    = qq ($minutes minutes $duration) if $minutes ;
		$duration    = qq ($hours hours $duration) if $hours ;

		return {
			duration => $duration,
			files    => $self->{stats}{files} // 0,
		};
	}

	sub _default_find_files {
		my ($self) = @_;

		my @sources = @{ $self->{sources} };
		my $iterator = Path::Iterator::Rule
			->new
			->file
			->or (
				Path::Iterator::Rule->new->name    (qr ( [.] (?: pm | pl | t ) $ )x),
				Path::Iterator::Rule->new->shebang (qr (^ [#] [!] .* \b perl \b )x),
			)
			->iter (@sources ? @sources : q ('.'), { recurse => 1 })
			;

		my $files = 0;
		while (my $file = $iterator->()) {
			++ $files;
			$self->{manager_queue}->enqueue ({
				job  => q (process_file),
				file => qq ($file),
			});
		}

		MCE->gather (files => $files);

		$self->send_poison_pill;
	}

	sub is_poison_pill {
		my ($self, $message) = @_;

		return exists $message->{terminate};
	}

	sub send_poison_pill {
		my ($self, %result) = @_;

		$self->{manager_queue}->enqueue ({ terminate => 1, result => \ %result });
	}

	sub task_manager {
		my ($self) = @_;

		my $start_time = [ gettimeofday ];

		local $" = q ( );
		while ($self->{pending_count} > 0) {
			my $message = $self->{manager_queue}->dequeue;
			my $job_id = $self->_job_id ($message);

			undef
				// $self->_process_poison_pill ($job_id, $message)
				// $self->_process_requires    ($job_id, $message)
				// $self->_process_response    ($job_id, $message)
				// $self->_pending_job_start   ($job_id, $message)
				;

		}

		MCE->gather (jobs => $self->{stats}{jobs});
		MCE->gather (duration => tv_interval ($start_time, [ gettimeofday ]));

		$self->send_poison_pill ($self->{task_queue});
	}

	sub _job_id {
		my ($self, $message) = @_;

		join q ( - ) => grep { defined } @$message{qw (job file)};
	}

	sub _pending_job_finish {
		my ($self, $job_id) = @_;

		return MCE->say (qq (WARNING: job doesn't exist: $job_id}))
			unless exists $self->{pending}{$job_id}
			;

		delete $self->{pending}{$job_id}
			unless --$self->{pending}{$job_id}
			;

		-- $self->{pending_count};
	}

	sub _pending_job_start {
		my ($self, $job_id, $job) = @_;

		return
			if exists $self->{pending}{ $job_id }
			;

		++ $self->{stats}{jobs};
		++ $self->{pending}{ $job_id };
		++ $self->{pending_count};

		$self->{worker_queue}->enqueue ($job);

		1;
	}

	sub _process_poison_pill {
		my ($self, $job_id, $message) = @_;

		return
			unless $self->is_poison_pill ($message)
			;

		$self->_pending_job_finish (q (terminate));

		1;
	}

	sub _process_requires {
		my ($self, $job_id, $message) = @_;

		return
			unless exists $message->{requires}
			;

		my $mapping = delete $message->{requires};
		my $waiting = {
			job_id => $job_id,
			count   => 0,
			mapping => {},
			task    => $message,
		};
		$message->{parameters} //= {};

		while (my ($parameter, $required_task) = each %$mapping) {
			my $required_task_id = $self->_job_id ($required_task);

			$waiting->{mapping}{$required_task_id} = $parameter;

			push @{ $self->{waiting_for}{$required_task_id} //= [] }, $waiting;

			$self->_pending_job_start ($required_task_id, $required_task);
		}

		1;
	}

	sub _process_response {
		my ($self, $job_id, $message) = @_;

		return
			unless exists $message->{response}
			;

		my $response = $message->{response};

		$self->_waiting_jobs_resolve ($job_id, $response);
		$self->_pending_job_finish ($job_id);

		1;
	}

	sub _waiting_jobs_list {
		my ($self, $job_id) = @_;

		return @{ $self->{waiting_for}->{ $job_id } // [] };
	}

	sub _waiting_jobs_resolve {
		my ($self, $job_id, $result) = @_;

		for my $waiting ($self->_waiting_jobs_list ($job_id)) {
			# attach required result
			my $parameter = $waiting->{mapping}{ $job_id };
			$waiting->{task}{parameters}{ $parameter } = $result // {};

			# decrement pending count, if still requires more, process next
			--$waiting->{count} && next;

			# all dependencies finished
			$self->_pending_job_start ($waiting->{job_id}, $waiting->{task});
		}
	}

	1;
}

