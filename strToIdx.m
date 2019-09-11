% helper function
% returns indices where input str elements match nodenames
function idx=strToIdx(inputStr,nodeNames)
    idx=-1; % initialize
    a=strsplit(inputStr,','); % split string of nodes by comma delimiter, yielding cell array
    idx=[];
    for i=1:length(a)
        foo=find(ismember(nodeNames,a(i))); % return indices where a matches with nodeNames
        if isempty(foo)
            disp(strcat('error, could not match{ ',inputStr,' with load names'));
        end
        idx=[idx foo];
    end
end