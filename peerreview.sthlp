{smcl}
{* *! version 1.0.2  08dec2020}{...}
{viewerjumpto "Syntax" "peerreview##syntax"}{...}
{viewerjumpto "Description" "peerreview##description"}{...}
{viewerjumpto "Options" "peerreview##options"}{...}
{viewerjumpto "Examples" "peerreview##examples"}{...}
{title:Title}

{phang}
{bf:peerreview} {hline 2} Randomly assign papers to peers for review


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:peerreview} {varname}
{cmd:,} 
{cmdab:r:eview(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}


{synoptset 32 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:r:eview(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}}expects number of reviews; integer{p_end}
{synoptline}
{syntab:name_suboption}
{synopt:{opth n:ame(newvar)}}specifies name for new variable(s) to be generated{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:peerreview} randomly assigns papers to peers for review, based on the 
principle of assignment without replacement which ensures that each paper is 
assigned an equal number of times. Assignment is carried out with two 
constraints: Reviewers cannot review their own paper and reviewers cannot 
read papers more than once.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:review(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)} expects number of reviews; integer

{dlgtab:name_suboption}

{phang}
{opth name(newvar)} specifies name for new variable(s) to be generated
{break}The default is {it:review#}


{marker examples}{...}
{title:Examples}

{pstd}Create dataset assigning 1 paper each to 3 reviewers{p_end}
{phang}{cmd:. set seed 1234}{p_end}
{phang}{cmd:. peerreview, reviewers(3) papers(1) clear}{p_end}

{pstd}Create dataset assigning 2 papers each to 3 reviewers with non-default variable names{p_end}
{phang}{cmd:. set seed 2020}{p_end}
{phang}{cmd:. peerreview, r(3, n(student)) p(2, n(peer)) clear}{p_end}

{pstd}Assign 2 papers to each student of variable {cmd:student}, using the values (names) of {cmd:student}{p_end}
{phang}{cmd:. input str14 student}{p_end}
{phang}{space 12}student{p_end}
{phang}{cmd:  1. "John Smith"}{p_end}
{phang}{cmd:  2. "James Black"}{p_end}
{phang}{cmd:  3. "Maria Garcia"}{p_end}
{phang}{cmd:  4. "Patricia Brown"}{p_end}
{phang}{cmd:  5. end}{p_end}
{phang}{cmd:. set seed 1122}{p_end}
{phang}{cmd:. peerreview student, p(2)}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Wouter Wakker, wouter.wakker@outlook.com
