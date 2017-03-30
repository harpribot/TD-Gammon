% Copyright @2017 MIT License - Author - Garrett Kaiser
% See the License document for further information
function printMoveEvaluations(table)
    % original evaluations are the opponents probability of winning that
    % you try to minimize. For printing this is flip to show your
    % probability of winning.
    table(:,1) = 1-table(:,1);
    fprintf('\tEval\tMove\n');
    fprintf('\t%.4f\t[%3d ->%3d    %3d ->%3d    %3d ->%3d    %3d ->%3d ]\n', table.');
    fprintf('\n');
end
