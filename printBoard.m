% Copyright @2017 MIT License - Author - Garrett Kaiser & Tim Sheppard
% See the License document for further information
function printBoard( boardReadable )
% Print the visually readable board
% boardReadable = 2 x 27 matrix [bar,homeUser,1 to 24,homeAgent]
% 1st Row - agentCount
% 2nd Row - userCount
% Prints something like: 
%  Index | Bar|   0|   1|   2|   3|   4|   5|   6|   7|   8|   9|  10|  11|  12|  13|  14|  15|  16|  17|  18|  19|  20|  21|  22|  23|  24|  25|
%        |----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----|
%     AI |   0| NaN|   2|   0|   0|   0|   0|   0|   0|   0|   0|   0|   0|   5|   0|   0|   0|   0|   3|   0|   5|   0|   0|   0|   0|   0|   0|
%   User |   0|   0|   0|   0|   0|   0|   0|   5|   0|   3|   0|   0|   0|   0|   5|   0|   0|   0|   0|   0|   0|   0|   0|   0|   0|   2| NaN|

Index = 0:1:25; 

fprintf('Index | Bar|') 
fprintf('%4d|', Index)

fprintf('\n      |%s----|\n',repmat('----+',1,26))

fprintf('   AI |') 
fprintf('%4d|', boardReadable(1,:)) 

fprintf('\n User |') 
fprintf('%4d|', boardReadable(2,:)) 
fprintf('\n\n')

end % function 

