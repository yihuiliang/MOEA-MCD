clear,addpath('moead');
img = imread('gt05.png');
trimap = imread('trimap.png');
F_ind = find(trimap == 255);
B_ind = find(trimap == 0);
U_ind = find(trimap == 128);
U_num = length(U_ind);
img_rgb = single(reshape(img,[numel(trimap),3]));
%% pixel feature extraction
% color
F_rgb = img_rgb(F_ind,:);
B_rgb = img_rgb(B_ind,:);
U_rgb = img_rgb(U_ind,:);
% spatical distance
[F_y,F_x] = ind2sub(size(trimap),F_ind); F_yx = single([F_y,F_x]);
[B_y,B_x] = ind2sub(size(trimap),B_ind); B_yx = single([B_y,B_x]);
[U_y,U_x] = ind2sub(size(trimap),U_ind); U_yx = single([U_y,U_x]);
F_s  = [F_y,F_x];
B_s  = [B_y,B_x];
U_s  = [U_y,U_x];
% distance to known region
F_mindist = bwdist(trimap == 255);F_mindist = F_mindist(U_ind);
B_mindist = bwdist(trimap == 0);B_mindist = B_mindist(U_ind);

%% optimize pixel pairs
FB_pairs = zeros(length(U_ind),2);
CB = CheckerboardGenerator(size(trimap));
U_CB = CB(U_ind);
for n = 1:length(U_ind)
    if ~U_CB(n)
        FB_pairs(n,:) = [0,0];
        continue;
    end
    U_s_k = U_s(n,:);
    U_rgb_k = U_rgb(n,:);
    F_mindist_k = F_mindist(n,:);
    B_mindist_k = B_mindist(n,:);
    % options for ga
    FitnessFcn = @(x) MOEADCostFunc(x,F_rgb,B_rgb,U_rgb_k,F_s,B_s,U_s_k,F_mindist_k,B_mindist_k);
    mop = struct('name','Matting','od',3,'pd',2,...
        'domain',[1 size(F_rgb,1);1 size(B_rgb,1)],'func',FitnessFcn);
    
    % run MOEA/D
    [pareto,funccount] = moead( mop, 'popsize', 50, 'niche', 20, 'iteration', 99, 'method', 'ws');
    %fuzzy pixel pair evlauation
    [moead_best_fval,best_ind] = min(FuzzyCostFunc([pareto.parameter]',F_rgb,B_rgb,U_rgb_k,F_s,B_s,U_s_k,F_mindist_k,B_mindist_k));
    x3 = pareto(best_ind).parameter';
    
    % save the optimal pixel pair
    FB_pairs(n,:) = round(x3);
end
%% Neighborhood Grouping
map_global_U_ind =zeros(size(trimap));
map_global_U_ind(U_ind) = 1:length(U_ind);
img_size = size(trimap);
neighbor_range = 4;
boundary = [1,img_size(2),1,img_size(1)];
for n = 1:length(U_ind)
    if U_CB(n)
        continue;
    end
    U_rgb_k = U_rgb(n,:);
    U_yx_k = U_s(n,:);
    F_mindist_k = F_mindist(n,:);
    B_mindist_k = B_mindist(n,:);
    [~,neighbor_global_ind] = getNeighborhood(U_yx_k(2),U_yx_k(1),neighbor_range,boundary,img_size,'ignore');
    neighbor_ind = map_global_U_ind(neighbor_global_ind{1});
    neighbor_ind(neighbor_ind==0) = [];
    bw = U_CB(neighbor_ind);
    neighbor_pair = FB_pairs(neighbor_ind(bw),:);
    neighbor_pair = unique(neighbor_pair,'rows');
    fitness = FuzzyCostFunc(neighbor_pair,F_rgb,B_rgb,U_rgb_k,F_yx,B_yx,U_yx_k,F_mindist_k,B_mindist_k);
    [~,best_neighbor_ind] = min(fitness);
    FB_pairs(n,:) = neighbor_pair(best_neighbor_ind,:);
end
for n = 1:length(U_ind)
    if ~U_CB(n)
        continue;
    end
    U_rgb_k = U_rgb(n,:);
    U_yx_k = U_s(n,:);
    F_mindist_k = F_mindist(n,:);
    B_mindist_k = B_mindist(n,:);
    [~,neighbor_global_ind] = getNeighborhood(U_yx_k(2),U_yx_k(1),neighbor_range,boundary,img_size,'ignore');
    neighbor_ind = map_global_U_ind(neighbor_global_ind{1});
    neighbor_ind(neighbor_ind==0) = [];
    bw = U_CB(neighbor_ind);
    neighbor_pair = FB_pairs(neighbor_ind(bw),:);
    neighbor_pair = unique(neighbor_pair,'rows');
    fitness = FuzzyCostFunc(neighbor_pair,F_rgb,B_rgb,U_rgb_k,F_yx,B_yx,U_yx_k,F_mindist_k,B_mindist_k);
    [~,best_neighbor_ind] = min(fitness);
    FB_pairs(n,:) = neighbor_pair(best_neighbor_ind,:);
end
[alpha,fitness] = FB2alpha(FB_pairs,img,trimap,0);
imwrite(alpha,'alpha.png');