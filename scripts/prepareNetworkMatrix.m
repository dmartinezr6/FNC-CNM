% This function converts the values of the given matrix into the interval
% [0 1] while change the non-neuronal values to 0. Also, it could takes a
% threshold parameter to keep or eliminate a value in the matrix.
%
% function X = prepareNetworkMatrix( M, kind, varargin ) return a converted
%     X matrix from the M matrix of the kind considering an threshold
% 
% Parameters:
%
%    M         = The square matrix of values to convert
%    kind      = The kind of conversion depending on the correlation, 
%                kind = DC or NMI to map from [0 N] to [0 1]
%                kind = Pearson to map from [-1 1] to [0 1] 
%    threshold = A value between [0 1] to keep or eliminate (convert to 0)
%                the values in the matrix
%    binary    = return a binary matrix after the threshold operation 1
%                binarize, 0 do not binarize
% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

function X = prepareNetworkMatrix( M, kind, varargin )
    threshold = 0.0;
    % review the optional parameters
    if nargin > 2
        if nargin == 3
            threshold = varargin{1};
        elseif nargin == 4
            threshold = varargin{1};
            binary = varargin{2};
        else
            error('prepareNetworkMatrix receives only one optional parameter');
        end
    end
    if size(M,1) ~= size(M,2)
        error('M must be a square matrix');
    end
    tam = length(M);
    X = zeros(size(M));
    % review the kind of conversion
    if strcmp(kind,'DC') == 1 || strcmp(kind,'NMI') == 1
        for i = 1:tam
            for j = i:tam 
                % if it is no neuronal activity map to 0
                if M(i,j) ~= -1.1
                    % if actual value if greater or equal to the threshold
                    if M(i,j) >= threshold 
                        % if result matrix if binary
                        if binary == 1
                            X(i,j) = 1;
                        else
                            X(i,j) = M(i,j);
                        end
                    end
                end 
            end
        end
    elseif strcmp(kind,'Pearson') == 1
        for i = 1:tam
            for j = i:tam 
                % if it is no neuronal activity map to 0
                if M(i,j) ~= -1.1
                    % if actual absolut value if greater or equal to the threshold
                    if abs(M(i,j)) >= threshold 
                        % if result matrix if binary
                        if binary == 1
                            X(i,j) = 1;
                        else
                            X(i,j) = abs(M(i,j));
                        end
                    end
                end 
            end
        end
    else
        error('kind values must be DC or NMI for [0 N] to [0 1] mapping or be Pearson for [-1 1] to [0 1] mapping.')
    end
end