% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TD gammon player - Copyrights @2015 -Harshal Priyadarshi

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
% lambda     -> The decay rate = 0.9
% discount   -> the discounting factor = 1
% y_hidden   -> activation value for the hidden node(50 x 1)
% y_out      -> activation value for the output node(1 x 1)
% board      -> The board state for the NN input (198 x 1 vector)
% die        -> the random roll value of the two die (1 x 2 vector)
% move       -> All possible moves for given die (k x 8 matrix)
%               k - number of possible moves
%               move(i,:) = [start_first,stop_first,start_second,stop_second,rest 2 moves for double]
% userChance -> 0 --> AI's Turn (AI we are training)
%               1 --> Opponents Turn (temporary opponent playes bot optimal and suboptimal for training)
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
% nnAI   = {V_InHidden,V_HiddenOut,e_InHidden,e_HiddenOut};
% nnUser = {V_InHidden,V_HiddenOut,e_InHidden,e_HiddenOut};
alpha  = 0.2;
lambda = 0.8;
% winner Count
agentWins = 0;
userWins = 0;

%% train through RL 
% play against optimal opponent 2/3 of the games
% play against suboptimal opponent 1/3 of the games
for epoch = 1:10000
    fprintf('episode # %d\n',epoch);
    userChance = randi([0,1]);
    boardPresent = generateInitialBoard(userChance);
    boardReadable = generateReadableBoard(boardPresent);
    hasGameEnded = false;
    numTurns = 1;
    
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

        % make a move
        if((mod(epoch,3)==2) && userChance)
            % 1/3 of games the opponent will choose random moves
            if((mod(epoch,6)==2))
                randomIndex = randi(size(possibleMoves,1));
                move = possibleMoves(randomIndex,:);
                boardNext = generateBoardFromMove(move,boardPresent,false);
                evalNext = evaluateBoardNN(boardNext,V_InHidden,V_HiddenOut);
            else
                [evalNext,boardNext] = randomAction(possibleMoves,boardPresent,V_InHidden,V_HiddenOut,userChance);
            end
        else
            % use optimal move
            [evalNext,boardNext] = bestAction(possibleMoves,boardPresent,V_InHidden,V_HiddenOut,userChance);
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
%         if(~userChance)
            if(hasGameEnded)
                outputNext    = reward;
                outputPresent = evalPresent;
            else
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
%         end
        
        % next turn
        userChance = ~userChance;
        numTurns = numTurns + 1;
        
%         disp('Board State at present:');
%         printBoard(boardReadable);
%         disp('press "enter" to continue');pause;
        
    end
    
    fprintf('Agent/User = [%d, %d]\n', agentWins,userWins);
    % save the data against system shutdown
    if(mod(epoch,500)== 1)
        dlmwrite('VinHide.mat',V_InHidden,'delimiter',' ','precision','%10.6g');
        dlmwrite('VhideOut.mat',V_HiddenOut,'delimiter',' ','precision','%10.6g');
        dlmwrite('eInHide.mat',e_InHidden,'delimiter',' ','precision','%10.6g');
        dlmwrite('eHideOut.mat',e_HiddenOut,'delimiter',' ','precision','%10.6g');
        dlmwrite('agentUser.mat',[agentWins,userWins],'delimiter',' ','precision','%10.6g');
    end
    
end



