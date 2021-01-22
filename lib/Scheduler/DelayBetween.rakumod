unit module Scheduler::DelayBetween;

class DelayBetweenCancellation { ... }

#|[
# &code - the code to be run
# $at - an Instant before which the code won't be run
# $in - the number of seconds to wait before running the code
# $every - the number of seconds to wait before re-executing the code
# $times - how many times the code has to be run
# &stop - a check to decide should we continue to run the code
# &catch - an exception handler -> e { ... } is called if &code throws
# $delay-between - delay in seconds between each run of the code except before the first one
# $scheduler - a scheduler to de used for scheduling the code running
#]
sub cue(
	&code, :$at, :$in is copy, :$every, :$times = 0, :&stop is copy,
	:&catch is copy, :$delay-between, :$scheduler = $*SCHEDULER
	--> Cancellation
) is export {
	#	use default behaviour in case we do not want to use delay-between parameter
	return $scheduler.cue(
		&code, |{:$at, :$in, :$every, :times => max($times, 1), :&catch}\
			.list.grep(-> $e { $e.value.DEFINITE }).Map
	) without $delay-between;

	die "Cannot specify :at and :in at the same time" if $at.defined and $in.defined;
	die "Connot specify :every and :delay-between at the same time" if $every.defined;

	$in = max($at ?? $at - now !! $in // 0, 0);
	&stop = comb-stop(time-stop($times), &stop);
	my &run := &catch ?? wrap-catch(&code, &catch) !! &code;

	my DelayBetweenCancellation $cancellation .= new;
	$cancellation.set-intern: $scheduler
		.cue({ execute(&run, $cancellation, $delay-between, &stop, $scheduler) }, :$in);

	$cancellation
}

sub time-stop($time) {
	if $time > 0 {
		my atomicint $already = 0;
		return -> { ++⚛$already >= $time };
	} else {
		return Callable;
	}
}

sub comb-stop(&time-stop, &stop) {
	with &time-stop {
		with &stop {
			return -> { time-stop() && stop() };
		} else {
			return &time-stop
		}
	}
	with &stop {
		return &stop;
	} else {
		return -> { False }
	}
}

sub execute(&code, $cancellation, $db, &stop, $scheduler) {
	return if $cancellation.cancelled;
	code();
	return if $cancellation.cancelled;
	return if stop();
	$cancellation.set-intern: $scheduler
		.cue({ execute(&code, $cancellation, $db, &stop, $scheduler) }, :in($db));
}

sub wrap-catch(&code, &catch) {
	-> { code(); CATCH { default { catch($_) } } }
}

class DelayBetweenCancellation is Cancellation {
	has Cancellation $!intern;
	has atomicint $!cancelled;
	has Lock $!lock;

	submethod BUILD(--> Nil) {
		$!cancelled ⚛= 0;
		$!lock = Lock.new;
	}

	method set-intern($intern) {
		$!lock.protect: { $!intern = $intern };
	}

	method cancelled() {
		return ⚛$!cancelled > 0;
	}

	method cancel() {
		$!lock.protect: {
			if ⚛$!cancelled == 0 {
				$!intern.cancel with $!intern;
				$!cancelled ⚛= 1;
			}
		}
	}
}