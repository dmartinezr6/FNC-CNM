% Computes some measurements over a network using some BCT functions
%
% M = computeBCTMeasures(X, binary)
%
% Parameters: 
%
%    M      = the matriz with the network information 
%    binary = indicates if the matrix is a binary matrix 1 = binary or 0 =
%             not binary
%
function M = computeBCTMeasures(X, binary)
    M.degree = degrees_und(X);
    M.strength = strengths_und(X);                                     
    M.eigenvector = eigenvector_centrality_und(X);
    if sum(any(X)) > 0
        M.modularity = modularity_und(X);
    else
        M.modularity = zeros(length(X),1);
    end
    
    if binary == 1
        M.clustering = clustering_coef_bu(X);
        M.transitivity = transitivity_bu(X);
        M.localefficiency = efficiency_bin(X,1);
        M.efficiency = efficiency_bin(X);
        M.distance = distance_bin(X);
        [lambda, efficiency, ecc, radius, diameter] = charpath(M.distance);
        M.charpath = {lambda, efficiency,ecc,radius, diameter};
        if sum(any(X)) > 0
            M.richclub = rich_club_bu(X);
        else
            M.richclub = zeros(length(X),1);
        end
        
        M.betweenness = betweenness_bin(X);
    elseif binary == 0
        M.clustering = clustering_coef_wu(X);
        M.transitivity = transitivity_wu(X);
        M.efficiency = efficiency_wei(X);
        M.localefficiency = efficiency_wei(X,1);
        M.distance = distance_wei(X);
        [lambda, efficiency, ecc, radius, diameter] = charpath(M.distance);
        M.charpath = {lambda, efficiency,ecc,radius, diameter};
        if sum(any(X)) > 0
            M.richclub = rich_club_wu(X);
        else
            M.richclub = zeros(length(X),1);
        end
        M.betweenness = betweenness_wei(X);
    else
        error('binary must be either 1 = binary matrix or 0 = weigthed matrix');
    end
end
