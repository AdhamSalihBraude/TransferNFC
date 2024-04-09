function PopulationUpdated = Evaluation1D(Population,SystemParameters,ArenaParameters)
N = length(Population);
PopulationUpdated = Population;
for  IndIdx = 1 : N
    warning("off")
    FIS = GenFisController(Population(IndIdx).Eprameters,Population(IndIdx).delEprameters...
        ,Population(IndIdx).Cparameters,Population(IndIdx).Uparameters);
    [PopulationUpdated(IndIdx).Jt,PopulationUpdated(IndIdx).Jc,PopulationUpdated(IndIdx).Jv] =...
        EvaluateFIS(FIS,SystemParameters,ArenaParameters,0);
    PopulationUpdated(IndIdx).F = [PopulationUpdated(IndIdx).Jt;PopulationUpdated(IndIdx).Jc];

end