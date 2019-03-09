use Test;

use lib 'lib';
use Scheduler::DelayBetween;

plan 13;

my $cancel;
my atomicint $count ⚛= 0;
sub check($expected-cound, $title) {
	$cancel.cancel;
	ok $cancel.cancelled, "$title canceled";
	is ⚛$count, $expected-cound, "$title works well";
	$count ⚛= 0;
}

my &code = { sleep 2; ++⚛$count; }
my atomicint $enough;
my &stop = { --⚛$enough < 1 }

dies-ok { cue(&code, :1delay-between, :3every) }, 'every is forbidden';
dies-ok { cue(&code, :1delay-between, :1in, :2at) }, 'at and in is forbidden';

$cancel = cue(&code, :1delay-between, at => (now + 3));
sleep(11.5);
check(3, ':+3at');

$cancel = cue(&code, :1delay-between, :3in);
sleep(8.5);
check(2, ':3in');

$cancel = cue(&code, :1delay-between, :2times);
sleep(12);
check(2, ':2times');

$enough ⚛= 3;
$cancel = cue(&code, :1delay-between, :&stop);
sleep(14);
check(3, ':3stop');

$enough ⚛= 3;
$cancel = cue(&code, :1delay-between, :1times, :&stop);
sleep(4);
check(1, ':1times and :3stop');

my $caught;
$cancel = cue({die 'catch this'}, :1delay-between, catch => { $caught = $^a.message });
sleep(1);
$cancel.cancel;
is $caught, 'catch this', 'did catch';

done-testing;
