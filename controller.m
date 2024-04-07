function id = controller(maps,position,target)
    % controller    Decides the id of the frequency that should be played.
    %               Usage:
    %
    %               id = controller(maps,position,target)
    %               
    %               maps is a struct array of length M and id should be
    %                  index to this array (1..M).
    %               position is the current position(s) of the particle(s)
    %               target is the current target(s) of the particle(s).
    %    
    %               The predicted movement of a particle after returning id
    %               is pnew = p + [maps(id).deltaX(p) maps(id).deltaY(p)].
    
    % TODO: Implement your controller here.
    % Initialize variables to store the minimum distance and the corresponding frequency ID
    persistent prev_x prev_y
    minDistance = inf;
    id = 1; % Default to the first frequency if no better option is found
    
    % Extract the current position coordinates
    x = position(1);
    y = position(2);
    
    % Iterate through each frequency in the maps
    for i = 1:length(maps)
        % Evaluate the sfit objects for deltaX and deltaY at the current position
        deltaX = feval(maps(i).deltaX, x, y);
        deltaY = feval(maps(i).deltaY, x, y);
        
        % Predict new position after applying the current frequency's movement
        predictedPosition = position + [deltaX, deltaY];
        
        % Calculate the Euclidean distance from the predicted position to the target
        distance = norm(predictedPosition - target);
        
        % Update minDistance and id if this frequency results in a closer position to the target
        if distance < minDistance
            minDistance = distance;
            id = i;
        end
    end

    if ~isempty(prev_x) || ~isempty(prev_y)
        prev_dist = norm([x - prev_x, prev_y-y]);
        thresh = 0.001;
        if prev_dist <= thresh 
            id = randi([1,length(maps)]);
            sprintf('Random frequency selected!')
        end
    end

    prev_y = y;
    prev_x = x;


%     id = randi([1,length(maps)]);     
end
        