% marker
% Class to handle a color marker: maintains position statistics,
% color data, and time history for tracking.

classdef marker
    %% Class properties
    properties
        colorName       % Color name (e.g., 'red')
        xMean           % Mean X coordinate within the sample window
        yMean           % Mean Y coordinate within the sample window
        colorMean       % Mean color (RGB) within the sample window
        data            % Timetable storing [Time, xData, yData]
        sampleNumber    % Number of samples for moving average
        colorSamples    % Vector of color samples
        time            % Time vector (duration) for each data sample
        xData           % Temporary X coordinates before being stored in data
        yData           % Temporary Y coordinates before being stored in data
        xSamples        % Circular buffer of X samples for moving average
        ySamples        % Circular buffer of Y samples for moving average
        colorIndex      % Current index in colorSamples buffer
        meanIndex       % Current index in xSamples/ySamples buffers
        dataIndex       % Current index in xData/yData/time buffers
        updateFactor    % Update factor: number of frames before saving data
        initialized     % Flag indicating whether the marker has been initialized
        radii           % Estimated average radius of the marker
    end

    methods
        %% Constructor
        function obj = marker(colorIndex, updateFactor, sample)
            % colorIndex: index (1-8) of the color in the palette
            % updateFactor: number of iterations before consolidating into 'data'
            % sample: window size for moving averages (xSamples, ySamples)

            % Definition of RGB colors and names
            colors = [255 0 0; 0 255 0; 0 0 255; 0 255 255; ...
                      255 0 255; 255 255 0; 0 0 0; 255 255 255];
            colornames = ["red","green","blue","cyan", ...
                          "magenta","yellow","black","white"];

            % Initialize color properties
            obj.colorMean   = colors(colorIndex, :);
            obj.colorName   = colornames(colorIndex);
            obj.colorIndex  = 1;

            % Buffer and sample parameters
            obj.updateFactor = updateFactor;
            obj.sampleNumber = sample;

            % Initialize circular buffers for position and color
            obj.xSamples = ones(sample,1) * 110;
            obj.ySamples = ones(sample,1) * 110;
            obj.colorSamples = zeros(sample,3) + obj.colorMean;

            % Compute initial means
            obj.xMean = mean(obj.xSamples);
            obj.yMean = mean(obj.ySamples);

            % Buffers for temporary storage before consolidation
            obj.xData = zeros(1, updateFactor);
            obj.yData = zeros(1, updateFactor);
            obj.time = seconds(zeros(1, updateFactor));

            % Indices for circular buffer
            obj.meanIndex = 1;
            obj.dataIndex = 1;

            % Initialization state
            obj.initialized = false;

            % Default initial radius
            obj.radii = 10;
        end

        %% Update color buffer and recompute mean
        function obj = updateColor(obj, color)
            % color: RGB vector of the new sample
            obj.colorSamples(obj.colorIndex, :) = color;
            obj.colorMean = mean(obj.colorSamples, 1);
            obj.colorIndex = obj.colorIndex + 1;
            % Circular buffer
            if obj.colorIndex > obj.sampleNumber
                obj.colorIndex = 1;
            end
        end

        %% Update coordinate buffers and recompute mean
        function obj = updatexy(obj, x, y)
            % x, y: new sample coordinates
            obj.xSamples(obj.meanIndex) = x;
            obj.ySamples(obj.meanIndex) = y;
            obj.xMean = mean(obj.xSamples);
            obj.yMean = mean(obj.ySamples);
            obj.meanIndex = obj.meanIndex + 1;
            if obj.meanIndex > obj.sampleNumber
                obj.meanIndex = 1;
            end
        end

        %% Record new sample in 'data' when updateFactor is reached
        function obj = updateData(obj, x, y, radii, time)
            % x, y: current coordinates
            % radii: vector of detected radii
            % time: current time (in seconds)

            % Add to temporary buffers
            obj.xData(obj.dataIndex) = x;
            obj.yData(obj.dataIndex) = y;
            obj.radii = mean(radii);
            obj.time(obj.dataIndex) = seconds(time);
            obj.dataIndex = obj.dataIndex + 1;

            % When buffer is full, consolidate into timetable
            if obj.dataIndex > obj.updateFactor
                obj.dataIndex = 1;
                newEntry = timetable(obj.time', obj.xData', obj.yData', ...
                                     'VariableNames', {'x','y'});
                if isempty(obj.data)
                    obj.data = newEntry;
                else
                    obj.data = [obj.data; newEntry];
                end
            end
        end
    end
end
