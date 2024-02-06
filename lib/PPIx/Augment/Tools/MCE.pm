
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

	use constant TASK_WORKER_NAME => q (task worker);

	sub new {
		my ($class, %params) = @_;

		my $self = bless {
			sources         => $params{sources} // [],
			worker_queue    => MCE::Queue->new (await => 1),
			manager_queue   => MCE::Queue->new (await => 1),
			finish_queue    => MCE::Queue->new (await => 1),
			stats           => {},
			find_files      => $params{find_files} // \ &_default_find_files,
			worker          => $params{worker},
			finish_task     => $params{finish_task} // \ &_default_finish_task,
			jobs            => $params{jobs} // q (100%),
			file_iterator   => $params{file_iterator},
			task_manager    => $params{task_manager},
			preprocess_task => $params{preprocess_task},

			pending_count   => 1,
			pending         => { terminate => 1 },
			waiting_for     => {},
			stats           => {
				files         => 0,
				jobs          => 0,
			},
		};


		$self->{mce} = MCE->new (
			gather     => $self->{stats},
			task_end   => sub { $self->task_end ($_[1], $_[2]) },
			user_tasks => [ $self->_user_tasks ],
			on_post_exit => sub {
				my ($mce, $e) = @_;
				MCE->say (qq ([!!!!!!!] Restart worker: $e->{wid}: $e->{pid}: status $e->{status}: $e->{msg}));
				$mce->restart_worker;
			},
		);

		return $self;
	}

	sub _build_file_iterator {
		my ($self) = @_;

		my @sources = @{ $self->{sources} };
		my $iterator = $self->_perl_file_rule
			-not_name (qr ( (?: ^ | [/] ) (?:Build | Makefile) [.] [pP][lL] $ )x)
			->iter (@sources ? @sources : q ('.'), { recurse => 1 })
			;

		return $iterator;
	}

	sub _build_perl_path_rule {
		my ($self) = @_;

		return Path::Iterator::Rule
			->new
			->file
			->or (
				Path::Iterator::Rule->new->name    (qr ( [.] (?: pm | pl | t ) $ )x),
				Path::Iterator::Rule->new->shebang (qr (^ [#] [!] .* \b perl \b )x),
			)
			;
	}

	sub _builtin_lookup_files {
		my ($self) = @_;

		my $file_iterator = $self->{file_iterator} // $self->_build_file_iterator;
		my $pending_limit = $self->{pending_limit} // 10_000;

		my $files = 0;
		while (my $file = $file_iterator->()) {
			my $task = {
				job     => q (process_file),
				file    => qq ($file),
				counter => $files,
			};

			++$files;

#			last if $files > 3;

			$self->{manager_queue}->enqueue ($task);

			$self->{manager_queue}->await ($pending_limit)
				if $self->{manager_queue}->pending > $pending_limit
				;
		}

		MCE->gather (files => $files);

		MCE->say (q ([       ] send poison pill to manager));
		$self->send_poison_pill;
	}

	sub _builtin_task_manager {
		my ($self) = @_;

		my $start_time = [ gettimeofday ];
		my $preprocess_task = $self->{preprocess_task} // sub { return $_[1] };

		local $" = q ( );
		while ($self->{pending_count} > 0) {
			my $task   = $self->{manager_queue}->dequeue;
			my $job_id = $self->_job_id ($task);
			$task->{job_id} = $job_id;

			next
				if undef
				// $self->_process_poison_pill ($job_id, $task)
				// $self->_process_response    ($job_id, $task)
				;

			next
				unless $task = $self->$preprocess_task ($task)
				;

			undef
				// $self->_process_requires    ($job_id, $task)
				// $self->_pending_job_start   ($job_id, $task)
				;
		}

		MCE->gather (jobs => $self->{stats}{jobs});
		MCE->gather (duration => tv_interval ($start_time, [ gettimeofday ]));
	}

	sub _default_find_files {
		my ($self) = @_;

		$self->{file_iterator} //= $self->_build_file_iterator;
		$self->{file_iterator_counter} = 0;
	}

	sub _default_finish_task {
	}

	sub _user_tasks {
		my ($self) = @_;

		return +( {
			task_name   => q (lookup files),
			max_workers => 1,
			user_func   => sub { $self->lookup_files },
		}, {
			task_name   => q (task manager),
			max_workers => 1,
			user_func   => sub { $self->task_manager },
		}, {
			task_name   => TASK_WORKER_NAME,
			max_workers => $self->{jobs},
			user_func   => sub { $self->worker },
		});
	}

	sub task_end {
		my ($self, $task_id, $task_name) = @_;
		say qq ([       ] Task [$task_id -- $task_name] completed processing);
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

	sub is_poison_pill {
		my ($self, $message) = @_;

		return exists $message->{terminate};
	}

	sub send_poison_pill {
		my ($self, %result) = @_;

		$self->{manager_queue}->enqueue ({ terminate => 1, result => \ %result });
	}

	sub send_to_task_manager {
		my ($self, $task) = @_;

		$self->{manager_queue}->enqueue ($task);
	}

	sub terminate_workers {
		my ($self) = @_;

		$self->{worker_queue}->enqueue ({ terminate => 1 });
	}

	sub task_manager {
		my ($self) = @_;

		state $title = ($0 = q (perl-critic-all-policies.pl - task manager));

		my $task_manager = $self->{task_manager} // \ &_builtin_task_manager;

		$self->$task_manager;
	}

	sub lookup_files {
		my ($self) = @_;

		state $title = ($0 = q (perl-critic-all-policies.pl - lookup files));

		my $lookup_files = $self->{lookup_files} // \ &_builtin_lookup_files;

		$self->$lookup_files;

	}

	sub initialize_queue {
		my ($self) = @_;
		my $find_files = $self->{find_files};

		my $files = 0;
		while (my $file = $find_files->()) {
			++$files;

			my $task = {
				job     => q (process_file),
				file    => qq ($file),
				counter => $files,
			};
		}

		MCE->gather (files => $files);

		$self->send_poison_pill;
	}

	sub worker {
		my ($self) = @_;

		state $title = ($0 = q (perl-critic-all-policies.pl - worker));

		my $user_worker = $self->{worker};

		while (my $message = $self->{worker_queue}->dequeue) {
			if ($self->is_poison_pill ($message)) {
				# terminate another worker (we have no idea how many)
				$self->terminate_workers;
				last;
			}

			$self->{manager_queue}->enqueue (
				$self->$user_worker ($message)
			);
		}

		if (my $cleanup = $self->{worker_cleanup}) {
			$cleanup->();
		}
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

		$self->terminate_workers
			unless -- $self->{pending_count}
			;
	}

	sub _pending_job_start {
		my ($self, $job_id, $message) = @_;

		return
			if exists $self->{pending}{ $job_id }
			;

		++ $self->{stats}{jobs};
		++ $self->{pending}{ $job_id };
		++ $self->{pending_count};

		$self->{worker_queue}->enqueue ($message);

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

		if (my $finish_task = $self->{finish_task}) {
			$self->$finish_task ($message, $response);
		}

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

