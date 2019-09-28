function [ neighbors_xy, neighbors_ind ] = getNeighborhood( x,y,neighbor_pos,xy_boundary,matrix_size,bounds_mode )
%GETNEIGHBOR get neighborhood postion and ind of x,y
%   neighbor_pos: the range of neighborhood
if length(xy_boundary)~=4;
    error('getNeighborhood::x y boundary format error. please input [Xmin Xmax Ymin Ymax]');
end
if length(x)~=length(y);
    error('getNeighborhood::dimension of x y must be equal');
end
if ~isa(x,'int')
    x = int16(x);
end
if ~isa(y,'int')
    y = int16(y);
end
if strcmp(bounds_mode,'ignore')
    %% 越界区域忽略
    x1 = max(x-neighbor_pos,xy_boundary(1));
    x2 = min(x+neighbor_pos,xy_boundary(2));
    y1 = max(y-neighbor_pos,xy_boundary(3));
    y2 = min(y+neighbor_pos,xy_boundary(4));
    neighbors_ind = cell(length(x),1);
    neighbors_xy = cell(length(x),1);
    for i = 1:length(x)
        [neighbor_x,neighbor_y] = meshgrid(x1(i):x2(i),y1(i):y2(i));
        neighbors_xy{i} = [neighbor_x(:),neighbor_y(:)];
        neighbors_ind{i} = sub2ind(matrix_size,neighbor_y,neighbor_x);
    end
elseif strcmp(bounds_mode,'randomfill')
    %% 越界做随机填充处理
    x1 = x-neighbor_pos;
    x2 = x+neighbor_pos;
    y1 = y-neighbor_pos;
    y2 = y+neighbor_pos;
    neighbors_ind = cell(1,length(x));
    neighbors_xy = cell(1,length(x));
    for i = 1:length(x)
        [neighbor_x,neighbor_y] = meshgrid(x1(i):x2(i),y1(i):y2(i));
        %找出越界的点
        out_of_bound_bw = neighbor_x < xy_boundary(1)|neighbor_x> xy_boundary(2)|neighbor_y < xy_boundary(3)|neighbor_y> xy_boundary(4);
        inrange_ind = find(~out_of_bound_bw);
        %随机替换越界点
        fill_ind = inrange_ind(randi(length(inrange_ind),nnz(out_of_bound_bw),1));
        neighbor_x(out_of_bound_bw) = neighbor_x(fill_ind);
        neighbor_y(out_of_bound_bw) = neighbor_y(fill_ind);
        neighbors_xy{i} = [neighbor_x(:),neighbor_y(:)];
        neighbors_ind{i} = uint32(sub2ind(matrix_size,neighbor_y(:),neighbor_x(:)));
    end
else
    error('getNeighborhood::mode error');
end
end

