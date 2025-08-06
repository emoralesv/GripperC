% acquisition
% Class to handle image acquisition from a webcam or video and
% perform marker detection using a Deep Learning model.

classdef acquisition
    properties
        camera              % Webcam or VideoReader object depending on cameraType
        cameraType          % Source type: "webcam" or "video"
        preprocessMethod    % Preprocessing method: "contrast" or "none"
        detectionMethod     % Detection method: "DL" (Deep Learning)
        model               % Detector loaded from .mat file
        vidObj              % VideoReader object for video files
        confidence = 0.5;   % Minimum confidence level for detection
    end

    methods
        %% Constructor
        function obj = acquisition(cameraType, camera, preprocessMethod, detectionMethod, model)
            % Initialize instance with input parameters:
            % cameraType: "webcam" or "video"
            % camera: camera name or video path
            % preprocessMethod: "contrast" or "none"
            % detectionMethod: "DL" to load a model
            % model: .mat file containing a variable named 'detector'

            obj.cameraType = cameraType;
            obj.preprocessMethod = preprocessMethod;
            obj.detectionMethod = detectionMethod;

            % Set up image source
            if cameraType == "webcam"
                obj.camera = webcam(camera);
            end
            if cameraType == "video"
                obj.vidObj = VideoReader(camera);
            end

            % If Deep Learning detection is chosen, load the model
            if detectionMethod == "DL"
                disp("Loading model");
                data = load(model);
                obj.model = data.detector;   % Assumes variable 'detector' in the .mat
            end
        end

        %% Main detection method
        function [I, detectedImg, bboxes, labels] = detectMarkers(obj)
            % Capture an image, run detection, and return:
            % I          - preprocessed original image
            % detectedImg- image with annotations (rectangles)
            % bboxes     - detected bounding boxes
            % labels     - labels of detected objects

            I = obj.image();  % Get preprocessed image
            if ~isempty(I)
                % Run DL model on GPU
                [bboxes, ~, labels] = detect(obj.model, I, ...
                    'Threshold', obj.confidence, ...
                    'ExecutionEnvironment', 'gpu');
                % Insert annotations if detections exist
                if ~isempty(bboxes)
                    detectedImg = insertObjectAnnotation(I, 'Rectangle', bboxes, labels);
                else
                    detectedImg = I;
                end
            else
                detectedImg = [];
                bboxes = [];
                labels = [];
            end
        end

        %% Detection with variable threshold and given frame
        function [I, detectedImg, bboxes, labels] = detectMarkersFrame(obj, I, tr)
            % Run detection on image I using threshold tr
            if ~isempty(I)
                [bboxes, ~, labels] = detect(obj.model, I, ...
                    'Threshold', tr, ...
                    'ExecutionEnvironment', 'gpu');
                if ~isempty(bboxes)
                    detectedImg = insertObjectAnnotation(I, 'Rectangle', bboxes, labels);
                else
                    detectedImg = I;
                end
            else
                detectedImg = [];
                bboxes = [];
                labels = [];
            end
        end

        %% Capture image according to source and preprocess
        function I = image(obj)
            switch obj.cameraType
                case 'webcam'
                    I = snapshot(obj.camera);      % Capture webcam frame
                case 'video'
                    if hasFrame(obj.vidObj)
                        I = readFrame(obj.vidObj);     % Read next video frame
                    else
                        I = [];                        % End of video
                    end
                otherwise
                    I = [];
            end
            % Apply preprocessing before returning
            I = obj.preprocess(I);
        end

        %% Image preprocessing
        function Ic = preprocess(obj, I)
            switch obj.preprocessMethod
                case "contrast"
                    % Enhance local contrast
                    Ic = localcontrast(I);
                case "none"
                    % No changes
                    Ic = I;
                otherwise
                    Ic = I;
            end
        end
    end
end
