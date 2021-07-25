function [newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation,phi)

hedge(2:2+hedge(1)-1)=phi;

[priceBondOriginal, D0bond, D1bond, D2bond]=fixed_duration(t_0, bond, r, tau, betaValues);
[priceBondNew, D0bond, D1bond, D2bond]=fixed_duration(t_0, bond, r, tau, betaValues+betaVariation);

[priceZeroOriginal, D0zero, D1zero, D2zero]=fixed_duration(t_0, hedge, r, tau, betaValues);
[priceZero, D0zero, D1zero, D2zero]=fixed_duration(t_0, hedge, r, tau, betaValues+betaVariation);

newValuePosition = priceBondNew + (priceZero - priceZeroOriginal);