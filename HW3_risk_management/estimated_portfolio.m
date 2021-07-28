function [wealth, w] = estimated_portfolio(numRepl, trueMu, trueSigma, lambda, ...
                                           num_days, type, plotWealth, numPastDays, ...
                                           num_days_update, muVariation)

options = optimoptions('quadprog','Display','none');
w = zeros(numRepl,length(trueMu));
wealth = zeros(numRepl,num_days+1);
wealth(:,1) = 1000;

if ~exist('muVariation','var')
    muVariation = zeros(length(trueMu),1);
end

for i=1:numRepl
    
    switch type
        case 'optimal'
            w(i,:) = QuadFolio(trueMu, trueSigma, lambda);
        case 'optimalNoShort'
            w(i,:) = quadprog(lambda*trueSigma,-trueMu,-eye(length(trueMu)), ...
                              zeros(length(trueMu),1),ones(1,length(trueMu)), ...
                              1,[],[],[],options);
        case 'estimated'
            returnsObs = mvnrnd(trueMu+muVariation,trueSigma,numPastDays);
            hatMu = mean(returnsObs);
            hatSigma = cov(returnsObs);
            w(i,:) = QuadFolio(hatMu, hatSigma, lambda);
        case 'estimatedNoShort'
            returnsObs = mvnrnd(trueMu+muVariation,trueSigma,numPastDays);
            hatMu = mean(returnsObs);
            hatSigma = cov(returnsObs);
            w(i,:) = quadprog(lambda*hatSigma,-hatMu,-eye(length(hatMu)), ...
                              zeros(length(hatMu),1),ones(1,length(hatMu)), ...
                              1,[],[],[],options);
        case 'minvariance'
            returnsObs = mvnrnd(trueMu+muVariation,trueSigma,numPastDays);
            hatSigma = cov(returnsObs);
            w(i,:) = quadprog(lambda*hatSigma,[],[],[],ones(1,size(hatSigma,1)), ...
                              1,[],[],[],options);
        case 'naive'
            w(i,:) = 1/length(trueMu)*ones(length(trueMu), 1);
        otherwise
            error('Error of the type')
    end
    
    for day=1:num_days
        returnDay = mvnrnd(trueMu,trueSigma);
        wealth(i,day+1) = wealth(i,day)*(1 + dot(w(i,:),returnDay));
        
        %se si aggiornano i pesi dopo num_days_update giorni
        if exist('num_days_update','var') && num_days_update > 0 && ...
            (strcmp(type,'estimated') || strcmp(type,'estimatedNoShort') ...
                || strcmp(type,'minvariance'))
            returnsObs(end+1,:) = returnDay;
            if mod(day+1,num_days_update) == 0 && day ~= 1
                hatMu = mean(returnsObs)+muVariation';
                hatSigma = cov(returnsObs);
                switch type
                    case 'estimated'
                        w(i,:) = QuadFolio(hatMu, hatSigma, lambda);
                    case 'estimatedNoShort'
                        w(i,:) = quadprog(lambda*hatSigma,-hatMu,-eye(length(hatMu)), ...
                                          zeros(length(hatMu),1),ones(1,length(hatMu)), ...
                                          1,[],[],[],options);
                    case 'minvariance'
                        w(i,:) = quadprog(lambda*hatSigma,[],[],[],ones(1,size(hatSigma,1)), ...
                                          1,[],[],[],options);
                end
            end
        end
    end
    
    if plotWealth
        %figure
        switch type
            case 'optimal'
                myTitle = "Optimal Portfolio";
            case 'optimalNoShort'
                myTitle = "Optimal Portfolio with no short selling";
            case 'estimated'
                myTitle = "Estimated Portfolio";
            case 'estimatedNoShort'
                myTitle = "Estimated Portfolio with no short selling";
            case 'minvariance'
                myTitle = "MinVariance Portfolio";
            case 'naive'
                myTitle = "Naive Portfolio";
            otherwise
                error('Error of the type')
        end
        plot(0:num_days,wealth(i,:))
        ylim([0 3000]);
        yline(wealth(i,1),'r','LineWidth',1);
        title(myTitle);
    end
end
end