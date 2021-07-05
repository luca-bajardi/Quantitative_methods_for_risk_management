%hedging_policies(perc_cover, perc_forward, change, volume)
clc
clear all
close all
format bank
perc_cover = [0,0.25,0.5,0.75,1];
%perc_cover = [0:0.001:1];
perc_forward = [0,0.25,0.5,0.75,1];
%perc_forward = [0:0.001:1];
change = [1.01,1.22,1.48];
volume = [10000,25000,30000];
K = 1.22;

%la politica è stabile su 25000 studenti
volume_policy = 25000;

impact = hedging_policies(perc_cover, perc_forward, change, volume, volume_policy, K);

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