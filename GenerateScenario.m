function [SystemParameters,ArenaParameters] = GenerateScenario(numOfobs,GoalPoint,InitialPosition)

m = 1;
Fmax = 50;
vmax = 5;
GoalSpeed = 0;
InitialSpeed = 0;
SystemParameters(1) = m;
SystemParameters(2) = Fmax; % Max Force
SystemParameters(3) = vmax; % Max speed
SystemParameters(4) = GoalPoint;
SystemParameters(5) = GoalSpeed;
SystemParameters(6) = InitialPosition;
SystemParameters(7) = InitialSpeed;
if numOfobs ~= 0
    ArenaParameters(numOfobs).mu = 0;
    ArenaParameters(numOfobs).sigma = 0;
    ArenaParameters(numOfobs).ValRatio = 0;
    for i  = 1 : numOfobs
        ArenaParameters(i).mu = InitialPosition+0.5 + (GoalPoint-0.5 - (InitialPosition+0.5))*(rand());
        ArenaParameters(i).sigma = min(GoalPoint-ArenaParameters(i).mu,ArenaParameters(i).mu-InitialPosition)/(4);
        ArenaParameters(i).ValRatio = 0.5 + 0.5*rand();
    end

else
    ArenaParameters.mu = InitialPosition - 10^5;
    ArenaParameters.sigma = 0.1;
    ArenaParameters.ValRatio = 1;
end
% % % for debugging
% X = SystemParameters(4):0.1:SystemParameters(5);
% [O,Vratio] = ObstFunc(X,ArenaParameters);
% for i = 1 : size(O,1)
%     plot(X,O(i,:));
%     hold on
%     grid on
% end
% hold off
end
