function [pop,score,nonDomRank,Distance]  = rankAndDistance_debugg(pop,score,options,nParents)
	%rankAndDistance Assign rank and distance measure to each individual

	%   Copyright 2007 The MathWorks, Inc.
	%   $Revision: 1.1.6.1 $  $Date: 2009/08/29 08:27:00 $

	if nargin < 4
		nParents = size(pop,1);
	end

	ParetoFraction = .35;%options.ParetoFraction;
	nScore = size(score,2);
	if nScore == 1 % single objective
		nonDomRank = nonDominatedRank_debugg(score,nParents);
		% Remove individuals with infinite rank
		index = isinf(nonDomRank);
		nonDomRank(index) = [];
		pop(index,:) = [];
		score(index,:) = [];
	else
		nonDomRank = nonDominatedRank_debugg(score);
	end
	popSize = size(pop,1);
	Distance = zeros(popSize,1);
	numRank = unique(nonDomRank); % numRank will be sorted

	% Compute crowding distance for individuals in each front
	for i = numRank'
	   % Get individual from each front
	   index = (nonDomRank == i);
	%   Distance(index) = options.DistanceMeasureFcn(pop(index,:),score(index,:),options,options.DistanceMeasureFcnArgs{:}); 
		Distance(index) = distanceCrowding_debugg(pop(index,:),score(index,:));
	end

	% If populations were not combined then no need to trim the population
	if nParents == popSize
		% do nothing
	else
		[pop,score,nonDomRank,Distance] = trimPopulation(pop,score,nonDomRank,Distance, ...
			popSize,nScore,nParents,ParetoFraction);
	end
end

function crowdingDistance = distanceCrowding_debugg(pop,score,options,space)
	%DISTANCECROWDING Assign local crowding distance to each individual
	%   CROWDINGDISTANCE = DISTANCECROWDING(POP,SCORE,OPTIONS,SPACE) Calculates
	%   crowding distance for each individuals on a non-dominated front. The
	%   fourth argument SPACE can be 'phenotype' or 'genotype' for distance to
	%   be in function space or decision variable space respectively.
	%
	%   Example:
	%   Create an options structure using DISTANCECROWDING as the distance
	%   function in decision variable space
	%     options = gaoptimset('DistanceMeasureFcn',{@distancecrowding,'genotype'}); 

	%   Reference: Kalyanmoy Deb, "Multi-Objective Optimization using
	%   Evolutionary Algorithms", John Wiley & Sons ISBN 047187339, pg: 245 -
	%   253

	%   Copyright 2007 The MathWorks, Inc.
	%   $Revision: 1.1.6.1 $  $Date: 2009/08/29 08:24:23 $

	if nargin < 4
		space = 'phenotype';
	end

	% Score should be finite to work with 'phenotype' distance 
	%if strcmpi(space,'phenotype') && nnz(~isfinite(score)) == 0
		y = score;
	%else % if strcmpi(space,'genotype')
	%    y = pop;
	%end

	popSize = size(y,1);
	numData = size(y,2);
	crowdingDistance = zeros(popSize,1);

	for m = 1:numData       %   m is pareto front index
		data = y(:,m);
		% Normalize obective before computing distance
		data = data./(1 + max(abs(data(isfinite(data)))));
		[sorteddata,index] = sort(data);
		% The best and worst individuals are at the end of Pareto front and
		% they are assigned Inf distance measure
		crowdingDistance([index(1),index(end)]) = Inf;
		% Distance measure of remaining individuals
		i = 2;
		while i < popSize
			crowdingDistance(index(i)) = crowdingDistance(index(i)) + ...
				min(Inf, (data(index(i+1)) - data(index(i-1))));
			i = i+1;
		end
	end
end

function nondominatedRank = nonDominatedRank_debugg(score,nParent)
	%nonDominatedRank Assigns rank to individuals in 'score'. 
	%   The optional argument 'nParent' will limit rank assignment to only
	%   'nParent' individuals.

	%   Copyright 2007-2009 The MathWorks, Inc.
	%   $Revision: 1.1.6.2 $  $Date: 2009/10/10 20:09:25 $


	% Population size
	popSize = size(score,1);
	if nargin < 2
		nParent = popSize;
	end
	% Boolean to track if individuals are ranked
	rankedIndiv = false(popSize,1);
	% Initialization: rank of individuals (denotes which front)
	nondominatedRank = inf(popSize,1);

	numObj = size(score,2);
	dominationMatrix = false(popSize);
	% First test for domination is to check which points have better function
	% values in at least one of the objectives
	for count = 1:numObj
		dominationMatrix = dominationMatrix | bsxfun(@lt,score(:,count),score(:,count)');
	end
	% Now, check to see if those points that pass the first test, if they are
	% at least as good as others in all the objectives
	for count = 1:numObj
		dominationMatrix = dominationMatrix & bsxfun(@le,score(:,count),score(:,count)');
	end
	% We will do the test along the column
	dominationMatrix = ~dominationMatrix;

	% At this point, we have the domination matrix that may look like this
	% (example only). 
		%     p1  p2  p3  p4  p5
		% p1  1   1   0   1   1
		%
		% p2  1   1   0   1   1
		%
		% p3  0   1   1   1   1
		%
		% p4  0   0   1   1   0
		%
		% p5  1   1   0   1   1

	% In this matrix, if (i,j) entry is '1' then jth individual dominates ith
	% individual else it does not dominate ith individual. Also, if all the
	% entries in a column are '1' then it is a non-dominated individual. In
	% this example we have 5 points. From this matrix we can tell that 4th
	% point is non-dominated since 4th column has all '1'. In the first
	% iteration (rank = 1) p4 will be chosen as non-dominated individual.

	rankCounter = 1;
	while ~all(rankedIndiv) && nnz(isfinite(nondominatedRank)) <= nParent
		dominates = all(dominationMatrix);
		nondominatedRank(dominates) = rankCounter;
		rankCounter = rankCounter + 1;
	%=========================================================================
		% We want to remove p4 from the population but we don't want to change
		% the matrix size. Instead, we turn all the entris in the 4th row to
		% '1' which means that p4 is dominated by every other individuals
		% (effectively).
		dominationMatrix(dominates,:) = true;

		%     p1  p2  p3  p4  p5
		% p1  0   1   0   1   1
		%
		% p2  1   1   0   1   1
		%
		% p3  0   1   1   1   1
		%
		% p4  1   1   1   1   1   
		%
		% p5  1   1   0   1   1

		% By this action, p2 and p5 are now non-dominated individuals
		% (excluding p3) in the remaining pool.

	%==========================================================================
		% Next, make sure we don't pick the same individuals again. For this to
		% happen, we turn the (4,4) element to '0'.
		dominationMatrix(dominates,dominates) = false;

		%     p1  p2  p3  p4  p5
		% p1  1   1   0   1   1
		%
		% p2  1   1   0   1   1
		%
		% p3  0   1   1   1   1
		%
		% p4  1   1   1   0   1   
		%
		% p5  1   1   0   1   1

		% In the next iteration (rank = 2) p5 and p2 will be chosen but not p4. 
	%==========================================================================

		rankedIndiv(dominates) = true;
	end


	% For the above example, it will take 4 iterations to find exactly 4 pareto
	% fronts (with rank = 1, 2, 3, and 4). At the end of the 2nd iteration, the
	% matrix will look like this (two fronts found)
		%     p1  p2  p3  p4  p5
		% p1  1   1   1   1   1
		%
		% p2  1   0   1   1   1
		%
		% p3  0   1   1   1   1
		%
		% p4  1   1   1   0   1   
		%
		% p5  1   1   1   1   0

	% and, after the 3rd iteration it will look like this (3rd front will be
	% found)

		%     p1  p2  p3  p4  p5
		% p1  1   1   1   1   1
		%
		% p2  1   0   1   1   1
		%
		% p3  1   1   0   1   1
		%
		% p4  1   1   1   0   1   
		%
		% p5  1   1   1   1   0

	% and after the 4th iteration (last) the matrix will be not used anymore
	% but it will look like this:

		%     p1  p2  p3  p4  p5
		% p1  0   1   1   1   1
		%
		% p2  1   0   1   1   1
		%
		% p3  1   1   0   1   1
		%
		% p4  1   1   1   0   1   
		%
		% p5  1   1   1   1   0

end


