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

