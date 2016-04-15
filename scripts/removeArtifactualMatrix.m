% This function eliminates the subjects with functional matrix without 
% meaningful vaules, i.e. the matrix with only non neuronal values
% 
% function [X,S] removeMatrix(M, kind) return a X matrix whose elements are
%     of Neurological values
% 
% Parameters:
%
%    M         = The Matrix of square matrixes to remove
% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
function [X,S] = removeArtifactualMatrix(M)
    numSubjects = length(M);
    S = [];
    ne = 0;
    for s=1:numSubjects
        X_s = M(:,:,s);
        tam = length(X_s);
        for i = 1:tam
            for j = i:tam 
                % if it is no neuronal activity map to 0
                if X_s(i,j) == -1.1
                    X_s(i,j) = 0;
                end 
            end
        end
        if(sum(any(X_s)) ~= 0 )
            X(:,:,s-ne) = X_s;
        else
            ne = ne +1;
            S(ne) = s;
        end
    end
end