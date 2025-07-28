classdef markersInterface

    properties
        markers
        time 
    end

    methods%colorCount = [2,0,0,0,0,0,0,0];
        function obj = markersInterface(colorCount,updateFactor,samples)
            markersCount = 1;
            for colorN = 1 : size(colorCount,2)
                for n = 1: colorCount( colorN)
                    obj.markers{markersCount} = marker(colorN,updateFactor,samples);
                    markersCount = markersCount + 1;
                end
            end
            obj.time =  datetime('now');
            fprintf("markers were intialized \n");
        end
        function obj = updateNaN(obj)
            
            for markerN = 1: size(obj.markers,2)
                obj.markers{marker} = obj.markers{marker}.updateData(Nan,Nan,NaN);

            end
        end
        function obj =  updateMarkers(obj,centers,labels)
            %obj.time = obj.time + deltaTime;
            currTime = datetime("now") - obj.time;
            currTime = seconds(currTime);
            distance = zeros([size(centers,1),size(obj.markers,2)]);

            for markerN = 1: size(obj.markers,2)
                idx = string(labels) == obj.markers{markerN}.colorName;
                for detectedMarker = 1 : size(centers,1)
                    if idx(detectedMarker) == 1
                        distanceX = obj.markers{markerN}.xMean - (centers(detectedMarker,1)+(centers(detectedMarker,3)/2));
                        distanceY = obj.markers{markerN}.yMean - (centers(detectedMarker,2)+(centers(detectedMarker,3)/2));
                        distance(detectedMarker,markerN) = sqrt(distanceX^2 + distanceY^2);
                    else
                        distance(detectedMarker,markerN) = Inf;
                    end
                end
            end

            [assignment,~,~] = assignDetectionsToTracks(distance,1000);
            for as = 1: size(assignment,1)
                center = assignment(as,1); marker = assignment(as,2);
                obj.markers{marker} = obj.markers{marker}.updatexy(centers(center,1)+(centers(center,3)/2),centers(center,2)+(centers(center,3)/2));
                if distance(center,marker) < centers(center,3)
                    obj.markers{marker} = obj.markers{marker}.updateData(centers(center,1)+(centers(center,3)/2),centers(center,2)+(centers(center,3)/2) ,(centers(center,3) + centers(center,4))/2 , currTime);
                end
   
            end




            end
        end
    end
