function [vec] = extract_blks(Mat)
vec=[];
    for j=1:size(Mat,2)
        len=size(Mat,1)/size(Mat,2); % split matrix into blocks
        vec=[vec; Mat(j*len-(len-1):j*len,j)]; 
    end
end

