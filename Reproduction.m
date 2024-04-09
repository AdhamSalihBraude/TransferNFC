function Offsprings = Reproduction(MatingPool,CrossOverRate,MutationRate,MFOrRules)
N =  length(MatingPool);
Offsprings = MatingPool;
%% CrossOver
for i = 1 : 2 : N
    if MFOrRules 
        % Eprameters
        parent1 = MatingPool(i).Eprameters;
        parent2 = MatingPool(i+1).Eprameters;
        [child1, child2] = SBX(parent1,parent2,CrossOverRate,[-1 1]);
        child1(1:3) = sort(child1(1:3));
        child2(1:3) = sort(child2(1:3));
        Offsprings(i).Eprameters = child1;
        Offsprings(i+1).Eprameters = child2;
        % delEprameters
        parent1 = MatingPool(i).delEprameters;
        parent2 = MatingPool(i+1).delEprameters;
        [child1, child2] = SBX(parent1,parent2,CrossOverRate,[-1 1]);
        child1(1:3) = sort(child1(1:3));
        child2(1:3) = sort(child2(1:3));
        Offsprings(i).delEprameters = child1;
        Offsprings(i+1).delEprameters = child2;
        % Cparameters
        parent1 = MatingPool(i).Cparameters;
        parent2 = MatingPool(i+1).Cparameters;
        [child1, child2] = SBX(parent1,parent2,CrossOverRate,[-1 1]);
        child1(1:3) = sort(child1(1:3));
        child2(1:3) = sort(child2(1:3));
        Offsprings(i).Cparameters = child1;
        Offsprings(i+1).Cparameters = child2;
    else
        % Uparameters
        parent1 = MatingPool(i).Uparameters;
        parent2 = MatingPool(i+1).Uparameters;
        [child1, child2] = SBX(parent1,parent2,CrossOverRate,[-1 1]);
        Offsprings(i).Uparameters = child1;
        Offsprings(i+1).Uparameters = child2;
    end
    % init Fit
    Offsprings(i).Jt = [];
    Offsprings(i+1).Jt = [];
    Offsprings(i).Jc = [];
    Offsprings(i+1).Jc = [];
    Offsprings(i).Jv = [];
    Offsprings(i+1).Jv = [];
    Offsprings(i).Rank = inf;
    Offsprings(i+1).Rank = inf;
    Offsprings(i).CrowdDis = 0;
    Offsprings(i+1).CrowdDis = 0;
    Offsprings(i).F = [];
    Offsprings(i+1).F = [];
end

% mutation
for i = 1 : N
    if MFOrRules
        % Eprameters
        parent = MatingPool(i).Eprameters;
        child = PolyMutation(parent,MutationRate,[-1 1]);
        child(1:3) = sort(child(1:3));
        Offsprings(i).Eprameters = child;

        % delEprameters
        parent = MatingPool(i).delEprameters;
        child = PolyMutation(parent,MutationRate,[-1 1]);
        child(1:3) = sort(child(1:3));
        Offsprings(i).delEprameters = child;

        % Cparameters
        parent = MatingPool(i).Cparameters;
        child = PolyMutation(parent,MutationRate,[-1 1]);
        child(1:3) = sort(child(1:3));
        Offsprings(i).Cparameters = child;
    else
        % Uparameters
        parent = MatingPool(i).Uparameters;
        child = PolyMutation(parent,MutationRate,[-1 1]);
        Offsprings(i).Uparameters = child;
    end
end
