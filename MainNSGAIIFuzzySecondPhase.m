

clc
clear
close all

%% General Parameters
% GA Parameters
rng('shuffle')
PopSize = 60; %number of individuals
MaxGen = 200; % maximal number of generations
CrossOverRate = 0.8;
MutationRate = 0.2;
PlotFlag = 0;
objType = 3; % 1-Fast, 2-Safe, 3 Balanced
% System Data
TargetSet = 2;
InitialPosition = -10;
GoalPoint = 0;


% DataSaver
Data(MaxGen).Population = [];
Data(MaxGen).NonDominated = [];
% FIS parameters
NRules = 27;
NumberOfScenarios = 3;

cont = 1; % 1 for using scenario from diffrent run 
folderPath = ['ResultsFuzzy\ScenarioSet',num2str(TargetSet),'\Type4']; % update to your folder path
mkdir(folderPath)
if cont==1
     % update to your file path
    load(['ResultsFuzzy\ScenarioSet',num2str(TargetSet),'\Type1\FixedSecondPhaseRun10WithParallel3ScenariosInitType2,objType1.mat'],'Scenario')
else
    for i = 1 : NumberOfScenarios
        NumberOfObstacles = randi(4);
        [Scenario(i).SystemParameters,Scenario(i).ArenaParameters] = GenerateScenario(NumberOfObstacles,GoalPoint,InitialPosition);
    end
end
%% First Generation
for RunIdx = 1:31
    Data(MaxGen).Population = [];
    Data(MaxGen).NonDominated = [];
    tic
    ParallelCPU = 1;

    NumOfPrevSc = 10;



    for InitType = 4:4 % 1-Balanced 2-edge 3-Random initialize 4-randomselection
        Data(MaxGen).Population = [];
        Data(MaxGen).NonDominated = [];
        if InitType == 3
            Population = InitPop(PopSize,NRules);
        else
            Population = InitPopFromData(PopSize,NRules,InitType,1,NumOfPrevSc);
        end
        if ParallelCPU
            Population = Evaluation1DMultiScenarioParallel(Population,Scenario,objType);
        else
            Population = Evaluation1DMultiScenario(Population,Scenario,objType);
        end
        GenCounter = 1;

        FitnessValues = [Population(:).F]';
        [~,~,FrontNo,~]  = rankAndDistance_debugg(FitnessValues,FitnessValues);
        NonDominated = Population(FrontNo==1);
        NonDominatedValues = [NonDominated(:).F]';
        [~,ia,~] = unique(NonDominatedValues,'rows');
        NonDominated = NonDominated(ia);
        NonDominatedValues = [NonDominated(:).F]';
        if PlotFlag

            plot3(FitnessValues(:,1),FitnessValues(:,2),FitnessValues(:,3),'.k'...
                ,NonDominatedValues(:,1),NonDominatedValues(:,2),NonDominatedValues(:,3),'xr')
            xlabel('Sc1');ylabel('Sc2');zlabel('Sc3')

            title(['Generation number  ', num2str(GenCounter)])
            grid on

            drawnow
        end
        Data(GenCounter).NonDominated = NonDominated;
        Data(GenCounter).Population = Population;
        MFORRules = 1;
        avgTime = 0;
        while GenCounter <= MaxGen

            if rem(GenCounter,10)==0
                MFORRules = ~MFORRules;
            end
            Population = CalcRankAndDistance(Population);
            MatingPool = SelectionFIS(Population);
            Offsprings = Reproduction(MatingPool,CrossOverRate,MutationRate,MFORRules);
            if ParallelCPU
                Offsprings = Evaluation1DMultiScenarioParallel(Offsprings,Scenario,objType);
            else
                Offsprings = Evaluation1DMultiScenario(Offsprings,Scenario,objType);
            end

            Population = EliteFullSorting(Population,Offsprings);
            GenCounter = GenCounter + 1;
            FitnessValues = [Population(:).F]';
            [~,~,FrontNo,~]  = rankAndDistance_debugg(FitnessValues,FitnessValues);
            NonDominated = Population(FrontNo==1);
            NonDominatedValues = [NonDominated(:).F]';

            [~,ia,~] = unique(NonDominatedValues,'rows');
            NonDominated = NonDominated(ia);
            NonDominatedValues = [NonDominated(:).F]';
            Data(GenCounter).NonDominated = NonDominated;
            Data(GenCounter).Population = Population;
            if rem(GenCounter,10)==0
                GenCounter
                if PlotFlag 

                    plot3(NonDominatedValues(:,1),NonDominatedValues(:,2),NonDominatedValues(:,3),'xr')
                    xlabel('Sc1');ylabel('Sc2');zlabel('Sc3')

                    title(['Generation number  ', num2str(GenCounter)])
                    grid on

                    drawnow
                end
            end

            %         fprintf('\nParallel = %d  GenCounter = %d  TimeLoop = %.5f  ', ParallelCPU,GenCounter,loopTime)
        end
        RunTime = toc;
        save([folderPath,'\FixedSecondPhaseRun',num2str(RunIdx),'WithParallel',num2str(NumberOfScenarios),'ScenariosInitType',num2str(InitType),',objType',num2str(objType)])
      
    end
end



