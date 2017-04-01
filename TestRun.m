% Copyright @2017 MIT License - Author - Harshal Priyadarshi, Tim Sheppard
% See the License document for further information
function [favorability] = TestRun( V_ih, V_ho, boardReadable, board, dice, userChance )
% V_ho -> weight from hidden layer to output layer
% V_ih -> weight from input layer to hidden layer
% boardReadable -> 2x27 board in readable form
% board -> 198 x 1 neural net board
% userChance = 0 as we are simulating agent
% dice -> the input vector of dice move 

favorability = []; 
moveTemp = [];
possibleMoves = [];
possibleMoves = get_possible_moves(dice,boardReadable,board,moveTemp,possibleMoves,userChance);

if (size(possibleMoves) ~= 0)
	possibleMoves = unique(possibleMoves,'rows');
	favorability = zeros(size(possibleMoves,1),size(possibleMoves,2) + 1);
	favorability(:,2:size(possibleMoves,2) + 1) = possibleMoves;
	for i = 1:size(possibleMoves,1)
		boardTemp = generateBoardFromMove(possibleMoves(i,:),board,false);
		evalVal = evaluateBoardNN(boardTemp,V_ih,V_ho);
		favorability(i,1) = evalVal;
	end
	% sort the content
	if(userChance == 1)
		favorability = sortrows(favorability,1); % sorts in ascending order
	else
		favorability = sortrows(favorability,-1);% sorts in descending order
	end
end

end % function

