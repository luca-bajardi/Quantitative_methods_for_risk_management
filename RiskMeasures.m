function [sigma_squared, sigma, VaR, CVaR] = RiskMeasures(probabilities, impact, normal)
%RISKMEASURE Summary of this function goes here
%   Detailed explanation goes here
s=size(impact);
volume=s(1);
perc_cover=s(2);
perc_forward=s(4);

sigma_squared = zeros(volume,perc_cover, perc_forward);
sigma = zeros(volume,perc_cover, perc_forward);
VaR = zeros(volume,perc_cover, perc_forward);
CVaR = zeros(volume,perc_cover, perc_forward);

for i = 1:volume
    for j = 1:perc_cover
              for w = 1:perc_forward %per ogni strategia
                  scenari=impact(i, j, :, w);
                  media_campionaria=1/length(scenari)*sum(scenari);
                  varianza_campionaria=1/(length(scenari)-1)*sum((scenari).^2-media_campionaria^2);
                  
                  if normal=='false'
                  %suppongo che la distribuzione sia Beta
                  %alpha = ((1 - media_campionaria) / varianza_campionaria - 1 / media_campionaria) * media_campionaria ^ 2;
                  %beta = alpha * (1 / media_campionaria - 1)-1+media_campionaria;
                  %sigma_squared(i, j, w)= alpha*beta/((alpha+beta+1)*(alpha+beta)^2);
                  %sigma(i, j, w)=sqrt(sigma_squared(i, j, w));
                  %VaR(i, j, w)=betainv(probabilities, alpha,beta);
                  %CVaR(i, j, w)= 1/(1-probabilities)*betacdf(VaR(i, j, w),alpha,beta);
                  else
                  %suppongo che la distribuzione sia Normale
                  sigma_squared(i, j, w)= varianza_campionaria;
                  sigma(i, j, w)=sqrt(sigma_squared(i, j, w));
                  VaR(i, j, w)=norminv(probabilities,media_campionaria,sigma(i, j, w));
                  CVaR(i, j, w)= media_campionaria+sigma(i, j, w)/(1-probabilities)*normcdf(VaR(i, j, w),media_campionaria,sigma(i, j, w));
                  end
                  
              end
         
    end
end



end

