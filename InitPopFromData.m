function Population = InitPopFromData(PopSize,NRules,InitType,RunIdx,NumOfPrevSc)
Population = [];
NperSc = floor(PopSize/NumOfPrevSc);
debugggg = 0;
for i = 1 : NumOfPrevSc
    load(['Run',num2str(RunIdx),'Sc',num2str(i),'Phase1.mat'],'NonDominated','NonDominatedValues')
    maxF = max(NonDominatedValues,[],1);
    minF = min(NonDominatedValues,[],1);
    NonDominatedValues = (NonDominatedValues-minF)./(maxF-minF);
    if InitType==1 % Balanced
        CenterLine = [0:0.1:1;0:0.1:1]';
        distFromCenter = ones(size(NonDominatedValues,1),1);
        for j = 1 : size(NonDominatedValues,1)
            distFromCenter(j,1) = min(sqrt(sum((NonDominatedValues(j,:)-CenterLine).^2,2)));
        end
        [~,I] = sort(distFromCenter);
        Population = [Population,NonDominated(I(1:min(NperSc,length(NonDominated))))];
        if debugggg
            figure()
            plot(NonDominatedValues(:,1),NonDominatedValues(:,2),'.k',CenterLine(:,1),CenterLine(:,2),'--k',NonDominatedValues(I(1:NperSc),1),NonDominatedValues(I(1:NperSc),2),'sk')
            grid on
            %         title(['Center Selection ',num2str(NperSc),' Solutions'])
        end
    elseif InitType==4 % random selection
        I = randperm(length(NonDominated),NperSc);
        Population = [Population,NonDominated(I)];
        if debugggg
            figure()
            plot(NonDominatedValues(:,1),NonDominatedValues(:,2),'.k',NonDominatedValues(I,1),NonDominatedValues(I,2),'^k')
            grid on
        end

    else %defult edge
        if rem(NperSc,2) ~= 0
            NperSc = NperSc - 1;
        end
        %1stEdge
        [~,I1] = sort(NonDominatedValues(:,1));
        Population = [Population,NonDominated(I1(1:NperSc/2))];

        %2ndEdge
        [~,I2] = sort(NonDominatedValues(:,2));
        Population = [Population,NonDominated(I2(1:NperSc/2))];
        if debugggg
            figure()
            plot(NonDominatedValues(:,1),NonDominatedValues(:,2),'.k',NonDominatedValues(I1(1:NperSc/2),1),NonDominatedValues(I1(1:NperSc/2),2),'ok',NonDominatedValues(I2(1:NperSc/2),1),NonDominatedValues(I2(1:NperSc/2),2),'ok')
            grid on
            %             title(['Edge Selection ',num2str(NperSc),' Solutions'])

        end
    end
    if length(Population) < PopSize
        Population = [Population,InitPop(PopSize-length(Population),NRules)];
    elseif length(Population) > PopSize
        Population = Population(1:PopSize);
    end
end