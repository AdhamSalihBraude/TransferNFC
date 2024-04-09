function Population = InitPop(PopSize,NRules)
%INITPOP Summary of this function goes here
%   Detailed explanation goes here
Population(PopSize).Eprameters = [sort(rand(1,3)), rand(1,3)];
Population(PopSize).delEprameters = [sort(-1 + 2*rand(1,3)),-1 + 2*rand(1,3)];
Population(PopSize).Cparameters = [sort(-1 + 2*rand(1,3)),-1 + 2*rand(1,3)];
Population(PopSize).Uparameters = rand(1,NRules);
Population(PopSize).Jt = [];
Population(PopSize).Jc = [];
Population(PopSize).Jv = [];
Population(PopSize).F = [];
Population(PopSize).Rank = inf;
Population(PopSize).CrowdDis = 0;
for i = 1 : PopSize-1
    Population(i).Eprameters = [sort(rand(1,3)), rand(1,3)];
    Population(i).delEprameters = [sort(-1 + 2*rand(1,3)),-1 + 2*rand(1,3)];
    Population(i).Cparameters = [sort(-1 + 2*rand(1,3)),-1 + 2*rand(1,3)];
    Population(i).Uparameters = linspace(-1,1,NRules);
    Population(i).Jt = [];
    Population(i).Jc = [];
    Population(i).Jv = [];
    Population(i).F = [];
    Population(i).Rank = inf;
    Population(i).CrowdDis = 0;
end

