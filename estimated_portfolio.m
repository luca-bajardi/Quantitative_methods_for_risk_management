function w = estimated_portfolio(numRepl,numSample, trueMu, trueSigma, lambda)

rng('default'); % ripetibilità
c=length(trueMu);
w = zeros(numRepl, c);
%w1=zeros(numRepl,1);
% matrice per i pesi di ciascun asset nel portafoglio ottimo stimato
    for k=1:numRepl
        retScenarios = mvnrnd(trueMu,trueSigma,numSample); %estrae vettori casuali dalla distribuzione normale
        hatMu = mean(retScenarios);
        hatSigma = cov(retScenarios);
        wp = QuadFolio(hatMu, hatSigma, lambda);

        for i=1:c
            w(k, i) = wp(i);
        end
    end
end


