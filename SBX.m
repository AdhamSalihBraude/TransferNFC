function [offspring1, offspring2] = SBX(parent1,parent2,CrossOverRate,ul)
yl = ul(1);
yu = ul(2);
Nl = length(parent1);
mu = 15;
offspring1 = parent1;
offspring2 = parent2;
if rand(1) <= CrossOverRate
    for j =  1:Nl
        par1 = parent1(j);
        par2 = parent2(j);
        rnd = rand(1);
        if rnd <= 0.5
            if abs(par1 - par2) > 0.000001
                if par2 > par1
                    y2 = par2;
                    y1 = par1;
                else
                    y2 = par1;
                    y1 = par2;
                end
                if (y1 - yl) > (yu - y2)
                    beta = 1 + (2*(yu - y2)/(y2 - y1));
                else
                    beta = 1 + (2*(y1 - yl)/(y2 - y1));
                end
                expp = mu + 1;
                beta = 1/beta;
                alpha = 2 - beta^expp;
                rnd = rand(1);
                if rnd <= 1/alpha
                    alpha = alpha*rnd;
                    expp = 1/(mu + 1);
                    betaq = alpha^expp;
                else
                    alpha = alpha*rnd;
                    alpha = 1/(2 - alpha);
                    expp = 1/(mu + 1);
                    betaq = alpha^expp;

                end
                child1 = 0.5*((y1 + y2) - betaq*(y2 - y1));
                child2 = 0.5*((y1 + y2) + betaq*(y2 - y1));
            else
                betaq = 1;
                y1 = par1;
                y2 = par2;
                child1 = 0.5*((y1 + y2) - betaq*(y2 - y1));
                child2 = 0.5*((y1 + y2) + betaq*(y2 - y1));
            end
            if child1 < yl
                child1 = yl;
            end
            if child2 < yl
                child2 = yl;
            end
            if child1 > yu
                child1 = yu;
            end
            if child2 > yu
                child2 = yu;
            end
        else
            child1 = par1;
            child2 = par2;
        end
        if ~isreal(child1) || ~isreal(child2)
            disp('error in ga rep sbx');
            if ~isreal(child1)
                child1 = rand(1)*(yu - yl) + yl;
            end
            if ~isreal(child2)
                child2 = rand(1)*(yu - yl) + yl;
            end
        end
        offspring1(j) = child1;
        offspring2(j) = child2;
    end
else

end