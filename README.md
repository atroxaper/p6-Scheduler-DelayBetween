[![Build Status](https://travis-ci.org/atroxaper/p6-Scheduler-DelayBetween.svg?branch=master)](https://travis-ci.org/atroxaper/p6-Scheduler-DelayBetween)

# NAME

**Scheduler::DelayBetween** - Standard Scheduler `cue` sub with possibility to
set a delay between each code execution.

# SYNOPSIS

```perl6
use Scheduler::DelayBetween;

my $cancel = cue({ say 'boom'; sleep 3; }, :1delay-between, :5in);
sleep 60;
# got boom 14 times
$cancel.cancel;
```

# DESCRIPTION

Sometimes you may need to execute some code several times with fixed delay
*between* each execution. Standard Scheduler method `cue` do not provide such
possibility. You can achieve it with this module.

It provides a single subroutine:

`cue(&code, :$at, :$in, :$every, :$times = 0, :&stop, :&catch, :$delay-between, :$scheduler = $*SCHEDULER --> Cancellation)`

Parameters meaning:

- `&code` - positional parameter - the code to run;
- `:$at` or `:in` - `:$at` can be an Instant before which the code won't be run.
Alternatively `:$in` is the number of seconds (possibly fractional) to wait
before running the code. If `:$at` is in the past or `:$in` is negative, the
delay is treated as zero. Implementations may equate to zero very small values
(e.g. lower than 0.001s) of `:$in` or result of `:$at - now`;
- `:$times` - if more then zero then describes how many times the code have to
be run; ignore this parameter otherwise. You can use this parameter together
with `:&stop`, then the code will be run until at least one will stop it;
- `:&stop` - code to decide should be continue to run the code. It will be
called after the first code call firstly. Code running will stop if `:&stop`
returns `True`. You can use this parameter together with `:$times`, then the
code will be run until at least one will stop it;
- `:$scheduler` - scheduler to de used for schedule the code running;
- `:&catch` - exception handler, a sub with single positional parameter -
exception occurred while the code running;
- `:$delay-between` - delay in seconds (possibly fractional) which must pass
between each the code run except before the first run; If the parameter is
missed then `cue` call will be delegates to `cue` method of `:$scheduler`;
Implementations may equate to zero very small values (e.g. lower than 0.001s).
- `:$every` - will pass to `cue` method of `:$scheduler` in case you do not
specify `:$delay-between`. You cannot use it together with `:$delay-between`.

The subroutine will return a `Cancellation` object you can use to cancel the
future code run.

# AUTHOR

Mikhail Khorkov <atroxaper@cpan.org>

Source can be located at: [GitHub](https://github.com/atroxaper/p6-Scheduler-DelayBetween). Comments and Pull Requests
are welcome.

# COPYRIGHT AND LICENSE

Copyright 2019 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.