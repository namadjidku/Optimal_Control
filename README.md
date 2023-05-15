# Optimal_Control

The project contains three folders dedicated to each technique. Please refer to the correspoding section for running instructions.

### PID 
The m file 'parameters' need to be run first to write parameters in simulink blocks before running the simulink model.
In the simulink model, the manual switches in the left-hand side are for selection of road disturbances. The manual switch in the right-hand 
side is for the switching between the passive suspension system and active suspension system. When the switch is on the constant '0', the system
is operating as a passive suspension system.
The m file 'PID_opt' and 'RMS_opt' should be put under same directory. The 'PID_opt' is the main code for optimization and 'RMS_opt' is a sub-function
of 'PID_opt'. To run the optimization for a specified road profile, the input should be selected manually and the system should be active suspension
system (the manual switch in the right-hand side should be switched to the output of the PID controller)

### LQR

1.Open the files "GENA_LQR2_run.m", "GENA_LQR2.m", "Quarter_LQRGENA_wh2".
2.Run "GENA_LQR2_run.m".
3.Select a road disturbance in the simulink model "Quarter_LQRGENA_wh2" and run the simulink model.
4.Click "scope" and "scope2" in the right-hand side of the simulink model to check the suspension stroke and verticle acceleration compared with the passive suspension system.

Note:
"GENA_LQR2.m" creates a function "GENA_LQR2" to be called in "GENA_LQR2_run.m".
You can change the fitness function in "GENA_LQR2.m" as you need.
You can change the parameters of genetic algorithm in "GENA_LQR2_run.m".

### DDPG
Please perform the following actions to run the code:
- Open DDPG.slx file
- Load parameters.m file
- Run DDPG_Train.m file

After this sequence, please run the following command on command window for training the agent:
```Matlab
trainingStats = agent.train(env,trainOpts);
```

Once the training is completed, please run the following commands on command window:
```Matlab
simOpts = rlSimulationOptions(MaxSteps=ceil(Tf/Ts),StopOnError="on");
experiences = env.sim(agent,simOpts);
```

Alternatively, you can already load the pre-trained agent:
```Matlab
load("trained_agent","agent")
```

Finally, please run the DDPG simulink file
