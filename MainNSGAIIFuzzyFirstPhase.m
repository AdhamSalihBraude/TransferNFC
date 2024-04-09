%% Transferability of Multi-objective Neuro-fuzzy Motion Controllers: 
% Towards  Cautious and Courageous Motion Behaviors in Rugged Terrains 
% Solving the MO source problems.
% The code generates MO-scource problems and solves them


clc
clear
close all

%% General Parameters
% GA Parameters
rng('shuffle')
PopSize = 20; %number of individuals
MaxGen = 300; % maximal number of generations
CrossOverRate = 0.8;
MutationRate = 0.2;
PlotFlag = 1; % 1 for plotting during the run
ThreeDflag = 0; % if it 3D objective space
% System Data
NumSc = 10; % number of scenarios to generate
InitialPosition = -10; 
GoalPoint = 0;
NumofRuns = 1;

% FIS parameters
NRules = 27;
%% First Generation

for RunIdx = 1 : NumofRuns
    for ScIdx = 1:NumSc
        % DataStruc
        Data = [];
        Data(MaxGen).Population = [];
        Data(MaxGen).NonDominated = [];

        tic
        ParallelCPU = 1;
        NumberOfObstacles = randi(5); %randomly init. the number of obtacles
        [SystemParameters,ArenaParameters] = GenerateScenario(NumberOfObstacles,GoalPoint,InitialPosition);
        
        Population = InitPop(PopSize,NRules);
        if ParallelCPU
            Population = Evaluation1DParallel(Population,SystemParameters,ArenaParameters);
        else
            Population = Evaluation1D(Population,SystemParameters,ArenaParameters);
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
            if size(NonDominatedValues,2) == 2

                plot(NonDominatedValues(:,1),NonDominatedValues(:,2),'xr')


                title(['Generation number  ', num2str(GenCounter)])
                grid on

                drawnow
            end
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
                Offsprings = Evaluation1DParallel(Offsprings,SystemParameters,ArenaParameters);
            else
                Offsprings = Evaluation1D(Offsprings,SystemParameters,ArenaParameters);
            end

            Population = EliteFullSorting(Population,Offsprings);
            GenCounter = GenCounter + 1;
            FitnessValues = [Population(:).F]';
            NonDominated = Population(FrontNo==1);
            NonDominatedValues = [NonDominated(:).F]';
            
            [~,~,FrontNo,~]  = rankAndDistance_debugg(FitnessValues,FitnessValues);

            [~,ia,~] = unique(NonDominatedValues,'rows');
            NonDominated = NonDominated(ia);
            NonDominatedValues = [NonDominated(:).F]';
            Data(GenCounter).NonDominated = NonDominated;
            Data(GenCounter).Population = Population;
            if PlotFlag && rem(GenCounter,10)==0
                if size(NonDominatedValues,2) == 2

                    plot(NonDominatedValues(:,1),NonDominatedValues(:,2),'xr')


                    title(['Generation number  ', num2str(GenCounter)])
                    grid on

                    drawnow
                end
            end

            %
        end
        RunTime = toc;
        if ParallelCPU
            fprintf('\nTime with Parallel = %.5f \nTime per evaluation = %.5f',RunTime,RunTime/PopSize/MaxGen)
            save(['Run',num2str(RunIdx),'Sc',num2str(ScIdx),'Phase1'])
        else
            fprintf('\nTime without Parallel = %.5f',avgTime/PopSize)
            save(['Run',num2str(RunIdx),'Sc',num2str(ScIdx),'Phase1'])
        end
    end
end
