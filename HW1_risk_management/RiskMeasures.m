function [minMatrix,sigma_squared, sigma, VaR, CVaR] = RiskMeasures(probabilities, impact, type)

s=size(impact);
num_perc_cover=s(2);
num_perc_forward=s(4);
num_prob=length(probabilities);

sigma_squared = zeros(num_perc_cover, num_perc_forward);
sigma = zeros(num_perc_cover, num_perc_forward);
VaR = zeros(num_prob,num_perc_cover, num_perc_forward);
CVaR = zeros(num_prob,num_perc_cover, num_perc_forward);

%%OTTIMIZZAZIONE ROBUSTA
% trovo il minimo lungo la dimensione del volume (dim 1) e lungo quella del
% change (dim 3) e poi sistemo la matrice per eliminare le dimensioni di 
% lunghezza 1
minMatrix = squeeze(min(min(impact,[],1),[],3));
for i = 1:num_perc_cover
    for j = 1:num_perc_forward %per ogni strategia
        scenari=squeeze(impact(:, i, :, j));
        
        %===========================
        %     Parametric Normal
        %===========================
        if strcmp(type,'Parametric Normal')
            muC=1/numel(scenari)*sum(scenari,'All');
            varC=1/(numel(scenari)-1)*sum((scenari).^2-muC^2,'All');
            sigma_squared(i,j)= varC;
            sigma(i,j)=sqrt(sigma_squared(i,j));
            for prob=1:length(probabilities)
                VaR(prob,i,j)=norminv(1-probabilities(prob),muC,sigma(i,j));
                CVaR(prob,i,j)= muC+sigma(i,j)/(1-probabilities(prob))*normcdf(VaR(prob,i,j),muC,sigma(i,j)); %non l'ho capito
            end
        end
        
        %============================
        %    Historical Simulation
        %============================
        if strcmp(type,'Historical Simulation')
            muC=1/numel(scenari)*sum(scenari,'All');
            varC=1/(numel(scenari)-1)*sum((scenari).^2-muC^2,'All');
            sigma_squared(i,j)= varC;
            sigma(i,j)=sqrt(sigma_squared(i,j));
            for prob=1:length(probabilities)
                id=floor(numel(scenari)*(1-probabilities(prob)));
                scenari_sort = sort(reshape(scenari,1,[]));
                VaR(prob,i,j) = scenari_sort(id);
                CVaR(prob,i,j) = mean(scenari_sort(1:id));
            end
        end
    end
end
end

