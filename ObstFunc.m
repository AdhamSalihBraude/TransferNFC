function [c,Vratio] = ObstFunc(x,ArenaParameters)
if size(x,1) ~=1
    x=x';
end
NumberOfObs = length(ArenaParameters);
c = zeros(NumberOfObs,length(x));
Vratio = ones(NumberOfObs,length(x));
for i = 1 : NumberOfObs
    c(i,:) = c(i,:) + normpdf(x,ArenaParameters(i).mu,ArenaParameters(i).sigma);
Vratio(i,:) = (1-c(i,:))*ArenaParameters(i).ValRatio;
end
Vratio = min(Vratio,[] ,1);
c = max(c,[],1);
c(c>0.8) = 0.8;
Vratio(c<0.1) = 1;
Vratio(Vratio<0.7) = 0.7;
Vratio(Vratio>1) = 1;