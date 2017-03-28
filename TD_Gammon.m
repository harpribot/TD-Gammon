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
% userChance-> 0 --> Robot's Chance
%              1 --> User's Chance
% board nomenclature -> The board numbering starts from user's home. Agent
%                       moves anticlockwise while user moves clockwise when
%                       seen from the home side
% 

% initialize weights(V) and eligibility trace(e)
V_InHidden  = rand(50,199)/10;
V_HiddenOut = rand(1,51)/10;
e_InHidden  = zeros(50,199);
e_HiddenOut = zeros(1,51);
alpha = 0.2;
lambda = 0.9; % best lambda = 0.8 till now
%discount = 1;
% winner Count
agentWins = 0;
userWins = 0;

% train through RL
for episode = 1:20000
    fprintf('episode # %d\n',episode);
    % device a method to choose as to who will move first
    areDiesSame = true;
    
    while(areDiesSame == true)
        agentProxyDie = randi(6,[1,1]);
        userProxyDie = randi(6,[1,1]);
        if(agentProxyDie ~= userProxyDie)
            areDiesSame = false;
            if(agentProxyDie > userProxyDie)
                userChance = 0;
            else
                userChance = 1;
            end
        end
    end
    boardPresent = generateInitialBoard(userChance);
    boardReadable = generateReadableBoard(boardPresent);
    hasGameEnded = false;
    % number of turns taken in a single game
    numTurns = 1;
    isFirstMove = true;
    % simulate the game and run RL
    while(hasGameEnded == false)

        % make present board evaluation
        evalPresent = evaluateBoardNN(boardPresent,V_InHidden,V_HiddenOut);
        % roll the die (every game starts with the die rolled to choose who will make the first move)
        equalDiceAllowed = 6; % i.e one in 6 times
        if(numTurns > 1)
            dice = randi(6,[1,2]);
            if(dice(1) == dice(2))
                while(equalDiceAllowed > 0)
                    dice = randi(6,[1,2]);
                    if(dice(1) ~= dice(2))
                        break;
                    else
                        equalDiceAllowed = equalDiceAllowed - 1;
                    end
                end
            end
            isFirstMove = false;
        else
            dice = [agentProxyDie,userProxyDie];
        end
        %% find all possible moves
        
        if(dice(1) == dice(2))
            diceNew = [dice,dice];
        else
            diceNew = dice;
        end
      
        %% the possible moves generated from backgammon model
        moveTemp = [];
        possibleMoves = [];
        possibleMoves = get_possible_moves(diceNew,boardReadable,boardPresent,moveTemp,possibleMoves, userChance);


        %% find the best possible move
        nextMoveMyMove = false;

        [evalNext,boardNext] = bestAction(possibleMoves,boardPresent...
                            ,nextMoveMyMove,V_InHidden,V_HiddenOut,userChance);
        %% Check if this is the end of the game
        agentBorneOff = 15 * boardNext(197);
        userBorneOff = 15 * boardNext(198);
        [hasGameEnded,agentWins,userWins,reward] = checkGameStatus(...
            agentBorneOff,userBorneOff,agentWins,userWins);

        % Make weight update using backprop
        if(hasGameEnded == true)
            outputNext = reward;  % this is V0(s1)
            outputPresent = evalPresent; % this is V0(s0)
            [V_HiddenOut,V_InHidden,e_HiddenOut,e_InHidden] = ...
                BackPropogation(V_HiddenOut,V_InHidden,...
                                e_HiddenOut,e_InHidden,reward,...
                                outputNext,outputPresent,...
                                alpha,lambda,boardNext);
        elseif(isFirstMove == false)
            outputNext = evalNext;  % this is V0(s1)
            outputPresent = evalPresent; % this is V0(s0)
            [V_HiddenOut,V_InHidden,e_HiddenOut,e_InHidden] = ...
                BackPropogation(V_HiddenOut,V_InHidden,...
                                e_HiddenOut,e_InHidden,reward,...
                                outputNext,outputPresent,...
                                alpha,lambda,boardNext);
        end
        
        %% update the board and give the chance to the opponent
        boardPresent = boardNext;
        boardReadable = generateReadableBoard(boardPresent);

        if(userChance == 0)
            userChance = 1;
        else
            userChance = 0;
        end
        numTurns = numTurns + 1;
    end
    fprintf('Agent/User = [%d, %d]\n', agentWins,userWins);
    %% save the data against system shutdown
    if(mod(episode,500)== 1)
        dlmwrite('VinHide.mat',V_InHidden,'delimiter',' ','precision','%10.6g');
        dlmwrite('VhideOut.mat',V_HiddenOut,'delimiter',' ','precision','%10.6g');
        dlmwrite('eInHide.mat',e_InHidden,'delimiter',' ','precision','%10.6g');
        dlmwrite('eHideOut.mat',e_HiddenOut,'delimiter',' ','precision','%10.6g');
        dlmwrite('agentUser.mat',[agentWins,userWins],'delimiter',' ','precision','%10.6g');
    end
end

%end

