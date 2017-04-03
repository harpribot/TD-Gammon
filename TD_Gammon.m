% Copyright @2017 MIT License
% See the License document for further information
% Author - Harshal Priyadarshi
% Revised - Garrett Kaiser 4/2/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TD gammon player

% V_InHidden -> weight vector of size 50 * 199---- V_InHidden(j,i) is the
%               weight between input node "i" and hidden node "j"
%               199th input node = bias(magnitude = 1)
%               Initialized randomly initially.
% V_HiddenOut-> weight vector of size 1  *  51---- V_HiddenOut(1,j) is the
%               weight between hidden node "j" and output node
%               51th hidden node = bias(magnitude = 1)
%               Initialized randomly initially.
% e_InHidden -> eligibility trace vector of same size as V_InHidden.
%               Initialized as 0 initially.
% e_HiddenOut-> eligibility trace vector of same size as V_HiddenOut.
%               Initialized as 0 initially.
% alpha      -> The learning rate = 0.7
% lambda     -> The decay rate = 0.8
% y_hidden   -> activation value for the hidden node(50 x 1)
% y_out      -> activation value for the output node(1 x 1)
% board      -> The board state for the NN input (198 x 1 vector)
% die        -> the random roll value of the two die (1 x 2 vector)
% move       -> All possible moves for given die (k x 8 matrix)
%               k - number of possible moves
%               move(i,:) = 
%                   [start_first,stop_first,start_second,stop_second,rest 2 moves for double]
% userChance -> 0 --> AI's Turn (AI we are training)
%               1 --> Opponents Turn
% board nomenclature -> The board numbering starts from user's home. Agent
%                       moves anticlockwise while user moves clockwise when
%                       seen from the home side
% 
%%
close all; clear all; clc;
%% Initialize
rng(mod((todatenum(cdfepoch(now)))*(10.^11),(2.^32)));
% initialize weights(V) and eligibility trace(e)
V_InHidden  = rand(50,199)/10;
V_HiddenOut = rand(1,51)/10;
e_InHidden  = zeros(50,199);
e_HiddenOut = zeros(1,51);
alpha  = 0.2;
lambda = 0.8;
% winner Count
agentWins = 0;
userWins = 0;

%% train through RL 
MAX_TRAIN = 120000;
for epoch = 1:MAX_TRAIN
    fprintf('Game # %d\n',epoch);
    userChance = randi([0,1]);
    boardPresent = generateInitialBoard(userChance);
    boardReadable = generateReadableBoard(boardPresent);
    hasGameEnded = false;
    numTurns = 1;
    evalStart = evaluateBoardNN(boardPresent,V_InHidden,V_HiddenOut);
    
    % simulate the game and run RL
    while(hasGameEnded == false)
        % make present board evaluation
        evalPresent = evaluateBoardNN(boardPresent,V_InHidden,V_HiddenOut);
        
        % roll the die
        dice = rollDice();
      
        % the possible moves generated from backgammon model
        moveTemp = [];
        possibleMoves = [];
        possibleMoves = get_possible_moves(dice,boardReadable,boardPresent,moveTemp,possibleMoves,userChance);

        % choose move
        %if((mod(epoch,3)==2) && userChance)
        if(userChance && evalStart <= 0.45 && ~isempty(possibleMoves))
            %if((mod(epoch,6)==2))
            if(evalStart <= 0.30)
                % completely random
                randomIndex = randi(size(possibleMoves,1));
                move = possibleMoves(randomIndex,:);
                boardNext = generateBoardFromMove(move,boardPresent,false);
                evalNext = evaluateBoardNN(boardNext,V_InHidden,V_HiddenOut);
            else
                % random action from top portion of evaluations
                [evalNext,boardNext] = ...
                    randomAction(possibleMoves,boardPresent,V_InHidden,V_HiddenOut,userChance);
            end
        else
            % optimal move
            [evalNext,boardNext] = ...
                bestAction(possibleMoves,boardPresent,V_InHidden,V_HiddenOut,userChance);
        end
        
        % Check if this is the end of the game
        reward = 0;
        boardPresent = boardNext;
        boardReadable = generateReadableBoard(boardPresent);
        if(boardReadable(2,2) == 15)
            hasGameEnded = true;
            userWins = userWins + 1;
            reward = 0;
        elseif(boardReadable(1,27) == 15)
            hasGameEnded = true;
            agentWins = agentWins + 1;
            reward = 1;
        end

        % Make weight update using backprop
        if(numTurns > 1)
            if(hasGameEnded)
                % if the User won error = (0 - user's eval) penalize based on magnitude of loss
                % if the   AI won error = (1 - ai's eval)   reward based on magnitude of win
                outputNext    = reward;
                outputPresent = evalPresent;
            else
                % error = change is eval the goal is that the opponents
                % eval(evalNext) will be less than your eval(evalPresent)
                outputNext    = evalNext;
                outputPresent = evalPresent;
            end
            [V_HiddenOut,V_InHidden,e_HiddenOut,e_InHidden] = ...
                BackPropogation(V_HiddenOut,...
                                V_InHidden,...
                                e_HiddenOut,...
                                e_InHidden,...
                                outputNext,...
                                outputPresent,...
                                alpha,lambda,...
                                boardNext);
        end
        
        % next turn
        userChance = ~userChance;
        % if ( (mod(numTurns,50) == 0) )
        %     fprintf('Number of turns: %d time: %s \n', numTurns, datestr(now,'HH:MM:SS PM'));
        % end
        numTurns = numTurns + 1;
    end
    
    fprintf('Agent/User = [%d, %d]  (Total turns = %d)\n', agentWins,userWins,numTurns);
    
    % save the data every 1000 or at the end to play against 
    if ( (mod(epoch,1000) == 0) || (epoch == MAX_TRAIN) )
        filename = 'trained_weights';
        wins_AI_User = [agentWins,userWins];
        epochs_trained = epoch;
        date_trained = datetime;
        V_InHide  = V_InHidden;
        V_HideOut = V_HiddenOut;
        e_InHide  = e_InHidden;
        e_HideOut = e_HiddenOut;
        save(filename, 'wins_AI_User', 'date_trained', 'epochs_trained', 'V_InHide' , 'V_HideOut', 'e_InHide', 'e_HideOut');
    end
    
end



