function in = localResetFcn(in)

% Randomize reference signal
blk = sprintf('DDPG/Desired \nWater Level');
h = 3*randn + 1;
while h <= -10 || h >= 10
    h = 3*randn + 10;
end
in = setBlockParameter(in,blk,'Value',num2str(h));

% Randomize initial height
h = 3*randn + 1;
while h <= -10 || h >= 10
    h = 3*randn + 10;
end
blk = 'DDPG/Suspension System/plant/H';
in = setBlockParameter(in,blk,'InitialCondition',num2str(h));

end