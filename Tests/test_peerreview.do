// Set seed
local startseed = 1234

log using test_v1_0_0_startseed`startseed', replace text nomsg

di "Compare means to expectations of 2000 outcomes of peerreview using different seeds"
di "Startseed = `startseed'"

clear
qui set obs 10
qui gen reviewer = _n
qui gen mean = .
qui gen cycle = 0

tempfile a
qui save `a', replace

forval i = 1/2000 {
	
	set seed `= `startseed' + `i' '
	qui peerreview, r(10) p(3) clear
	gen cycle = `i'
	egen mean = rowmean(review?)
	append using `a'
	qui save `a', replace
}

qui drop if cycle == 0
qui reg mean i.reviewer
margins i.reviewer, post
forval i = 1/10 {
	local expectation = (1+2+3+4+5+6+7+8+9+10-`i')/9
	lincom _b[`i'.reviewer] - `expectation'
}

collapse (mean) review*, by(cycle)
reshape long review, i(cycle) j(nr)
qui reg review i.nr
margins i.nr, post
forval i = 1/3 {
	local expectation = (1+2+3+4+5+6+7+8+9+10) / 10
	lincom _b[`i'.nr] - `expectation'
}

log close
