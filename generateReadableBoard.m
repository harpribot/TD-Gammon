% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
function boardReadable = generateReadableBoard( board )
% Generate the visually readable board from the input vector type board
% boardReadable = 2 x 27 matrix [bar,homeUser,1 to 24,homeAgent]
% 1st Row - agentCount
% 2nd Row - userCount
boardReadable = zeros(2,27);
for i = 1:27
    % On the bar
    if(i == 1)
        boardReadable(1,i) = 2 * board(195);
        boardReadable(2,i) = 2 * board(196);
    % Home state of the user
    elseif(i == 2)
        boardReadable(1,i) = NaN;
        boardReadable(2,i) = 15 * board(198);
    % Home state of the agent
    elseif(i == 27)
        boardReadable(1,i) = 15 * board(197);
        boardReadable(2,i) = NaN;
    % For checkers on the board
    else
        iBoard = i - 2;
        boardReadable(1,i) = sum(...
            board((8 * (iBoard - 1) + 1) : (8 * (iBoard - 1) + 3))) + ...
            board(8 * (iBoard - 1) + 4) * 2;
        boardReadable(2,i) = sum(...
            board((8 * (iBoard - 1) + 5) : (8 * (iBoard - 1) + 7))) + ...
            board(8 * (iBoard - 1) + 8) * 2;
    end
end


end

