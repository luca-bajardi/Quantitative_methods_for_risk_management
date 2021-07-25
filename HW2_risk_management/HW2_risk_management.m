clear all
close all
clc
format bank

termStructure=[0.03, 0.03, 0.03];  %%attuale
t_0=0;
portfolio=[1, 1, 18, 10000, 0.05, 2]; %Porfolio da immunizzare
%quanti bond nel portafoglio
%quanti bond di quel tipo
%maturità in mesi
%face value
%cedola annuale
%numero capitalizzazioni in un anno

%DURATION MATCHING

%supponiamo di fare hedging con una posizione corta in uno zero
H1=[6, 10000, 0, 2];
H2=[12, 10000, 0, 2];
N1=1;
N2=1;
%hedge_instrument=[N1, N2, H1, H2]
hedge_instrument=[1, 1, H1];



%SHIFT PARALLELO
var=termStructure+0.01;
L=firstOrderImmunization(t_0, portfolio,hedge_instrument, termStructure, var);


%SHIFT NON PARALLELO
var2=[0.038, 0.04, 0.042];
L2=firstOrderImmunization(t_0, portfolio,hedge_instrument, termStructure, var2);


