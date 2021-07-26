function [wealth] = estimated_portfolio(trueMu, trueSigma, lambda, num_days, type)

numPastDays = 250;
options = optimoptions('quadprog','Display','none');


returnsObs = mvnrnd(trueMu,trueSigma,numPastDays);
hatMu = mean(returnsObs);
hatSigma = cov(returnsObs);

figure

switch type
    case 'optimal'
        w = QuadFolio(trueMu, trueSigma, lambda);
        myTitle = "Optimal Portfolio";
    case 'optimalNoShort'
        w = quadprog(lambda*trueSigma,-trueMu,-eye(length(trueMu)),zeros(length(trueMu),1),ones(1,length(trueMu)),1,[],[],[],options);
        myTitle = "Optimal Portfolio with no short selling";
    case 'estimated'
        w = QuadFolio(hatMu, hatSigma, lambda);
        myTitle = "Estimated Portfolio";
    case 'estimatedNoShort'
        w = quadprog(lambda*hatSigma,-hatMu,-eye(length(hatMu)),zeros(length(hatMu),1),ones(1,length(hatMu)),1,[],[],[],options);
        myTitle = "Estimated Portfolio with no short selling";
    case 'minvariance'
        w = quadprog(lambda*trueSigma,[],[],[],ones(1,size(trueSigma,1)),1,[],[],[],options);
        myTitle = "MinVariance Portfolio";
    case 'naive'
        w = 1/length(trueMu)*ones(length(trueMu), 1);
        myTitle = "Naive Portfolio";
    otherwise
        error('Error of the type')
end
wealth = zeros(num_days+1,1);
wealth(1) = 1000;
for day=1:num_days
    returnDay = mvnrnd(trueMu,trueSigma);
    wealth(day+1) = wealth(day)*(1 + dot(w,returnDay));
end
plot(0:num_days,wealth)
title(myTitle)
end