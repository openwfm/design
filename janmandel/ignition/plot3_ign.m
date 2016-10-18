function plot3_ign(ign,t_sec,varargin)
% plot3_ign(ign,t_sec[,mark,ndims)
    opt=length(varargin);
    if opt>=1,
        mark=varargin{1};
    else
        mark='+r';
    end
    if opt>=2,
        ndims=varargin{2};
    else
        ndims=3;
    end
    Lon=[ign.Lon];
    Lat=[ign.Lat];
    t=[ign.t];
    ix=find(t<=t_sec);
    fprintf('plot3_ign: %d ignited points\n',length(ix))
    switch ndims
        case 2
            plot(Lon(ix),Lat(ix),mark)
        case 3
            plot3(Lon(ix),Lat(ix),t(ix),mark)
        otherwise
            error('ndims must be 2 or 3')
    end
end
