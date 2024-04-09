function [value, isterminal, direction] = myEvent(t, x)

value      = abs(x(1))<0.02; %~(abs(x(1))<0.01 && abs(x(2))<0.01);
isterminal = 1;% && abs(x(1)) < 0.1;   % Stop the integration  
direction  = 0;
end