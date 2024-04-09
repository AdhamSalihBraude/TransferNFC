function PopulationUpdated = Evaluation1DMultiScenario(Population,Scenario,objType)
N = length(Population);
PopulationUpdated = Population;
for  IndIdx = 1 : N
    warning("off")
    FIS = GenFisController(Population(IndIdx).Eprameters,Population(IndIdx).delEprameters...
        ,Population(IndIdx).Cparameters,Population(IndIdx).Uparameters);
    Jt = nan(length(Scenario),1);
    Jc = nan(length(Scenario),1);
    Jv = nan(length(Scenario),1);
    for i = 1 : length(Scenario)
        [Jt(i,1),Jc(i,1),Jv(i,1)] =...
            EvaluateFIS(FIS,Scenario(i).SystemParameters,Scenario(i).ArenaParameters,1);
        if objType == 1
            F(i,1) = Jt(i,1);
        elseif objType == 2
            F(i,1) = Jc(i,1);

        else
            F(i,1) = Jt(i,1)+Jc(i,1);

        end
    end
    PopulationUpdated(IndIdx).Jt = Jt;
    PopulationUpdated(IndIdx).Jv = Jv;
    PopulationUpdated(IndIdx).Jc = Jc;
    PopulationUpdated(IndIdx).F = F;
end