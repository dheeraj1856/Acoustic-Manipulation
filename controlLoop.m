function [step,manipulationTime] = controlLoop(mycontroller,maps,target,tolerance,plate,recorder)                     
    tic;    
    step = 0;    
    % Show the target on the machine vision
    plate.setTarget(target);              
    % Fetch the latest positions from machine vision
    curPos = plate.getPositions();
    % Loop until the object is within tolerance of the target
    while any(distance(curPos,target) > tolerance)           
        % Ask the controller which frequency to play next
        frequencyId = mycontroller(maps,curPos,target);                                                 
        % Play the frequency       
        plate.play(frequencyId); 
        % Get the positions after playing the frequency
        nextPos = plate.getPositions();        
        if (nargin > 5 && ~isempty(recorder))
            % Save/show the data
            recorder(curPos,nextPos,target,frequencyId);
        end
        curPos = nextPos;  
        step = step + 1;        
    end
    manipulationTime = toc;              
    
    function ret = distance(from,to)
        ret = sqrt(sum((from-to).^2,2));
    end
end