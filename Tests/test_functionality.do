// Functionality tests peerreview
discard
clear all
set obs 12
gen student = _n
gen group = ceil(_n / 3)

// Syntax 
cap peerreview
assert _rc == 100

cap peerreview group
assert _rc == 198

preserve
peerreview student, r(2)
restore

preserve
peerreview student, r(2, name(paper))
restore

preserve
peerreview student, r(2, name(paper)) by(group)
restore

preserve
bys group : peerreview student, r(2, name(paper))
restore

preserve
cap bys group : peerreview student, r(2, name(paper)) by(group)
assert _rc == 198
restore

preserve
peerreview student if group == 3, r(2, name(paper))
restore

preserve
peerreview student if group == 3, r(2, name(paper)) by(group)
restore

preserve
cap peerreview student if group == 3 in 1/5, r(2, name(paper)) by(group)
assert _rc == 2000
restore

preserve
cap peerreview student if group == 3 in 1/5, r(2, name(paper))
assert _rc == 2000
restore

cap peerreview student, r(hello)
assert _rc == 7

cap peerreview student, r(3, n(h h))
assert _rc == 103

// Conditions
cap peerreview student, r(0)
assert _rc == 119

cap peerreview student, r(12)
assert _rc == 119

cap peerreview group, r(3)
assert _rc == 499

// String variables
tostring student, replace

// Syntax 
cap peerreview
assert _rc == 100

cap peerreview group
assert _rc == 198

preserve
peerreview student, r(2)
restore

preserve
peerreview student, r(2, name(paper))
restore

preserve
peerreview student, r(2, name(paper)) by(group)
restore

preserve
bys group : peerreview student, r(2, name(paper))
restore

preserve
cap bys group : peerreview student, r(2, name(paper)) by(group)
assert _rc == 198
restore

preserve
peerreview student if group == 3, r(2, name(paper))
restore

preserve
peerreview student if group == 3, r(2, name(paper)) by(group)
restore

preserve
cap peerreview student if group == 3 in 1/5, r(2, name(paper)) by(group)
assert _rc == 2000
restore

preserve
cap peerreview student if group == 3 in 1/5, r(2, name(paper))
assert _rc == 2000
restore

cap peerreview student, r(hello)
assert _rc == 7

cap peerreview student, r(3, n(h h))
assert _rc == 103

di "All tests passed"
