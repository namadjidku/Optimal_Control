clear
clc

fitnessfcn = @GENA_LQR2;    
nvars=4;                  
LB = [0.1 0.1 0.1 0.1];    
UB = [1e6 1e6 1e6 1e6];      
options=gaoptimset('PopulationSize',100,'PopInitRange',[LB;UB],'EliteCount',10,'CrossoverFraction',0.4,'Generations',20,'StallGenLimit',20,'TolFun',1e-100,'PlotFcns',{@gaplotbestf,@gaplotbestindiv});
[x_best,fval]=ga(fitnessfcn,nvars, [],[],[],[],LB,UB,[],options); 