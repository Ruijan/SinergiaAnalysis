classdef LaplacianFilter < SpatialFilter & handle
    
    methods
        function obj = LaplacianFilter(nbChannels)
            obj@SpatialFilter(nbChannels);
            obj.filterMatrix = ...
                [1   ,0    ,0    ,-1/4 ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0;...
                0    ,1    ,-1/3 ,0    ,0    ,0    ,-1/3 ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0;...
                0    ,-1/2 ,1    ,-1/4 ,0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0;...
                -1   ,0    ,-1/3 ,1    ,-1/3 ,0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,0    ,0    ,0    ,0;...
                0    ,0    ,0    ,-1/4 ,1    ,-1/2 ,0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,0    ,0    ,0;...
                0    ,0    ,0    ,0    ,-1/3 ,1    ,0    ,0    ,0    ,0    ,-1/3 ,0    ,0    ,0    ,0    ,0;...
                0    ,-1/2 ,0    ,0    ,0    ,0    ,1    ,-1/4 ,0    ,0    ,0    ,-1/2 ,0    ,0    ,0    ,0;...
                0    ,0    ,-1/3 ,0    ,0    ,0    ,-1/3 ,1    ,-1/4 ,0    ,0    ,0    ,-1/3 ,0    ,0    ,0;...
                0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,-1/4 ,1    ,-1/4 ,0    ,0    ,0    ,-1/3 ,0    ,0;...
                0    ,0    ,0    ,0    ,-1/3 ,0    ,0    ,0    ,-1/4 ,1    ,-1/3 ,0    ,0    ,0    ,-1/3 ,0;...
                0    ,0    ,0    ,0    ,0    ,-1/2 ,0    ,0    ,0    ,-1/4 ,1   ,0    ,0    ,0    ,0    ,-1/2;...
                0    ,0    ,0    ,0    ,0    ,0    ,-1/3 ,0    ,0    ,0    ,0    ,1    ,-1/3 ,0    ,0    ,0;...
                0    ,0    ,0    ,0    ,0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,-1/2 ,1    ,-1/3 ,0    ,0;...
                0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,-1/3 ,1    ,-1/3 ,0;...
                0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,-1/4 ,0    ,0    ,0    ,-1/3 ,1    ,-1/2;...
                0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,0    ,-1/3 ,0    ,0    ,0    ,-1/3 ,1];
        end
    end
end

