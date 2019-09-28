function [val_w,val_cf,team,threshold] = assign(num_div,dim_f)
  type = 1; %1代表平面，2代表凸平面，其它为凹平面
  val_f  = weight(num_div,dim_f,type);
  val_w  = 1./val_f;
  [val_cf,team,threshold] = teamset(num_div,dim_f);
end

%% ----------------------权重设计----------------------------------    
function val_p = weight(num_p,dim_f,type)
    %----------------------计算权重分段数目---------------------------------
    N = ceil((num_p*prod(dim_f-1))^(1/(dim_f-1)))-dim_f+1;
    while nchoosek(N+dim_f-1,dim_f-1) < num_p
        N = N+1;
    end
    num_p = nchoosek(N+dim_f-1,dim_f-1);   
    %----------------------空间曲面布点-------------------------------------
    w_list = nchoosek(1:N+dim_f-1,dim_f-1)';
    val_p = zeros(dim_f,num_p);
    val_p(1,:)= w_list(1,:);
    for i = 2:dim_f-1
        val_p(i,:)= w_list(i,:)-w_list(i-1,:);
    end
    val_p(dim_f,:) = N+dim_f-w_list(dim_f-1,:);
    val_p = val_p-1;
    if type == 1      %----------------------平面布点-----------------------
        val_p = val_p./max(max(val_p));
        val_p(val_p==0) = 10^-100;
    elseif type == 2   %---------------------单位空间凸球面布点--------------
        for i = 0:N
            val_p(val_p==i)= sin(0.5*i*pi/N);
        end
        val_p(val_p==0) = 10^-100;
        for i = 1:num_p
            val_p(:,i) = val_p(:,i)./norm(val_p(:,i));
        end
    else               %---------------------单位空间凹球面布点--------------
        for i = 0:N
            val_p(val_p==i)= 1-cos(0.5*i*pi/N);
        end
        val_p(val_p==0) = 10^-100;
    end
end
 
%% ---------------------权重分组-----------------------------------
function [val_cp,team,threshold] = teamset(num_div,dim_f)
    threshold = 1;
    val_cp = weight(round(sqrt(num_div)),dim_f,2);
    val_p  = weight(num_div,dim_f,2);
    num_cp    = size(val_cp,2);
    num_p     = size(val_p,2);
    team      = cell(num_cp,1);
    loc_team = zeros(1,num_p);
    val_team = zeros(1,num_p);
    for i = 1:num_p
        [val,loc]    = max(val_p(:,i)'*val_cp);
        loc_team(i) = loc;
        val_team(i) = val;
    end
    for i=1:num_cp
        list      = find(loc_team==i);
        [~,loc]   = max(val_team(list));
        [val,~]   = min(val_team(list));
        threshold = min(threshold,val);
        tmp       = list(loc);
        list(loc) = list(1);
        list(1)   = tmp;
        team{i}   = list;
    end
%     %--------------设置每个权重的邻居点-------------------------------------
%     dis_p = val_p'*val_p;
%     neibor  = zeros(num_p);
%     for i = 1:num_p
%         [~,neibor(i,:)] = sort(dis_p(i,:),'descend');
%     end
%     neibor(:,1) = [];
end

% %% ----------------------画图---------------------------------------------
% if dim_f == 2 
%     ezplot('sqrt(1-t^2)',[0,1]);  %基于凸平面
% %         ezplot('1-sqrt(1-(t-1).^2)',[0,1]);  %基于凹平面
% %         ezplot('1-t',[0,1]);        %基于平面
%     hold on;
%     plot(val_p(1,:),val_p(2,:),'b.'); 
%     hold off;
%     xlabel('子函数f1','FontWeight','bold');
%     ylabel('子函数f2','FontWeight','bold');
%     title('遗传算法（Popsize:100,Maxgen:250）','FontWeight','bold');
%     legend('Even Design',1);
%     axis([0 1 0 1]);
%     grid on;
%     box on;
% else
%     ezmesh('cos(pi*x1./2).*cos(pi*x2./2)','cos(pi*x1./2).*sin(pi*x2./2)','sin(pi*x1./2)',[0,1],[0,1]);%基于凸平面
% %     ezmesh('x1','x2','1-x1-x2',[0,1],[0,1]); %基于平面
%     hold on;
%     plot3(val_p(1,:),val_p(2,:),val_p(3,:),'b.'); 
%     hold off;
%     xlabel('子函数f1','FontWeight','bold');
%     ylabel('子函数f2','FontWeight','bold');
%     zlabel('子函数f3','FontWeight','bold');
%     title('遗传算法（Popsize:100,Maxgen:250）','FontWeight','bold');
%     legend('Even Design',1);
%     axis([0 1 0 1 0 1]);
%     grid on;
%     box on;
% end