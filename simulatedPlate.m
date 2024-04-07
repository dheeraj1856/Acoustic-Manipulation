function ret = simulatedPlate(modeInfo,maps,positions,particle_stuck,played_notes)        
    % simulatedPlate  Constructor for creating a mockup plate object
    %
    %                 plate = simulatedPlate(p,maps) creates a simulated plate
    %                   using the maps struct array and p starting point
    
    ret = struct('play',@play,'getPositions',@getPositions,'setTarget',@setTarget);                       
    target = [];
    
    % In real plate, this will show the target in the machine vision
    function setTarget(t)  
        target = t;
    end

    % In real plate, this will play real sound
    % The mockup plate simulates the movement based on deltaX and deltaY,
    % adding some randonmness based on the variance maps
    function play(noteId)                      
        if (noteId < 1 || noteId > length(maps))
            error('Invalid frequencyId, should be between 1..%d (was: %d)',length(maps),noteId);
        end
        
        stuck_probability = 0.05;
        get_stuck = rand;
        
        if ((particle_stuck == 0) && (get_stuck > stuck_probability)) || ... 
            ((particle_stuck == 1) && (noteId ~= played_notes(end)))
            noise = (sqrt(max(maps(noteId).variance(positions),0)) * [1 1]) .* randn(size(positions));
            positions = positions + [maps(noteId).deltaX(positions),maps(noteId).deltaY(positions)] + noise; 
            particle_stuck = 0; 
        elseif (particle_stuck == 0) && (get_stuck <= stuck_probability)   
            particle_stuck = 1; 
        end
        
        pause(1e-6); % slow things down just enough matlab has time to plot things      
        
        % play sound
        freq = modeInfo.freq(noteId);
        duration = modeInfo.duration(noteId);
        amp = min(max(modeInfo.amp(noteId),0),1);
        played_notes = [played_notes; noteId];
    end

    % In real plate, this will perform machine vision
    function ret = getPositions()
        ret = positions;
    end
end