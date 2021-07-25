clc
clear all
close all
perc_cover = [0,0.25,0.5,0.75,1];
%perc_cover = [0:0.001:1];
perc_forward = [0,0.25,0.5,0.75,1];
%perc_forward = [0:0.001:1];
change = [1.01,1.22,1.48];
volume = [10000,25000,30000];
K = 1.22;

%la politica � stabile su 25000 studenti
volume_policy = 25000;

samplesChange = samplingBetaFromData(false);
samplesVolume = samplingBetaFromParameter(7,4.5,0,40000,false,volume);


format bank
%impact = hedging_policies(perc_cover, perc_forward, change, volume, volume_policy, K);
impact = hedging_policies(perc_cover, perc_forward, samplesChange, samplesVolume, volume_policy, K);

%
%%OTTIMIZZAZIONE ROBUSTA
% trovo il minimo lungo la dimensione del volume (dim 1) e lungo quella del
% change (dim 3) e poi sistemo la matrice per eliminare le dimensioni di 
% lunghezza 1
minMatrix = squeeze(min(min(impact,[],1),[],3));

print_table = true;
if print_table
    disp(array2table(minMatrix,...
                      'VariableNames',cellstr(num2str(perc_forward')),...
                      'RowNames',cellstr(num2str(perc_cover'))));
end

maxOfMatrix(minMatrix, perc_cover, perc_forward)


probabilities = [0.9 0.95 0.99];
disp('Historical Simulation')
[varianza, deviazione_standard, VaR, CVar]=RiskMeasures(probabilities, impact, 'Historical Simulation')
squeeze(VaR(3,:,:))
disp('Parametric Beta')
[varianza, deviazione_standard, VaR, CVar]=RiskMeasures(probabilities, impact, 'Parametric Beta')
disp('Parametric Normal')
[varianza, deviazione_standard, VaR, CVar]=RiskMeasures(probabilities, impact, 'Parametric Normal')