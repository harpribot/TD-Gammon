% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
function board = generateBoardFromMove(move,board,nextMoveMyMove)
%Generate the board vector for the given move

% find the present user and agent numbers on the bar or borne off status
agentOnBar = 2 * board(195);
userOnBar = 2 * board(196);
agentBorneOff = 15 * board(197);
userBorneOff = 15 * board(198);

% to adjust to the shape of move to be 1*8 vector;
if(size(move,2) < 8)
    move = [move,zeros(1,8 - size(move,2))];
end
% reshape the move to proper shape
move = reshape(move,[2,4])';
% check as to whose move
if(board(193)==1)
    % present move is for the agent
    player = 0;
    if(nextMoveMyMove == false)
        % make the next board user's chance
        board(193) = 0;
        board(194) = 1;
    end
else
    % present move is for the user
    player = 1;
    if(nextMoveMyMove == false)
        % make the next board agent's chance
        board(193) = 1;
        board(194) = 0;
    end
end
% update the board for each move
for dice = 1:size(move,1)
    startPosition = move(dice,1);
    endPosition = move(dice,2);
    % in case there is no doubling '0' is fed in the start and end position
    if(startPosition == 0 && endPosition == 0)
        break;
    end
    if(player == 0)
        if(startPosition ~= -1)% the checker is not on bar
            startFirstNeuron = (startPosition - 1) * 8 + 1;
            startLastNeuron  = (startPosition - 1) * 8 + 4;
        end
        if(endPosition ~= 25)  % the checker does not bear off
            endFirstNeuron   = (endPosition - 1) * 8 + 1;
            endLastNeuron    = (endPosition - 1) * 8 + 4;
        end
        % remove the checker from original position
        if(startPosition ~= -1)
            numCheckers = sum(board(startFirstNeuron:startLastNeuron)) +...
                              board(startLastNeuron);% last neuron double val
            numCheckers = numCheckers - 1;
            neuronAgent = zeros(4,1);
            if(numCheckers <= 3)
                neuronAgent(1:numCheckers) = 1;
            else
                neuronAgent(1:3) = 1;
                neuronAgent(4) = 0.5 * (numCheckers - 3);
            end
            board(startFirstNeuron:startLastNeuron) = neuronAgent;
        % update the count due to re-entering
        else
            agentOnBar = agentOnBar - 1;
        end
        % add the checker to the new position (no bearing off)- Takes into
        % consideration the entering of checkers on the bar
        if(endPosition ~= 25)
            numCheckers = sum(board(endFirstNeuron:endLastNeuron)) +...
                              board(endLastNeuron);% last neuron double val
            numCheckers = numCheckers + 1;
            neuronAgent = zeros(4,1);
            if(numCheckers <= 3)
                neuronAgent(1:numCheckers) = 1;
            else
                neuronAgent(1:3) = 1;
                neuronAgent(4) = 0.5 * (numCheckers - 3);
            end
            board(endFirstNeuron:endLastNeuron) = neuronAgent;
            
            % consider Hits as well
            numCheckersOpposition = sum(board(...
                endFirstNeuron + 4:endLastNeuron + 4)) + ...
                board(endLastNeuron + 4);
            if(numCheckersOpposition == 1)
                board(endFirstNeuron + 4:endLastNeuron + 4) = 0;
                userOnBar = userOnBar + 1;
            end   
        % for the bearing off
        else 
            agentBorneOff = agentBorneOff + 1;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    else
        if(startPosition ~= -1)% the checker is not on bar
            startFirstNeuron = (startPosition - 1) * 8 + 5;
            startLastNeuron  = (startPosition - 1) * 8 + 8;
        end
        if(endPosition ~= 0)  % the checker does not bear off
            endFirstNeuron   = (endPosition - 1) * 8 + 5;
            endLastNeuron    = (endPosition - 1) * 8 + 8;
        end
        % remove the checker from original position
        if(startPosition ~= -1)
            numCheckers = sum(board(startFirstNeuron:startLastNeuron)) +...
                              board(startLastNeuron);
            numCheckers = numCheckers - 1;
            neuronAgent = zeros(4,1);
            if(numCheckers <= 3)
                neuronAgent(1:numCheckers) = 1;
            else
                neuronAgent(1:3) = 1;
                neuronAgent(4) = 0.5 * (numCheckers - 3);
            end
            board(startFirstNeuron:startLastNeuron) = neuronAgent;
        % update count due to re-entering
        else
            userOnBar = userOnBar - 1;
        end
        % add the checker to the new position (no bearing off)- Takes into
        % consideration the entering of checkers on the bar
        if(endPosition ~= 0)
            numCheckers = sum(board(endFirstNeuron:endLastNeuron)) + ...
                              board(endLastNeuron);
            numCheckers = numCheckers + 1;
            neuronAgent = zeros(4,1);
            if(numCheckers <= 3)
                neuronAgent(1:numCheckers) = 1;
            else
                neuronAgent(1:3) = 1;
                neuronAgent(4) = 0.5 * (numCheckers - 3);
            end
            board(endFirstNeuron:endLastNeuron) = neuronAgent;
            
            % consider Hits as well
            numCheckersOpposition = sum(board(...
                endFirstNeuron - 4:endLastNeuron - 4)) +...
                board(endLastNeuron - 4);
            if(numCheckersOpposition == 1)
                board(endFirstNeuron - 4:endLastNeuron - 4) = 0;
                agentOnBar = agentOnBar + 1;
            end
        % for the bearing off
        else 
            userBorneOff = userBorneOff + 1;
        end
    end
end

% update the board due to bearing off and due to hits
board(195) = 0.5 * agentOnBar;
board(196) = 0.5 * userOnBar;
board(197) = agentBorneOff/15;
board(198) = userBorneOff/15;
end
