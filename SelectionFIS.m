function MatingPool = SelectionFIS(Population)
N = length(Population);
MatingPool(N) = Population(1);
idx = randi(N,N,2);
for i = 1 : N
    if Population(idx(i,1)).Rank < Population(idx(i,2)).Rank
        MatingPool(i) = Population(idx(i,1));
    elseif Population(idx(i,1)).Rank > Population(idx(i,2)).Rank
        MatingPool(i) = Population(idx(i,2));
    elseif Population(idx(i,1)).CrowdDis > Population(idx(i,2)).CrowdDis
        MatingPool(i) = Population(idx(i,1));
    else
        MatingPool(i) = Population(idx(i,2));
    end
end
end