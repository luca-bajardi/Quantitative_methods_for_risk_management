function [minMatrix,sigma_squared, sigma, VaR, CVaR] = RiskMeasures(probabilities, impact, type)
%RISKMEASURE Summary of this function goes here
%   Detailed explanation goes here

s=size(impact);
num_perc_cover=s(2);
num_perc_forward=s(4);
num_prob=length(probabilities);

sigma_squared = zeros(num_perc_cover, num_perc_forward);
sigma = zeros(num_perc_cover, num_perc_forward);
VaR = zeros(num_prob,num_perc_cover, num_perc_forward);
%scen = zeros(num_perc_cover, num_perc_forward);
%err_VaR = zeros(num_perc_cover, num_perc_forward);
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
        %     Parametric Beta
        %===========================
        if strcmp(type,'Parametric Beta')
            minValue = min(scenari,[],'All');
            maxValue = max(scenari,[],'All');
            scenari_norm = (scenari-minValue) / (maxValue-minValue);
            muC=1/numel(scenari_norm)*sum(scenari_norm,'All');
            varC=1/(numel(scenari_norm)-1)*sum((scenari_norm).^2-muC^2,'All');
            alpha = ((1 - muC) / varC - 1 / muC) * muC ^ 2;
            beta = alpha * (1 / muC - 1)-1+muC;
            %sigma_squared(i, j)= alpha*beta/((alpha+beta+1)*(alpha+beta)^2);
            sigma_squared(i,j)=1/(numel(scenari)-1)*sum((scenari).^2-muC^2,'All');
            sigma(i,j)=sqrt(sigma_squared(i,j));
            for prob=1:length(probabilities)
                VaR(prob,i,j)=betainv(1-probabilities(prob), alpha,beta)*(maxValue-minValue)+minValue;
                CVaR(prob,i,j)= 1/(1-probabilities(prob))*betacdf(VaR(prob,i,j),alpha,beta); %non l'ho capito
            end
        end
        
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
            %VaR(i,j) = prctile(scenari,100-probability*100,'all');
            %err_VaR(i,j) = min(abs(squeeze(impact(:,i,:,j))-VaR(i,j)),[],'All');
            
        end
    end
end
end

