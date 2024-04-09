function PopulationUpdated = EliteFullSorting(Population,Offsprings)
N = length(Population);

FitnessValues = [Population(:).F]';
[~,ia,~] = unique(FitnessValues,'rows');
Population = Population(ia);
AllPop = [Population,Offsprings];
% if ThreeDflag
%     FitnessValues = [[AllPop(:).Jt]',[AllPop(:).Jc]',[AllPop(:).Jv]'];
% else
%     FitnessValues = [[AllPop(:).Jt]',[AllPop(:).Jc]'];
% end
[~,ia,~] = unique(FitnessValues,'rows');
if length(ia) == 1
    AllPop = AllPop(ia);
end
AllPop = CalcRankAndDistance(AllPop);
AllPop(isnan([AllPop(:).CrowdDis]))=[];
RankAndDistMatrix = [[AllPop(:).Rank]',[AllPop(:).CrowdDis]'];
[~, I ] = sortrows(RankAndDistMatrix,[1 -2]);
if length(I)>N
    PopulationUpdated = AllPop(I(1:N));
else
    PopulationUpdated = AllPop;
    while length(PopulationUpdated) < N
        PopulationUpdated = [PopulationUpdated,AllPop(randi(length(AllPop)))];
    end
end

