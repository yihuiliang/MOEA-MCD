function subp=init_weights(popsize, niche, objDim)
% init_weights function initialize a pupulation of subproblems structure
% with the generated decomposition weight and the neighbourhood
% relationship.
    subp=[];
    %% assign weight
%     for i=0:popsize
%         if objDim==2
%             p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
%             weight=zeros(2,1);
%             weight(1)=i/popsize;
%             weight(2)=(popsize-i)/popsize;
%             p.weight=weight;
%             subp=[subp p];
%         elseif objDim==3
%         %TODO
%             p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
%             a=rand()/2*pi;
%             b=asin(rand());
%             x=cos(a).*cos(b);
%             y=sin(a).*cos(b);
%             z=sin(b);
%             p.weight= [x;y;z];
%             subp=[subp p];
%         end
%     end
      val_w = weight(popsize,objDim,1);
      for i=1:popsize
          p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
          p.weight= val_w(:,i);
          subp=[subp p];
      end

% weight = lhsdesign(popsize, objDim, 'criterion','maximin', 'iterations', 1000)';
% p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
% subp = repmat(p, popsize, 1);
% cells = num2cell(weight);
% [subp.weight]=cells{:};

    %Set up the neighbourhood.
    leng=length(subp);
    distanceMatrix=zeros(leng, leng);
    for i=1:leng
        for j=i+1:leng
            A=subp(i).weight;B=subp(j).weight;
            distanceMatrix(i,j)=(A-B)'*(A-B);
            distanceMatrix(j,i)=distanceMatrix(i,j);
        end
        [s,sindex]=sort(distanceMatrix(i,:));
        subp(i).neighbour=sindex(1:niche)';
    end
   
end