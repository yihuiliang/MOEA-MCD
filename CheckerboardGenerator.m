function [ img ] = CheckerboardGenerator( img_size )
%CHECKERBOARDGENERATOR Summary of this function goes here
%   Detailed explanation goes here
    img = false(img_size);
    odd_ind = 1:2:img_size(1);
    even_ind = 2:2:img_size(1);
    for i = 1:img_size(2)
        if mod(i,2)==0
            img(odd_ind,i) = true;
        else
            img(even_ind,i) = true;
        end
    end

end

