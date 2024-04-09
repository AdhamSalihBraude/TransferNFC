function [Jt,Jc,Jv,T] = EvaluateFISTime(FIS,SystemParameters,ArenaParameters,plotflag)
% EvaluateFIS calculates objectives value for a given 1D scenario
%   FIS is a fuzzy controller
%   ObstFunc is a function that produces a drag constant c as function of the position
%   SystemParameters is a row vector of [m,Fmax,vmax,GoalPoint,GoalSpeed,x_initial,v_initial]
%   plotflag = 1 for plotting

InitialPosition = SystemParameters(6);
InitialSpeed = SystemParameters(7);
vmax = SystemParameters(3); % Max speed

GoalPoint = SystemParameters(4);
% GoalSpeed = SystemParameters(5);
Tmin = abs(GoalPoint-InitialPosition)/(vmax);
tfinal = 20;
tspan = 0 : 0.01 : tfinal;
X0 = [InitialPosition,InitialSpeed,0,0,0,0,0,0,0];
Opt    = odeset('Events', @myEvent);
[tout, X] = ode45(@(t, x) OneDDrive(t, x, FIS,SystemParameters,ArenaParameters), tspan, X0');
[errorPos, I] = min(abs(GoalPoint-X(:,1)));
if errorPos > abs(GoalPoint-InitialPosition)/2
    I = length(tout);
end

Jt = 1-Tmin/X(I,3);
T = X(I,3);
X(X(:,2)>vmax,2) = vmax;
X(X(:,2)<-vmax,2) = -vmax;
[O,Vratio] = ObstFunc(X(1:I,1),ArenaParameters);
maxVaiolation = max(O.*X(1:I,2)');
Jc = X(I,8) + maxVaiolation;
Jv = abs(X(I,2));
VaiolateSpeed = X(I,9)>0;
% for i = 1 : length(X(:,2))
%     X(i,2) = min([X(i,2),vmax]);
%     X(i,2) = max([-vmax,X(i,2)]);
% end

if errorPos > 1e-2
    Jt = (1+Jt)*errorPos*100;
    Jc = (1+Jc)*errorPos*100;
    Jv = (1+Jv)*errorPos*100;
end
errorPosEnd = abs(GoalPoint-X(I,1));
if errorPosEnd > 1e-2
    Jt = (1+Jt)*errorPosEnd*100;
    Jc = (1+Jc)*errorPosEnd*100;
    Jv = (1+Jv)*errorPosEnd*100;
end
Maxerr = max(abs(GoalPoint-X(1:I,1))/(GoalPoint-InitialPosition));
if VaiolateSpeed
    Jt = (1+Jt)*100;
    Jc = (1+Jc)*100;
    Jv = (1+Jv)*100;
end
if Maxerr>1
    Jt = (1+Jt)*Maxerr*100;
    Jc = (1+Jc)*Maxerr*100;
    Jv = (1+Jv)*Maxerr*100;
end

if plotflag
    fig = figure();
    set(fig,'defaultAxesColorOrder',[0.15,0.15,0.15; 0.15,0.15,0.15]);
    subplot(3,1,1)
    
    yyaxis left

    plot(tout(1:I),X(1:I,1),'k',tout(I),GoalPoint,'kx','LineWidth',1.25)
    xlabel('time[sec]')
    ylabel('x(t)[m]')
    %hold on
    yyaxis right

    plot(tout(1:I),O,'--k','LineWidth',1.25)
    ylabel('C(x(t))')
    %hold off
    grid on
    subplot(3,1,2)
    yyaxis left
    plot(tout(1:I),X(1:I,2),'k','LineWidth',1.25)
    ylim([-0.2 vmax+0.2])
    
    xlabel('time[sec]')
    ylabel('V(t)[m/s]')
    %hold on
    yyaxis right
    plot(tout(1:I),Vratio*vmax,'--k','LineWidth',1.25)
    ylabel('V_O(x(t))[m/s]')
    ylim([-0.2 vmax+0.2])
    %hold off
    grid on
    subplot(3,1,3)
    yyaxis left
    plot(X(1:I,1),O,'k','LineWidth',1.25)
    ylabel('C(x)')
    xlabel('x[m]')
    yyaxis right
    plot(X(1:I,1),Vratio*vmax,'--k','LineWidth',1.25)
    ylabel('V_O(x)[m/s]')
    ylim([-0.2 vmax+0.2])
    grid on
end
end

function dx = OneDDrive(~,x,FIS,SystemParameters,ArenaParameters)
% x =
% [X,V,integral(u^2),integral(e^2),integra(cv^2),integral(abs(u)),integral(abs(e)),integral(abs(cv))]
pos = x(1);
GoalPoint = SystemParameters(4);
if abs(GoalPoint-pos)<1e-2% && abs(GoalSpeed-v)<1e-2
    dx = zeros(size(x));
else
    dpos = 0.1;
    v = x(2);
    m = SystemParameters(1);
    Fmax = SystemParameters(2); % Max Force
    vmax = SystemParameters(3); % Max speed
    
    % GoalSpeed = SystemParameters(5);
    InitialPosition = SystemParameters(6);
    % InitialSpeed = SystemParameters(7);
    v = min([v,vmax]);
    v = max([-vmax,v]);

    [c,Vr] = ObstFunc(pos,ArenaParameters);
    [c2,~] = ObstFunc(pos+dpos,ArenaParameters);
    % observ
    e = (GoalPoint-pos)/(GoalPoint-InitialPosition);
    e = max(e,-1);
    e = min(e,1);
    edot = (v)/vmax;
    inputFis = [e,edot,-1+2*(c+c2)/2];
    Fisout = evalfis(FIS,inputFis);
    F = Fisout*Fmax;


    dx(3) = 1;
    dx(1) = v;
    dx(2) = -c/m*v + F/m;
    dx(4) = (e)^2;
    dx(5) = (c*v)^2;
    dx(6) = abs(e);
    dx(7) = F/Fmax;
    dx(8) = abs(c*v);
    dx(9) = Vr*vmax < v;
    dx = dx';
end



end