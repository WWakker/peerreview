clear all

// Set seed
local seed 1234
set seed `seed'

log using test_means_expectations_seed`seed', replace text nomsg

// Setup
set obs 10000
gen reviewer = mod(_n - 1, 10) + 1
gen group = ceil(_n / 10)

// Assign
qui peerreview reviewer, r(3) by(group)
egen mean = rowmean(review?)

// Check whether the rowmean is significantly different from its expectation
qui reg mean i.reviewer
margins i.reviewer, post

forval i = 1/10 {
	local expectation = (1+2+3+4+5+6+7+8+9+10-`i')/9
	local xlincom_exp `xlincom_exp' (`i'.reviewer - `expectation')
}

// Result
xlincom `xlincom_exp'

// Check whether column mean is different from expectation
collapse (mean) review*, by(group)
reshape long review, i(group) j(nr)
qui reg review i.nr
margins i.nr, post

local xlincom_exp
local expectation = (1+2+3+4+5+6+7+8+9+10) / 10
forval i = 1/3 {
	local xlincom_exp `xlincom_exp' (`i'.nr - `expectation')
}

// Result
xlincom `xlincom_exp'

log close
