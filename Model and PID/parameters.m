clc;
clear;
ms = 240;
mus = 36;
ks = 16000;
kus = 160000;
cs = 980;
cus = 400;
A = [0 1 0 -1;
    -ks/ms -cs/ms 0 cs/ms;
    0 0 0 1;
    ks/mus cs/mus -kus/mus -(cs+cus)/mus
    ];
B = [0; 1/ms; 0; -1/mus];
B1 = [0; 0; -1; cus/mus];
C = [1 0 0 0;
    -ks/ms -cs/ms 0 cs/ms];
D = [0; 1/ms];
Gp = tf([ms+mus cus kus],[ms*mus cs*ms+cs*mus+cus*ms cs*cus+ks*ms+ks*mus+kus*ms cs*kus+cus*ks ks*kus])
Q = [10000 0 0 0;
    0 500 0 0;
    0 0 50 0;
    0 0 0 0.1];
R = 0.1;
K = lqr(A,B,Q,R)