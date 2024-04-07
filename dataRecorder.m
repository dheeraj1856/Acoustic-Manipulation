function ret = dataRecorder(varargin)            
    % dataRecorder  Constructor for creating a data recorder object
    %               The control loop uses data recorder to show the
    %               manipulation on screen and/or save .txt log file and/or
    %               save a video. The log file is comma separated, each
    %               line having following columns:
    %               number-of-particles n,id of the frequency played,[positions
    %               of the particles before, 2*n columns],[positions of
    %               particle afterwards, 2*n columns],[targets, 2*n
    %               columns]
    %               
    %               recorder = dataRecorder(name,value,...)
    %
    %               optional parameters:
    %                   'plot': 'none','screen' or 'video'; video plots
    %                   also to screen
    %                   'log': true or false, enables/disables logging
    %                   'videofile': if undefined, asks for the user where
    %                   to save the video
    %                   'logfile': if undefined, asks for the user where
    %                   to save the data
    %                   'maps: the struct array for the vectors fields. if
    %                   defined, the plots also show the vector fields
    
    % Constructor
    
    inp = inputParser;    
    addParameter(inp,'plot','screen',@(x) any(validatestring(x,{'none','screen','video'})));
    addParameter(inp,'log',false);
    addParameter(inp,'maps',[]);
    addParameter(inp,'videofile',[]);
    addParameter(inp,'logfile',[]);   
    parse(inp,varargin{:});
          
    N = 20;
    [MX,MY] = meshgrid(linspace(0,1,N),linspace(0,1,N));    
    
    if (inp.Results.log)
        logfile = inp.Results.logfile;        
        if (isempty(logfile))
            [logfile,logpath] = uiputfile('.txt','Choose where to save logfile of the manipulation',['log_' datestr(now,'yymmdd_HHMMSS') '.txt']);        
            logfile = [logpath logfile];
        end
    end
           
    if (strcmp(inp.Results.plot,'video'))
        videofile = inp.Results.videofile;
        if (isempty(videofile))
            [videofile,videopath] = uiputfile('.avi','Choose where to save a video of the manipulation',['video_' datestr(now,'yymmdd_HHMMSS') '.avi']);    
            videofile = [videopath videofile];
        end
        vidObj = VideoWriter(videofile);
        open(vidObj);
    end               
    
    if ~strcmp(inp.Results.plot,'none')
        fig = figure();    
        historyX = [];
        historyY = [];                
    end
    
    ret = @record;               
    
    % Public methods
    
    function record(p,n,t,frequencyId)                        
        if inp.Results.log
            M = [flat(size(p,1)) flat(p) flat(n) flat(t) flat(frequencyId)];
            dlmwrite(logfile,M,'-append') 
        end
        if ~strcmp(inp.Results.plot,'none')
            historyX = [historyX p(:,1)];
            historyY = [historyY p(:,2)];            
            scale = 10;
            figure(fig);         
            clf;        
            hold on;
            if (~isempty(historyX))
                plot(historyX,historyY,'b.');                                
            end                
            visualizeText(p);        
            visualizeText(t);            
            plot(p(:,1),p(:,2),'rd');                                        
            plot(t(:,1),t(:,2),'g*');                
            title(sprintf('Frequency ID: %d',frequencyId));
            if (~isempty(inp.Results.maps))
                maps = inp.Results.maps;
                delta = [maps(frequencyId).deltaX(p) maps(frequencyId).deltaY(p)];
                plot([p(:,1) p(:,1)+scale*delta(:,1)]',[p(:,2) p(:,2)+scale*delta(:,2)]','c-','LineWidth',2);                        
                quiver(MX,MY,maps(frequencyId).deltaX(MX,MY),maps(frequencyId).deltaY(MX,MY),3,'AutoScale','off','color','b')                
            end
            set(gca,'YDir','reverse');
            hold off;        
            axis([0 1 0 1]);
            if (exist('vidObj','var'))
                writeVideo(vidObj, getframe(gcf));
            end          
        end
    end

    % Private methods

    function visualizeText(p)
       b = num2str((1:size(p,1))');
       c = cellstr(b);
       dx = 0.01; dy = 0.01;
       text(p(:,1)+dx, p(:,2)+dy, c); 
    end

    function ret = flat(d)
        ret = reshape(d,1,numel(d));
    end
end