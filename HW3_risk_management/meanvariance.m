function w = meanvariance(numRepl,numSample, trueMu, trueSigma, lambda, options)
rng('default'); % ripetibilità
c=length(trueMu);
w = zeros(numRepl, c);
%w1=zeros(numRepl,1);
% matrice per i pesi di ciascun asset nel portafoglio ottimo stimato
    for k=1:numRepl
        retScenarios = mvnrnd(trueMu,trueSigma,numSample); %estrae vettori casuali dalla distribuzione normale
        %hatMu = mean(retScenarios);
        hatSigma = cov(retScenarios);
        wp = quadprog(lambda*hatSigma,[],[],[],ones(1,2),1,[],[],[],options);

        for i=1:c
            w(k, i) = wp(i);
        end
    end
end



