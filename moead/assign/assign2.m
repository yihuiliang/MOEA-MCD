function [num_p,val_w,val_cp,team] = assign(num_div,dim_f)
    [num_p,val_w,val_p] = weight(num_div,dim_f);
    if dim_f == 2
        num_group          = 15;
    elseif dim_f ==3
        num_group          = 7;
    else
        num_group          = 4;
    end
    [num_cp,val_cw,val_cp] = weight(num_group,dim_f);
    team                   = group(val_cp,val_p);    
    clear num_cp val_cw val_p num_group num_div dim_f;  
end

function [num_pop,val_w,val_p] = weight(num_div,dim_f)
    val_rad         = radvalue(num_div,dim_f);
    num_pop         = size(val_rad,2);
    val_w           = ones(dim_f,num_pop);
    val_p           = zeros(dim_f,num_pop);
    for i = 1:dim_f-1
        val_p(1,:)  = cos(val_rad(1,:));
        val_w(1,:)  = 1./val_p(1,:);
    end
    for i = 2:dim_f-1
        val_p(i,:)  = ((val_p(i-1,:).*sin(val_rad(i-1,:))).*cos(val_rad(i,:)))./cos(val_rad(i-1,:));
        val_w(i,:)  = 1./val_p(i,:);
    end
    val_p(dim_f,:)  = (val_p(dim_f-1,:).*sin(val_rad(dim_f-1,:)))./cos(val_rad(dim_f-1,:));
    val_w(dim_f,:)  = 1./val_p(dim_f,:);
    clear dim_f i val_rad;
end
    

function val_rad = radvalue(num_div,dim_f)
    unit        = pi/(2*num_div);
    if dim_f   == 2
        val_rad = radunif(1,unit);
    elseif dim_f > 2
        rad     = radunif(1,unit);
        val_rad = radget(rad,unit,dim_f);
        clear rad;
    else
        disp('The dimension of mutiobject is wrong!');
    end
    clear num_div dim_f;
end

function radian = radget(rad,unit,dim_f)
    if dim_f > 2
        [dim_rad,len_rad] = size(rad);
        fix_len           = round((len_rad^2)/2);
        radian            = zeros(dim_rad+1,fix_len);
        reg               = 1;
        radius            = prod(sin(rad),1);
        for i = 1:len_rad
            tmp_rad                             = radunif(radius(i),unit);
            tmp_len                             = length(tmp_rad);
            radian(1:dim_rad,reg:reg+tmp_len-1) = repmat(rad(:,i),[1,tmp_len]);
            radian(dim_rad+1,reg:reg+tmp_len-1) = tmp_rad;
            reg                                 = reg+tmp_len;
            clear tmp_rad;
        end
        radian(:,reg:fix_len) = [];
        clear rad dim_rad len_rad reg i tmp_len fix_len;
        dim_f                   = dim_f-1;
        if dim_f > 2;
            radian = radget(radian,unit,dim_f);  
        else
            clear dim_f unit;
        end
    end
end
  

function rad = radunif(radius,unit)
    num_rad  = ceil(radius*pi/(2*unit));
    rad      = pi*(1:2:2*num_rad)/(4*num_rad);  
    clear radius unit num_rad;
end
 

function team = group(val_cp,val_p)
    num_cp    = size(val_cp,2);
    num_p     = size(val_p,2);
    team      = cell(num_cp,1);
    loc_group = zeros(1,num_p);
    val_group = zeros(1,num_p);
    for i = 1:num_p
        val_dis      = sum((repmat(val_p(:,i),[1,num_cp])-val_cp).^2,1);
        [val,loc]    = min(val_dis);
        loc_group(i) = loc;
        val_group(i) = val;
    end
    for i=1:num_cp
        list      = find(loc_group==i);
        [val,loc] = min(val_group(list));
        tmp       = list(loc);
        list(loc) = list(1);
        list(1)   = tmp;
        team{i}   = list;
    end
    
    clear val_cp val_p num_cp num_p loc_group val_dis val loc list tmp i;
end