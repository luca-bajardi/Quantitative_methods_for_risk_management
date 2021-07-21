function [p_swap,Dd_swap] = swap_duration(fixed, t_0,portfolio,termStructure, last_rate)

%Argomenti in input: 
%fixed=variabile booleana per stabilire il punto di vista fixed/floater
%t_0=istante di tempo in cui voglio calcolare il valore del portafoglio coperto
%portfolio=[NDifferentBond, NBond, T, faceValue, swapRate, NPayments]
%termStructure=quella che conosco oggi
%last_rate= per calcolare il prossimo pagamento del floater


[p_fixed, ~, Dd_fixed]=price_duration(t_0, portfolio, termStructure);
[p_float, ~, Dd_float]=price_duration(t_0,portfolio, termStructure, last_rate);

if fixed==true                          %dal punto di chi paga fisso
    p_swap=p_float-p_fixed;
    Dd_swap=Dd_float-Dd_fixed;
else
    p_swap=p_fixed-p_float;
    Dd_swap=Dd_fixed-Dd_float;
end