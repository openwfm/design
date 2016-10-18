function d=point_dist(p,q,dom)
d=norm([dom.unit_fxlong*(p.Lon-q.Lon), dom.unit_fxlat*(p.Lat-q.Lat)]);