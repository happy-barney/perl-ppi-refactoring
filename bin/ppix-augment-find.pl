#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib qq ($FindBin::Bin/../lib);

use MCE;
use MCE::Queue;
use Path::Tiny;
use Path::Iterator::Rule;
#use PPIx::Augment;
use PPIx::Augment::Utils;
use Time::HiRes;

sub find_perl_files;
sub task_manager;
sub task_worker;

package PPIx::Augment::MCE::Task::Manager { }

my $task_queue = MCE::Queue->new;
my $manager_queue = MCE::Queue->new;

my $mce = MCE->new (
	gather     => (my $stats = {}),
	task_end   => sub {
		my ($mce, $task_id, $task_name) = @_;
		say qq (Task [$task_id -- $task_name] completed processing);
	},
	user_tasks => [ {
		task_name   => q (lookup perl files),
		max_workers => 1,
		user_func   => \& find_perl_files,
	}, {
		task_name   => q (task manager),
		max_workers => 1,
		user_func   => \& task_manager,
	}, {
		task_name   => q (task worker),
		max_workers => q (100%),
		user_func   => \& task_worker,
	} ],
);

$mce->run;

my $seconds = int $stats->{duration};
my $minutes = int $seconds / 60;
$seconds = $seconds - $minutes * 60;

my $duration = qq ($seconds seconds);
$duration = qq ($minutes minutes $duration)
	if $minutes
	;

say (qq (Process $stats->{files} files with $stats->{jobs} jobs in $duration));

sub find_perl_files {
	my $iterator = Path::Iterator::Rule
		->new
		->file
		->or (
			Path::Iterator::Rule->new->name (qr/\.(?:pm|pl|t)$/),
			Path::Iterator::Rule->new->shebang (qr/#!.*\bperl\b/),
		)
		->iter (@ARGV ? @ARGV : q ('.'), { recurse => 1 })
		;

	my $files = 0;
	while (my $file = $iterator->()) {
		++ $files;
		$manager_queue->enqueue ({
			job  => q (process_file),
			file => qq ($file),
		});
	}

	MCE->gather (files => $files);

	# ... and send poisoned pill
	PPIx::Augment::MCE::Task::Manager::->send_poison_pill (
		$manager_queue,
	);
}

sub task_manager {
	PPIx::Augment::MCE::Task::Manager::->new (
		input_queue  => $manager_queue,
		output_queue => $task_queue,
		input_jobs   => 1,
	)->run;
}

sub task_worker {
	my $input_queue = $task_queue;

	while (my $message = $input_queue->dequeue) {
		if (PPIx::Augment::MCE::Task::Manager::->is_poison_pill ($message)) {
			$input_queue->enqueue ($message);
			last;
		}

		#MCE->say (qq (# processing $message->{file}));
		my $document = PPI::Document->new ($message->{file});

		my $found = $document->find ( sub {
			my ($document, $element) = @_;
			return 0 if $element->isa (PPI::Node::);
			return 0 unless $element->content eq q ('get_conf');
			return 0 unless $element = $element->snext_sibling;
			return 0 unless $element = $element->snext_sibling;

			#return 0 unless $element->content eq 'or';
			return 0 unless $element = $element->snext_sibling;
			return 1 if $element->content eq q ('die');
			return 1 if $element->content eq q ('croak');

			return 0;
		});

		if ($found && @$found) {
			MCE->say (qq (emacsclient -n +${\ $found->[0]->line_number } $message->{file}));
			#system (q(emacsclient), q (-n), q(+) . $found->[0]->line_number, $message->{file});
		}

		$manager_queue->enqueue ({
			%$message,
			response => {},
		});

		sleep 1;
	}
}

package PPIx::Augment::MCE::Task::Manager {
    use feature q (signatures);
    no warnings experimental::signatures::;

	my $poison_pill;

	BEGIN { $poison_pill = q (terminate) }

	use Time::HiRes qw [ gettimeofday tv_interval ];

	use namespace::clean;

	sub new {
		my ($class, %params) = @_;

		bless {
			pending_count => $params{input_jobs},
			pending       => { $poison_pill => $params{input_jobs} },
			waiting_for   => {},
			input_queue   => $params{input_queue},
			output_queue  => $params{output_queue},
			stats         => {
				files         => 0,
				jobs          => 0,
			},
		};
	}

	sub waiting_for             ($self) {
		$self->{waiting_for};
	}

	sub input_queue             ($self) {
		$self->{input_queue};
	}

	sub output_queue            ($self) {
		$self->{output_queue};
	}

	sub _job_id                 ($self, $message) {
		join q ( - ), grep { defined } @$message{qw (job file)};
	}

	sub _pending_job_finish     ($self, $job_id) {
		return MCE->say (qq (WARNING: job doesn't exist: $job_id}))
			unless exists $self->{pending}{$job_id}
			;

		delete $self->{pending}{$job_id}
			unless --$self->{pending}{$job_id}
			;

		-- $self->{pending_count};
	}

	sub _pending_job_start      ($self, $job_id, $job) {
		return
			if exists $self->{pending}{ $job_id }
			;

		++ $self->{stats}{jobs};
		++ $self->{pending}{ $job_id };
		++ $self->{pending_count};

		$self->output_queue->enqueue ($job);

		1;
	}

	sub _process_poison_pill    ($self, $job_id, $message) {
		return
			unless $self->is_poison_pill ($message)
			;

		$self->_pending_job_finish ($poison_pill);

		1;
	}

	sub _process_requires       ($self, $job_id, $message) {
		return
			unless exists $message->{requires}
			;

		#MCE->say (qq (pause    - $job_id));

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

			push @{ $self->waiting_for->{$required_task_id} //= [] }, $waiting;

			$self->_pending_job_start ($required_task_id, $required_task);
		}

		1;
	}

	sub _process_response       ($self, $job_id, $message) {
		return
			unless exists $message->{response}
			;

		my $response = $message->{response};

		#MCE->say (qq (finished - $job_id));

		$self->_waiting_jobs_resolve ($job_id, $response);
		$self->_pending_job_finish ($job_id);

		1;
	}

	sub _waiting_jobs_list      ($self, $job_id) {
		return @{ $self->waiting_for->{ $job_id } // [] };
	}

	sub _waiting_jobs_resolve   ($self, $job_id, $result) {
		for my $waiting ($self->_waiting_jobs_list ($job_id)) {
			# attach required result
			my $parameter = $waiting->{mapping}{ $job_id };
			$waiting->{task}{parameters}{ $parameter } = $result // {};

			# decrement pending count, if still requires more, process next
			--$waiting->{count} && next;

			# all dependencies finished
			#MCE->say (qq (restart  - $waiting->{job_id}));
			$self->_pending_job_start ($waiting->{job_id}, $waiting->{task});
		}
	}

	sub is_poison_pill          ($self, $message) {
		return exists $message->{$poison_pill};
	}

	sub send_poison_pill        ($self, $queue, %result) {
		$queue->enqueue ({ $poison_pill => 1, result => \ %result });
	}

	sub run                     ($self) {
		my $start_time = [ gettimeofday ];

		local $" = q ( );
		while ($self->{pending_count} > 0) {
			my $message = $self->input_queue->dequeue;
			my $job_id = $self->_job_id ($message);

			#MCE->say (qq ([$self->{pending_count}] $job_id - @{[ sort keys %$message ]}));

			undef
				// $self->_process_poison_pill ($job_id, $message)
				// $self->_process_requires    ($job_id, $message)
				// $self->_process_response    ($job_id, $message)
				// $self->_pending_job_start   ($job_id, $message)
				;

		}

		MCE->gather (jobs => $self->{stats}{jobs});
		MCE->gather (duration => tv_interval ($start_time, [ Time::HiRes::gettimeofday ]));

		$self->send_poison_pill ($self->output_queue);
	}
}

