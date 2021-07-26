clear all
close all
clc
%Sto usando questo tipo di modello (assumo una distribuzione di probabilit�),
%ma non vado a beccare i parametri giusti
%quindi si introduce del rumore nel portafoglio. Vediamo cosa comporta in termini
%di rendimento



% Symbol	Company Name
% AAPL	Apple, Inc.
% SBUX	Starbucks, Inc.
% MSFT	Microsoft, Inc.
% CSCO	Cisco Systems, Inc.
% QCOM	QUALCOMM Incorporated
% Facebook, Inc.	Facebook, Inc.
% AMZN	Amazon.com, Inc.
% TSLA	Tesla, Inc.
% AMD	Advanced Micro Devices, Inc.
% ZNGA	Zynga Inc.

list_stock= ["AAPL","SBUX","MSFT","CSCO","QCOM","FB","AMZN","TSLA","AMD","ZNGA"];
num_asset = length(list_stock);

% T = readtable(strcat('stock/',list_stock(3),".csv"),'PreserveVariableNames',0);
% values = str2double(strrep(string(T.Close_Last),'$',''));
% date = datetime(T.Date);
% var = (values(2:end)-values(1:end-1))./values(1:end-1);
% figure
% plot(date(2:end),var)

%per eliminare warning nella creazione delle table
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

figure
returns = zeros(num_asset,1257);
for i = 1:length(list_stock)
    T = readtable(strcat('stock/',list_stock(i),".csv"));
    date = flip(datetime(T.Date));
    date(1) = [];
    values = flip(str2double(strrep(string(T.Close_Last),'$','')));
    returns(i,:) = (values(2:end)-values(1:end-1))./values(1:end-1);
    hold on
    plot(date,returns(i,:))
end
title('Asset returns');
legend(list_stock);

startDate = date(300)
finishDate = date(803)
date = date(300:803);
returns = returns(:,300:803);
figure
for i = 1:num_asset
    hold on
    plot(date,returns(i,:))
end
title('Asset returns (small period)');
legend(list_stock);
hold off

trueMu = mean(returns,2)
trueSigma = cov(returns')

% %Consideriamo una distribuzione normale multivariata
% trueMu = [0.07; 0.05];
% trueVols = [0.20; 0.15]; % deviazione standard del rendimento
% trueRho = 0.7;
% % trucco per ottenere matrice di covarianza da matrice correlazione
% trueSigma = [1 trueRho; trueRho 1].*(trueVols * trueVols');
lambda = 3;
%Non impongo vincoli sulla vendita allo scoperto
[truewp,mup,sigmap] = QuadFolio(trueMu, trueSigma, lambda);
truew1 = truewp(1);

%in alternativa posso usare la funzione gi� implementata in matlab che per�
%non sfrutta la soluzione in forma chiusa

options = optimoptions('quadprog','Display','none');
x = quadprog(lambda*trueSigma,-trueMu,[],[],ones(1,num_asset),1,[],[],[],options);

%check stesso risultato
max(abs(truewp-x))<1.0e-4

% %errori di stima sui valori attesi
% err_absMu=max(abs(mup-trueMu));
% err_relMu=max(abs(mup-trueMu))/trueMu;
% 
% %errori di stima sulla matrice di cov
% err_abs_S=max(abs(trueSigma-sigmap));
% err_rel_S=max(abs(trueSigma-sigmap))/trueSigma;

w=estimated_portfolio(1000, 300, trueMu, trueSigma, lambda);
figure
histogram(w(:,1),50); %peso del primo asset nel portafoglio
xline(truew1,'r','LineWidth',3); %valore ottimo vero
title('Peso del primo asset nel portafoglio');
%estrema variabilit� del peso nel portafoglio

%possiamo vederlo equivalentemente sul secondo asset perch� in questo caso
%sono solamente due
%histogram(w(:,2),50); 
%xline(1-truew1,'r','LineWidth',3);

%%

%EFFETTO DELLA DIMENSIONE DEI DATI SU CUI FITTO LA DISTRIBUZUIONE

%vediamo come migliora la soluzione quando aumentiamo il numero di
%campioni a disposizione
figure 
w1=estimated_portfolio(1000, 3000, trueMu, trueSigma, lambda);
histogram(w1(:, 1),50);
xline(truew1,'r','LineWidth',3);
title('Aumento la dimensione dei dati su cui fitto la distribuzione')
%la variabilit� si riduce di molto
%nella realt� non avremo mai a disposizione tutti questi dati

%%
%EFFETTO DELL'AVVERSIONE AL RISCHIO
 lambda2=2;
[truewp,mup,sigmap] = QuadFolio(trueMu, trueSigma, lambda2);
truew_lambda = truewp(1);
w_lambda=estimated_portfolio(1000, 300, trueMu, trueSigma, lambda2);
figure
histogram(w_lambda(:,1),50); %peso del primo asset nel portafoglio
xline(truew_lambda,'r','LineWidth',3); %valore ottimo vero
title('Effetto del coef. di avversione al rischio');

lambda3=4;
[truewp,mup,sigmap] = QuadFolio(trueMu, trueSigma, lambda3);
truew_lambda = truewp(1);
w_lambda=estimated_portfolio(1000, 300, trueMu, trueSigma, lambda3);
figure
histogram(w_lambda(:,1),50); %peso del primo asset nel portafoglio
xline(truew_lambda,'r','LineWidth',3); %valore ottimo vero
title('Effetto del coef. di avversione al rischio2');

%Valori accettabili del coefficiente di avversione al rischio sono quelli
%dell'intervallo [2, 4]. Sembra che all'aumentare di lambda la variabilit�
%viene ridotta. PERCHE?????

%%
%EFFETTO DEI VINCOLI SULLO SCOPERTO
%Andiamo ad imporre un ulteriore vincolo
%Non solo richiediamo che la somma di tutti i pesi deve essere uguale ad 1,
%ma anche che tutti i pesi devono essere positivi (no vendita allo
%scoperto)
options = optimoptions('quadprog','Display','none');
x_no_scoperto = quadprog(lambda*trueSigma,-trueMu,-eye(length(trueMu)),zeros(length(trueMu),1),ones(1,length(trueMu)),1,[],[],[],options);
wns=estimated_portfolio(1000, 3000, trueMu, trueSigma, lambda);
figure
histogram(wns(:, 1),50);
xline(x_no_scoperto(1),'r','LineWidth',3);
title('No vendita allo scoperto');


%%
%PORTAFOGLIO DI MINIMA VARIANZA
%Non tengo conto dei valori attesi e intuitivamente potrebbe sembrare una
%scelta azzardata, ma visto che sto commettendo degli errori di stima
%faccio entrare meno errori nel modello, quindi in alcune circostanze
%potrebbe essere utile capire cosa accade.
options = optimoptions('quadprog','Display','none');
xmv= quadprog(lambda*trueSigma,[],[],[],ones(1,num_asset),1,[],[],[],options);
truew_lambda = xmv(1);
%non so se serve farlo??
w_mv=meanvariance(1000, 300, trueMu, trueSigma, lambda, options);
figure
histogram(w_mv(:,1),50); %peso del primo asset nel portafoglio
xline(truew_lambda,'r','LineWidth',3); %valore ottimo vero
title('Portafoglio di minima varianza');


%BISOGNA confrontare il rendimento del portafoglio ottimo con quello di
%minima varianza su un orizzonte di tempo

%%
%PORTAFOGLIO NAIVE
%Stesso orizzonte di tempo di prima, confrontare il rendimento
w_naive=1/length(trueMu)*ones(length(trueMu), 1);

%%
%Hanno pi� impatto errori sui premi per il rischio o sulle
%covarianze/correlazioni?? errori sui premi per il rischio, PERCHE'????

%%
%Effetto di asimmetrie o code grasse (volendo potete cambiare distribuzione di probabilit� e
%valutare la variabilit� del portafoglio)
 %la normale � gi� una distribuzione abbastanza buona, ma si pu� trovare
 %qualcosa di meglio... COPULE