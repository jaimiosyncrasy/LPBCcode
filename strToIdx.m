% helper function
% returns indices where input str elements match nodenames
function idx=strToIdx(inputStr,nodeNames)
    idx=-1; % initialize
    a=strsplit(inputStr,','); % split string of nodes by comma delimiter, yielding cell array
    idx=find(ismember(nodeNames,a)); % return indices where a matches with nodeNames
    if isempty(idx)
        disp(strcat('error, could not match{ ',inputStr,' with load names'));
    end
end