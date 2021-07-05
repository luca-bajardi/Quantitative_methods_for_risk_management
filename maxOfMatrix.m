function [] = maxOfMatrix(matrix, perc_cover, perc_forward)
% trova qual è l'elemento massimo della matrice e indica quali sono i
% corrispondenti valori percentuali di forward e di copertura
[M,id] = max(matrix,[],'all','linear');
numR = length(perc_cover);
idC = ceil(id/numR);
idR = id-numR*(idC-1);
fprintf("max:\t\t\t" + M + "\n")
fprintf("perc_cover:\t\t" + perc_cover(idR) + "\n");
fprintf("perc_forward:\t" + perc_forward(idC) + "\n");