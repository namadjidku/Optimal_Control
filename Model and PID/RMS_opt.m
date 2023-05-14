function q=RMS_opt(X)
global q_opt %q_opt2
kp = X(1);
ki = X(2);
kd = X(3);


if (kp<0) || (ki<0) || (kd<0)
    q=1000;
    return;
end

% if (q_opt>4.82e-5) 
%     q=1000;
%     return;
% end
% 
% if (q_opt2>1.9) 
%     q=1000;
%     return;
% end

set_param('Quarter_Vehical_model_pid_opt/PID controller/kp','Gain',num2str(kp));
set_param('Quarter_Vehical_model_pid_opt/PID controller/ki','Gain',num2str(ki));
set_param('Quarter_Vehical_model_pid_opt/PID controller/kd','Gain',num2str(kd));
sim Quarter_Vehical_model_pid_opt;

q_opt = RMS1;

%q_opt2 = RMS2;
q=q_opt;