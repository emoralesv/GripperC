% acquisition
% Clase para gestionar la adquisición de imágenes desde webcam o video y
% realizar detección de marcadores con un modelo de Deep Learning.

classdef acquisition
    properties
        camera              % Objeto webcam o VideoReader según cameraType
        cameraType          % Tipo de fuente: "webcam" o "video"
        preprocessMethod    % Método de preprocesamiento: "contrast" o "none"
        detectionMethod     % Método de detección: "DL" (Deep Learning)
        model               % Detector cargado desde archivo .mat
        vidObj              % Objeto VideoReader para video file
        confidence = 0.5;   % Nivel de confianza mínimo para detección
    end

    methods
        %% Constructor
        function obj = acquisition(cameraType, camera, preprocessMethod, detectionMethod, model)
            % Inicializa la instancia con parámetros de entrada:
            % cameraType: "webcam" o "video"
            % camera: nombre de la cámara o ruta de video
            % preprocessMethod: "contrast" o "none"
            % detectionMethod: "DL" para carga de modelo
            % model: archivo .mat con variable 'detector'

            obj.cameraType = cameraType;
            obj.preprocessMethod = preprocessMethod;
            obj.detectionMethod = detectionMethod;

            % Configura la fuente de imágenes
            if cameraType == "webcam"
                obj.camera = webcam(camera);
            end
            if cameraType == "video"
                obj.vidObj = VideoReader(camera);
            end

            % Si se elige detección con Deep Learning, carga el modelo
            if detectionMethod == "DL"
                disp("Loading model");
                data = load(model);
                obj.model = data.detector;   % Asume variable 'detector' en el .mat
            end
        end

        %% Método principal de detección
        function [I, detectedImg, bboxes, labels] = detectMarkers(obj)
            % Captura imagen, realiza detección y devuelve:
            % I          - imagen original preprocesada
            % detectedImg- imagen con anotaciones (rectángulos)
            % bboxes     - bounding boxes detectadas
            % labels     - etiquetas de los objetos detectados

            I = obj.image();  % Obtiene la imagen preprocesada
            if ~isempty(I)
                % Detecta con el modelo DL en GPU
                [bboxes, ~, labels] = detect(obj.model, I, ...
                    'Threshold', obj.confidence, ...
                    'ExecutionEnvironment', 'gpu');
                % Inserta anotaciones si hay detecciones
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

        %% Detección con umbral variable y frame dado
        function [I, detectedImg, bboxes, labels] = detectMarkersFrame(obj, I, tr)
            % Ejecuta detección sobre la imagen I usando umbral tr
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

        %% Captura imagen según fuente y preprocesa
        function I = image(obj)
            switch obj.cameraType
                case 'webcam'
                    I = snapshot(obj.camera);      % Toma foto de webcam
                case 'video'
                    if hasFrame(obj.vidObj)
                        I = readFrame(obj.vidObj);     % Lee siguiente frame de video
                    else
                        I = [];                        % Fin de video
                    end
                otherwise
                    I = [];
            end
            % Aplica preprocesamiento antes de retornar
            I = obj.preprocess(I);
        end

        %% Preprocesamiento de imagen
        function Ic = preprocess(obj, I)
            switch obj.preprocessMethod
                case "contrast"
                    % Mejora local de contraste
                    Ic = localcontrast(I);
                case "none"
                    % Sin cambios
                    Ic = I;
                otherwise
                    Ic = I;
            end
        end
    end
end
