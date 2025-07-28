% marker
% Clase para gestionar un marcador de color: mantiene estadísticas de posición,
% color y registro temporal de datos para seguimiento.

classdef marker
    %% Propiedades de la clase
    properties
        colorName       % Nombre del color (e.g., 'red')
        xMean           % Media de coordenada X en la ventana de muestra
        yMean           % Media de coordenada Y en la ventana de muestra
        colorMean       % Media de color (RGB) en la ventana de muestra
        data            % Timetable con historial de [Time, xData, yData]
        sampleNumber    % Número de muestras para cálculo de medias móviles
        colorSamples    % Vector de muestras de color
        time            % Vector de tiempos (duration) para cada muestra de data
        xData           % Vector temporal de coordenada X antes de consolidar en data
        yData           % Vector temporal de coordenada Y antes de consolidar en data
        xSamples        % Buffer circular de muestras de X para media móvil
        ySamples        % Buffer circular de muestras de Y para media móvil
        colorIndex      % Índice actual en buffer de colorSamples
        meanIndex       % Índice actual en buffers xSamples/ySamples
        dataIndex       % Índice actual en buffers xData/yData/time
        updateFactor    % Factor de actualización: número de frames antes de guardar data
        initialized     % Flag que indica si el marcador ha sido inicializado
        radii           % Radio medio estimado del marcador
    end

    methods
        %% Constructor
        function obj = marker(colorIndex, updateFactor, sample)
            % colorIndex: índice (1-8) del color en la paleta
            % updateFactor: número de iteraciones antes de consolidar en 'data'
            % sample: tamaño de ventana para medias móviles (xSamples, ySamples)

            % Definición de colores RGB y nombres
            colors = [255 0 0; 0 255 0; 0 0 255; 0 255 255; ...
                      255 0 255; 255 255 0; 0 0 0; 255 255 255];
            colornames = ["red","green","blue","cyan", ...
                          "magenta","yellow","black","white"];

            % Inicializa propiedades de color
            obj.colorMean   = colors(colorIndex, :);
            obj.colorName   = colornames(colorIndex);
            obj.colorIndex  = 1;

            % Parámetros de buffer y muestra
            obj.updateFactor = updateFactor;
            obj.sampleNumber = sample;

            % Inicializa buffers circulares para posición y color
            obj.xSamples = ones(sample,1) * 110;
            obj.ySamples = ones(sample,1) * 110;
            obj.colorSamples = zeros(sample,3) + obj.colorMean;

            % Calcula medias iniciales
            obj.xMean = mean(obj.xSamples);
            obj.yMean = mean(obj.ySamples);

            % Buffers para almacenamiento temporal antes de consolidación
            obj.xData = zeros(1, updateFactor);
            obj.yData = zeros(1, updateFactor);
            obj.time = seconds(zeros(1, updateFactor));

            % Índices para buffer circular
            obj.meanIndex = 1;
            obj.dataIndex = 1;

            % Estado de inicialización
            obj.initialized = false;

            % Radio inicial por defecto
            obj.radii = 10;
        end

        %% Actualiza buffer de color y recalcula media
        function obj = updateColor(obj, color)
            % color: vector RGB de nueva muestra
            obj.colorSamples(obj.colorIndex, :) = color;
            obj.colorMean = mean(obj.colorSamples, 1);
            obj.colorIndex = obj.colorIndex + 1;
            % Buffer circular
            if obj.colorIndex > obj.sampleNumber
                obj.colorIndex = 1;
            end
        end

        %% Actualiza buffers de coordenadas y recalcula media
        function obj = updatexy(obj, x, y)
            % x, y: nuevas coordenadas de muestra
            obj.xSamples(obj.meanIndex) = x;
            obj.ySamples(obj.meanIndex) = y;
            obj.xMean = mean(obj.xSamples);
            obj.yMean = mean(obj.ySamples);
            obj.meanIndex = obj.meanIndex + 1;
            if obj.meanIndex > obj.sampleNumber
                obj.meanIndex = 1;
            end
        end

        %% Registra nueva muestra en 'data' cuando se alcanza updateFactor
        function obj = updateData(obj, x, y, radii, time)
            % x, y: coordenadas actuales
            % radii: vector de radios detectados
            % time: tiempo actual (en segundos)

            % Añade en buffers temporales
            obj.xData(obj.dataIndex) = x;
            obj.yData(obj.dataIndex) = y;
            obj.radii = mean(radii);
            obj.time(obj.dataIndex) = seconds(time);
            obj.dataIndex = obj.dataIndex + 1;

            % Cuando el buffer está lleno, consolida en timetable
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
