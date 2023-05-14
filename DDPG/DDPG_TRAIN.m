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
K = lqr(A,B,Q,R);


obsInfo = rlNumericSpec([3 1],...
    LowerLimit=[-inf -inf 0  ]',...
    UpperLimit=[ inf  inf inf]');
obsInfo.Name = "observations";
obsInfo.Description = "integrated error, error, and Stroke";

actInfo = rlNumericSpec([1 1]);
actInfo.Name = "Control Action";

env = rlSimulinkEnv("DDPG","DDPG/RL Agent",...
    obsInfo,actInfo);

env.ResetFcn = @(in)localResetFcn(in);

Ts = 0.2;
Tf = 20;

rng(0)

% Observation path
obsPath = [
    featureInputLayer(obsInfo.Dimension(1),Name="obsInputLayer")
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(25,Name="obsPathOutLayer")];

% Action path
actPath = [
    featureInputLayer(actInfo.Dimension(1),Name="actInputLayer")
    fullyConnectedLayer(25,Name="actPathOutLayer")];

% Common path
commonPath = [
    additionLayer(2,Name="add")
    reluLayer
    fullyConnectedLayer(1,Name="CriticOutput")];

criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,obsPath);
criticNetwork = addLayers(criticNetwork,actPath);
criticNetwork = addLayers(criticNetwork,commonPath);

criticNetwork = connectLayers(criticNetwork, ...
    "obsPathOutLayer","add/in1");
criticNetwork = connectLayers(criticNetwork, ...
    "actPathOutLayer","add/in2");

figure(3)
plot(criticNetwork)

criticNetwork = dlnetwork(criticNetwork);
summary(criticNetwork)

critic = rlQValueFunction(criticNetwork, ...
    obsInfo,actInfo, ...
    ObservationInputNames="obsInputLayer", ...
    ActionInputNames="actInputLayer");

getValue(critic, ...
    {rand(obsInfo.Dimension)}, ...
    {rand(actInfo.Dimension)})

actorNetwork = [
    featureInputLayer(obsInfo.Dimension(1))
    fullyConnectedLayer(3)
    tanhLayer
    fullyConnectedLayer(actInfo.Dimension(1))
    ];

actorNetwork = dlnetwork(actorNetwork);
summary(actorNetwork)

actor = rlContinuousDeterministicActor(actorNetwork,obsInfo,actInfo);

getAction(actor,{rand(obsInfo.Dimension)})

agent = rlDDPGAgent(actor,critic);

agent.SampleTime = Ts;

agent.AgentOptions.TargetSmoothFactor = 1e-3;
agent.AgentOptions.DiscountFactor = 0.9;
agent.AgentOptions.ExperienceBufferLength = 1e6; 
agent.AgentOptions.NoiseOptions.Variance = 0.3;
agent.AgentOptions.NoiseOptions.VarianceDecayRate = 1e-5;
agent.AgentOptions.SampleTime = Ts;
agent.AgentOptions.MiniBatchSize = 32;
agent.AgentOptions.NoiseOptions.StandardDeviation = 0.3;
agent.AgentOptions.NoiseOptions.StandardDeviationDecayRate = 1e-7;
agent.AgentOptions.ActorOptimizerOptions.LearnRate = 1e-4;
agent.AgentOptions.ActorOptimizerOptions.GradientThreshold = 1;
agent.AgentOptions.CriticOptimizerOptions.LearnRate = 5e-3;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 1;




getAction(agent,{rand(obsInfo.Dimension)})

trainOpts = rlTrainingOptions(...
    MaxEpisodes=5000, ...
    MaxStepsPerEpisode=ceil(Tf/Ts), ...
    ScoreAveragingWindowLength=20, ...
    Verbose=false, ...
    Plots="training-progress",...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=800);

