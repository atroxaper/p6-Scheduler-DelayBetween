[![Build Status](https://github.com/atroxaper/p6-Scheduler-DelayBetween/workflows/build/badge.svg)](https://github.com/atroxaper/p6-Scheduler-DelayBetween/actions)

# NAME

**Scheduler::DelayBetween** - Standard Scheduler's `cue` sub with the possibility to set a delay between each code execution.

# SYNOPSIS

```perl6
use Scheduler::DelayBetween;

my $cancel = cue({ say 'boom'; sleep 3; }, :5in, :1delay-between);
sleep(5 + (3 + 1) * 13 + 0.7); # got 'boom' 14 times
$cancel.cancel;
```

# DESCRIPTION

Sometimes you may need to execute some code several times with fixed delay *between* each execution. Standard Scheduler method `cue` does not provide such possibility. You can achieve it with this module.

It provides a single subroutine:

`cue(&code, :$at, :$in, :$every, :$times = 0, :&stop, :&catch, :$delay-between, :$scheduler = $*SCHEDULER --> Cancellation)`

Parameters meaning:

- `&code` - positional parameter - the code to run;
- `:$at` or `:in` - `:$at` can be an Instant before which the code won't be run. Alternatively,`:$in` is the number of seconds (possibly fractional) to wait before running the code. If `:$at` is in the past or `:$in` is negative, the delay is treated as zero. Implementations may equate to zero very small values (e.g., lower than 0.001s) of `:$in` or result of `:$at - now`;
- `:$times` - how many times the code has to be run. The parameter will be ignored if the value will be less than one. You can use this parameter together with `:&stop`, then the code will be run until at least one will stop it;
`:&stop` - a check to decide should we continue to run the code. It will be called after each call of the code. Code running will stop if `:&stop` return `True`. You can use this parameter together with `:$times`, then the code will be run until at least one will stop it;
- `:$scheduler` - a scheduler to de used for scheduling the code running;
- `:&catch` - an exception handler, a sub with single positional parameter - exception occurred while the code running;
- `:$delay-between` - delay in seconds (possibly fractional), which must pass between each run of the code except before the first one. If the parameter is missed, then the `cue` call will be delegated to the `cue` method of `:$scheduler`. Implementations may equate to zero very small values (e.g., lower than 0.001s).
- `:$every` - will pass to the `cue` method of `:$scheduler` if you do not specify `:$delay-between` - you cannot use it together.

The subroutine will return a `Cancellation` object you can use to cancel the future code runs.

# AUTHOR

Mikhail Khorkov <atroxaper@cpan.org>

Source can be located at: [GitHub](https://github.com/atroxaper/p6-Scheduler-DelayBetween). Comments and Pull Requests
are welcome.

# COPYRIGHT AND LICENSE

Copyright 2021 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.
