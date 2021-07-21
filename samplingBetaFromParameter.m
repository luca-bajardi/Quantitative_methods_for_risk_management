function samples = samplingBetaFromParameter(alpha,beta,minValue,maxValue,...
                        plotDensity,importantValues,seed)
format long
if nargin<4
    error('Not enough input arguments.');
elseif nargin == 4
    plotDensity=false;
    importantValues=[];
    seed = 'default';
elseif nargin == 5
    importantValues=[];
    seed = 'default';
elseif nargin == 6
    seed = 'default';
elseif nargin>7
    error('Too many input arguments.');
end

rng(seed) % For reproducibility
samples = betarnd(alpha,beta,[200,1])*(maxValue-minValue)+minValue;

if plotDensity
    X = 0:.01:1;
    y = betapdf(X,alpha,beta);
    importantValues_pdf = betapdf((importantValues-minValue)/(maxValue-minValue),alpha,beta);
    figure
    hold on
    plot(X*(maxValue-minValue)+minValue,y,'LineStyle','-','Color','r','LineWidth',2);
    plot(importantValues,importantValues_pdf,'o','MarkerFaceColor','blue','MarkerEdgeColor','blue');
    hold off
end
end