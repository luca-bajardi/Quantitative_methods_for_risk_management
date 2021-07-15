function samples = samplingBetaFromData(plotHist,fileName,seed)
format long
if nargin == 0
    plotHist = false;
    fileName = 'EUR_USD Dati Storici.csv';
    seed = 'default';
elseif nargin == 1
    fileName = 'EUR_USD Dati Storici.csv';
    seed = 'default';
elseif nargin == 2
    seed = 'default';
else
    error('Too many input arguments.');
end
historical_data_table = readtable(fileName,'PreserveVariableNames',true).Ultimo;
historical_data = str2double(strrep(string(historical_data_table),',','.'));

minValue = min(historical_data);
maxValue = max(historical_data);
hd_norm = (historical_data-minValue) / (maxValue-minValue);
muHD = mean(hd_norm);
varHD = var(hd_norm);

alpha = ((1 - muHD) / varHD - 1 / muHD) * muHD ^ 2;
beta = alpha * (1 / muHD - 1);

rng(seed) % For reproducibility
samples = betarnd(alpha,beta,200)*(maxValue-minValue)+minValue;
if plotHist
    hold on
    histogram(historical_data,10,'Normalization','probability')
    histogram(samples,10,'Normalization','probability')
end