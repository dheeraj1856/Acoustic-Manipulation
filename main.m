% All units are normalized to the plate size: (0,0) is topleft corner,
% (1,0) is the topright corner; (0,1) is the bottomleft corner

clear all; close all;

IS_REALPLATE = false; % false|true

% Starting point for the manipulation
start = [0.7 0.3]; % Where the particle starts in the simulation
target = [0.2 0.9]; % Where the controller should try to move the particle
tolerance = 0.01; % At which distance the particle considered have reached the target, in plate units
particle_stuck = 0;
played_notes = [];
mycontroller = @controller; % Replace this line to switch from one controller to another

load('maps.mat');
load('modelInfo.mat');

% dataRecorder(...,'log',true) saves log file
% dataRecorder(...,'plot','video') save a video
% recorder = dataRecorder('maps',maps,'plot','screen');
recorder = dataRecorder('maps',maps,'plot','video','log',true);

% For simulation, use simulatedPlate.
% In the final competition, we will replace this with realPlate
if IS_REALPLATE
    % real plate
    plate = realPlate(modeInfo,maps);
else
    % simulator
    plate = simulatedPlate(modeInfo,maps,start,particle_stuck,played_notes);
end


% Run the main control loop
steps = controlLoop(mycontroller,maps,target,tolerance,plate,recorder);
fprintf('Manipulation completed in %d steps\n',steps);

% Clearing all references to the recorder calls the destructor for a
% videoWriter, so the video file is not locked anymore and can be watched
recorder = [];