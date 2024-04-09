function Population = CalcRankAndDistance(Population)
FitnessValues = [Population(:).F]';
maxF = max(FitnessValues,[],1);
minF = min(FitnessValues,[],1);
FitnessValues = (FitnessValues - minF)./(maxF - minF);
[~,~,Ranks,Distance] = rankAndDistance_debugg(FitnessValues,FitnessValues);

for i = 1 : length(Population)
    Population(i).Rank = Ranks(i);
    Population(i).CrowdDis = Distance(i);
end
end