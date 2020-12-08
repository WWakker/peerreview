*! 1.0.2                08dec2020
*! Wouter Wakker     	wouter.wakker@outlook.com

* 1.0.2     08dec2020   simplified syntax; string variables are encoded first
* 1.0.1     30jun2020   aesthetic changes
* 1.0.0     15apr2020   born

program define peerreview
	version 9.0
	
	// Syntax 
	syntax varname, Review(string)
	
	// Get number of reviews to be assigned and varname
	parse_name_opt `review'
	local reviews `s(integer)'
	local var_reviews `s(newvarname)'
	if "`var_reviews'" == "" local var_reviews "review" // Default
	
	// Store observations
	local reviewers `=_N'

	// Argument conditions
	qui tab `varlist'
	if `r(r)' != `=_N' & "`number'" == "" {
		di as error "duplicate or missing values in variable {bf:`varlist'}"
		exit 499
	}

	if `reviews' < 1 {
		di as error "number of reviews must be at least 1"
		exit 119
	}
	
	if `reviewers' < 2 {
		di as error "number of reviewers must be at least 2"
		exit 119
	}
	
	if `reviewers' <= `reviews' {
		di as error "number of reviews must be smaller than number of reviewers"
		exit 119
	}
	
	// Preserve the data
	preserve
	
	// Check if variable is string or numeric
	cap confirm string variable `varlist'
	if _rc {
		local isstring 0
		local var_reviewer `varlist'
	}
	else {
		local isstring 1
		tempvar var_reviewer
		encode `varlist', gen(`var_reviewer')
	}
	
	// Create list of reviews based on varname
	qui levelsof `varlist', local(levels) clean
	forval i = 1/`reviews' {
		local review_pool `review_pool' `levels'
	}
	
	// Check if variables to be created exist already
	if `reviews' == 1 {
		confirm new variable `var_reviews'
		if `isstring' {
			tempvar `var_reviews'
			local var_reviews_label ``var_reviews''
		}
	}
	else {
		forval i = 1/`reviews' {
			confirm new variable `var_reviews'`i'	
			if `isstring' {
				tempvar `var_reviews'`i'
				local var_reviews_label `var_reviews_label' ``var_reviews'`i''
			}
		}
	}

	// Mata: create inlist conditions and reviewer/author combination matrix
	mata {
		rvws  = strtoreal(st_local("reviews"))
		rvwrs = strtoreal(st_local("reviewers"))
		
		// Create empty matrices
		inlist_mat = J(1, rvws, ".")
		rev_auth_comb_mat = J(rvws * rvwrs, 2, .)
		
		row_nr = 1
		for (i=1; i<=rvws; i++) {
			// Create author/review combination matrix
			for (j=1; j<=rvwrs; j++) {
				rev_auth_comb_mat[row_nr, 1] = j
				rev_auth_comb_mat[row_nr, 2] = i
				row_nr++
			}
			// Create inlist conditions for inlist below (conditions are different for different number of reviews)
			if (rvws == 1) {
				if (`isstring') inlist_mat[i] = ", \``var_reviews''" + "[\`i']"
				else inlist_mat[i] = ", `var_reviews'" + "[\`i']"
			}
			else {
				if (`isstring') inlist_mat[i] = ", \``var_reviews'" + strofreal(i) + "'[\`i']"
				else inlist_mat[i] = ", `var_reviews'" + strofreal(i) + "[\`i']"
			}
		}
		st_local("inlist_cond", invtokens(inlist_mat))
	}
		

	// Shuffle list of reviews and assign to reviewers
	// Reviews are put at the end of the list if one of the conditions is not satisfied
	// In some cases, the reviews that are left cannot satisfy the conditions for the last couple of reviewers
	// If this is the case, the loop breaks and the list of reviews is reshuffled
	local iterations = 1
	local counter = 1
	while `counter' != `= `reviewers' * `reviews' + 1' { // Only false when succesfully assigned reviews to all reviewers
		
		// Randomize list of reviews and assignment order
		mata : A = strofreal(jumble(rev_auth_comb_mat))
		mata : st_local("reviewer_nr", invtokens(A[1...,1]'))
		mata : st_local("author_nr", invtokens(A[1...,2]'))
		mata : st_local("review_list", invtokens(jumble(A[1...,1]')))
		
		// Generate review variables
		if `reviews' == 1 {
			if `isstring' {
				cap drop ``var_reviews''
				qui gen ``var_reviews'' = .
			}
			else {
				cap drop `var_reviews'
				qui gen `var_reviews' = . 
			}		
		}
		else {
			if `isstring' {
				forval i = 1/`reviews' {
					cap drop ``var_reviews'`i''
					qui gen ``var_reviews'`i'' = .
				}
			}
			else {
				forval i = 1/`reviews' {
					cap drop `var_reviews'`i'
					qui gen `var_reviews'`i' = .
				}
			}
		}
		
		// Assign reviews to reviewers
		local counter = 1
		local cond_not_satisf = 0
		foreach rvw of local review_list {
			local i : word `counter' of `reviewer_nr'
			local j : word `counter' of `author_nr'

			if `var_reviewer'[`i'] == `rvw' | inlist(`rvw' `inlist_cond') { // Conditions: Reviewer cannot review themselves or review more than once
				local review_list `review_list' `rvw' // Add review to the end of the list
				local ++cond_not_satisf // Count times condition not satisfied
				if `cond_not_satisf' == `= `reviews' * 2 ' {
					local ++iterations
					continue, break // Break and reshuffle if condition is repeatedly not satisfied
				}
				continue
			}
			
			// Assign review to reviewer
			if `isstring' {
				if `reviews' == 1 qui replace ``var_reviews'' = `rvw' in `i' 
				else qui replace ``var_reviews'`j'' = `rvw' in `i' 
			}
			else {
				if `reviews' == 1 qui replace `var_reviews' = `rvw' in `i'
				else qui replace `var_reviews'`j' = `rvw' in `i'
			}
			
			// Reset count condition not satisfied
			local cond_not_satisf = 0 
			local ++counter
		}
	}
	
	// Decode review variables
	if `isstring' {
		lab val `var_reviews_label' `var_reviewer'
		if `reviews' == 1 decode ``var_reviews'', gen(`var_reviews')
		else {
			forval i = 1/`reviews' {
				decode ``var_reviews'`i'', gen(`var_reviews'`i')
			}
		}
	}
	
	restore, not

	di as txt "succesfully assigned; " as res `iterations' as txt " iteration(s)"
end

// Parser for options with name suboption
program parse_name_opt, sclass
	version 9.0
    
	syntax anything(id="integer") [, Name(name)]
	confirm integer number `anything'
    
	sreturn local integer `anything'
	sreturn local newvarname `name'
end
