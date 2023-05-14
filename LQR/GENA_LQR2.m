function f=GENA_LQR2(x)

ms = 240;
mus = 36;
ks = 16000;
kus = 160000;
cs = 980;
cus = 400;

% the State space model is:
A = [0, 1, 0, -1;
     -ks/ms, -cs/ms, 0, cs/ms;
     0, 0, 0, 1;
     ks/mus, cs/mus, -kus/mus, -(cs+cus)/mus];

B = [0; 1/ms; 0; -1/mus]; %for adaptive suspension Fa

B1= [0;0;-1;cus/mus];

C = [1 0 0 0;
    -ks/ms -cs/ms 0 cs/ms];
%D = [0 0; 0 1/ms];
D = [0; 1/ms];

%for classic suspension Fa = 0 so that matrix B can be eliminated
% The transfer function model is:
%[NUM, DEN] = ss2tf(A,B1,C,D)


%Active Suspension Fa design -- LQR method

%System model with Fa = -Kx, full state feedback
%as_sys= ss(A,B,eye(4),0);

%Evaluation matrix
%p1 = 40; p2=100; p3=40; p4=16; %Weight
Q = [(ks/ms)^2+x(1), cs*ks/(ms^2), 0, -(cs*ks/ms/ms);
     (cs*ks/ms/ms), (cs/ms)^2+x(2), 0, -((cs/ms)^2);
     0, 0, x(3), 0;
     -(cs*ks/ms/ms), -((cs/ms)^2), 0, (cs/ms)^2+x(4)]

R = 1/ms/ms;
N = [-ks; -cs; 0; cs]/(ms^2);

%Solve the LQR Problem. Please use help lqr for more details 
%[K,S,E] = lqr(A,B,Q, R, N)
K = lqr(A,B,Q, R, N);


%%%%%%%%%%%% run the Simulink model %%%%%%%%%%%%
assignin('base','A',A);
assignin('base','B',B);
assignin('base','B1',B1);
assignin('base','C',C);
assignin('base','D',D);
assignin('base','K',K);

[t_time,x_state,y1,y2,y3,y4]=sim('Quarter_LQRGENA_wh2',[1,3]);

%%%%%%%%%%%%% the Fitness Value %%%%%%%%%%%


%passive
SWS_pas=sqrt(sum(y3.*y3)/size(y3,1));
BA_pas=sqrt(sum(y4.*y4)/size(y4,1));


%active
SWS_RMS=sqrt(sum(y1.*y1)/size(y1,1));
BA_RMS=sqrt(sum(y2.*y2)/size(y2,1));




if (BA_RMS>BA_pas)|(SWS_RMS>(SWS_pas))
    f=BA_RMS/BA_pas+SWS_RMS/SWS_pas+10;
else
    f=BA_RMS/BA_pas+SWS_RMS/SWS_pas;
end

