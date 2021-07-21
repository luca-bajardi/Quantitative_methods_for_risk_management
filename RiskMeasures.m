function [sigma_squared, sigma, VaR, CVaR] = RiskMeasures(probability, impact, type)
%RISKMEASURE Summary of this function goes here
%   Detailed explanation goes here
% s=size(impact);
% volume=s(1);
% perc_cover=s(2);
% perc_forward=s(4);
% 
% sigma_squared = zeros(volume,perc_cover, perc_forward);
% sigma = zeros(volume,perc_cover, perc_forward);
% VaR = zeros(volume,perc_cover, perc_forward);
% CVaR = zeros(volume,perc_cover, perc_forward);
% 
% for i = 1:volume
%     for j = 1:perc_cover
%               for w = 1:perc_forward %per ogni strategia
%                   scenari=impact(i, j, :, w);
%                   media_campionaria=1/length(scenari)*sum(scenari);
%                   varianza_campionaria=1/(length(scenari)-1)*sum((scenari).^2-media_campionaria^2);
%                   
%                   if normal=='false'
%                   %suppongo che la distribuzione sia Beta
%                   %alpha = ((1 - media_campionaria) / varianza_campionaria - 1 / media_campionaria) * media_campionaria ^ 2;
%                   %beta = alpha * (1 / media_campionaria - 1)-1+media_campionaria;
%                   %sigma_squared(i, j, w)= alpha*beta/((alpha+beta+1)*(alpha+beta)^2);
%                   %sigma(i, j, w)=sqrt(sigma_squared(i, j, w));
%                   %VaR(i, j, w)=betainv(probabilities, alpha,beta);
%                   %CVaR(i, j, w)= 1/(1-probabilities)*betacdf(VaR(i, j, w),alpha,beta);
%                   else
%                   %suppongo che la distribuzione sia Normale
%                   sigma_squared(i, j, w)= varianza_campionaria;
%                   sigma(i, j, w)=sqrt(sigma_squared(i, j, w));
%                   VaR(i, j, w)=norminv(probabilities,media_campionaria,sigma(i, j, w));
%                   CVaR(i, j, w)= media_campionaria+sigma(i, j, w)/(1-probabilities)*normcdf(VaR(i, j, w),media_campionaria,sigma(i, j, w));
%                   end
%                   
%               end
%          
%     end
% end

s=size(impact);
num_perc_cover=s(2);
num_perc_forward=s(4);

sigma_squared = zeros(num_perc_cover, num_perc_forward);
sigma = zeros(num_perc_cover, num_perc_forward);
VaR = zeros(num_perc_cover, num_perc_forward);
%scen = zeros(num_perc_cover, num_perc_forward);
%err_VaR = zeros(num_perc_cover, num_perc_forward);
CVaR = zeros(num_perc_cover, num_perc_forward);

for i = 1:num_perc_cover
    for j = 1:num_perc_forward %per ogni strategia
        scenari=squeeze(impact(:, i, :, j));
        
        
        %===============================
        %     Parametric Beta VaR
        %===============================
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
            VaR(i,j)=betainv(1-probability, alpha,beta)*(maxValue-minValue)+minValue;
            CVaR(i,j)= 1/(1-probability)*betacdf(VaR(i,j),alpha,beta); %non l'ho capito
        end
        
        %===============================
        %     Parametric Normal VaR
        %===============================
        if strcmp(type,'Parametric Normal')
            muC=1/numel(scenari)*sum(scenari,'All');
            varC=1/(numel(scenari)-1)*sum((scenari).^2-muC^2,'All');
            sigma_squared(i,j)= varC;
            sigma(i,j)=sqrt(sigma_squared(i,j));
            VaR(i,j)=norminv(1-probability,muC,sigma(i,j));
            CVaR(i,j)= muC+sigma(i,j)/(1-probability)*normcdf(VaR(i,j),muC,sigma(i,j)); %non l'ho capito
        end
        
        
        %============================
        %    Historical Simulation
        %============================
        if strcmp(type,'Historical Simulation')
            muC=1/numel(scenari)*sum(scenari,'All');
            varC=1/(numel(scenari)-1)*sum((scenari).^2-muC^2,'All');
            sigma_squared(i,j)= varC;
            sigma(i,j)=sqrt(sigma_squared(i,j));
            id=floor(numel(scenari)*(1-probability));
            scenari_sort = sort(reshape(scenari,1,[]));
            VaR(i,j) = scenari_sort(id);
            CVaR(i,j) = mean(scenari_sort(1:id));
            %VaR(i,j) = prctile(scenari,100-probability*100,'all');
            %err_VaR(i,j) = min(abs(squeeze(impact(:,i,:,j))-VaR(i,j)),[],'All');
            
        end
    end
end
end

