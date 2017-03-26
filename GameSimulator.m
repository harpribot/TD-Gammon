% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
% Game Simulation for TD-Gammon
%% Initial Setup
clc;
% load the learnt parameters after 16k iterations
load('bestUser16kIteration.mat');
whoWon = ID.NULL;

%% throw in dice to decide whose first
userTurn = randi([0,1]);
areDiesSame = false; % make this true if you want to manually enter
while(areDiesSame == true)
    agentProxyDie = randi(6,[1,1]);
    userProxyDie = str2double(input('Enter Value Please [1 to 6]: ','s'));
    if(agentProxyDie ~= userProxyDie)
        areDiesSame = false;
        if(agentProxyDie > userProxyDie)
            userTurn = 0;
            disp('Computer Agent Goes First');
        else
            userTurn = 1;
            disp('User Goes First');
        end
    end
end

%% initial board and game objects
boardPresent = generateInitialBoard(userTurn);
boardReadable = generateReadableBoard(boardPresent);
boardIndex = -1:1:25;
doublingCube = {1,ID.NULL}; %[cubeValue,cubeOwner]
disp('Board State at present:');
% disp(boardIndex),disp(boardReadable);
printBoard(boardReadable);

%% Play Game
while(whoWon == ID.NULL)
    
    if(userTurn)
        disp('It is turn of User');
    else
        disp('It is turn of Computer Agent');
    end
    
    % New Die Roll
    equalDiceAllowed = 6;
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
    if(dice(1) == dice(2))
        dice = [dice,dice];
    end
    disp('Dice Throw:');
    disp(dice);

    if(userTurn)
        % User's Turn
        correctMoveMade = false;
        while(correctMoveMade == false)
            userMove = str2num(input('Write Your move in vector format separated by commas (0 to surrender turn):', 's'));
            % in case the user surrenders his move - Enter 0 if want to surrender
            if(userMove == 0)
                boardPresent(193) = 1;
                boardPresent(194) = 0;
                userTurn = ~userTurn;
                break;
            end
            % check if the move is right
            if(size(userMove,2) <= 8 && mod(size(userMove,2),2) == 0)
                userMove = horzcat(userMove,zeros(1,8 - size(userMove,2)));
                if(MoveDirectionValid(userMove))
                    favorability = TestRun(V_InHide, V_HideOut, boardReadable, boardPresent, dice, 1);
                    disp(favorability);
                    [~,indx]=ismember(userMove,favorability(:,2:end),'rows');
                    if(indx ~= 0)
                        correctMoveMade = true;
                        disp('Users Move:');
                        disp(userMove);
                        % update the NN, readable board and userTurn
                        boardPresent = generateBoardFromMove(userMove,boardPresent,false);
                        boardReadable = generateReadableBoard(boardPresent);
                        disp('Board State at present:');
                        printBoard(boardReadable);
                        userTurn = ~userTurn;
                    end
                end
            end
        end
    else
        % Computer Agent's Turn
        boardRevertReadable = changeRoles(boardReadable);
        boardRevert = getNNfromReadableBoard(boardRevertReadable,1);
        % userTurn = 1 as our Agent-2 was the best learner while training
        favorability = TestRun(V_InHide, V_HideOut, boardRevertReadable, boardRevert, dice, 1);
        disp(favorability);  
        bestMoveTemp = favorability(1,2:end);
        bestMove = bestMoveTemp;
        for i = [1,3,5,7]
            if(bestMoveTemp(i + 1) ~= 0 || bestMoveTemp(i) ~= 0)
                bestMove(i) = 25 - bestMoveTemp(i);
                bestMove(i + 1) = 25 - bestMoveTemp(i + 1);
            end
            bestMove(bestMove == 26) = -1;
        end
        disp('Computers Move:');
        disp(bestMove);
        % update the NN,readable board and userTurn
        boardPresent = generateBoardFromMove(bestMove,boardPresent,false);
        boardReadable = generateReadableBoard(boardPresent);
        disp('Board State at present:');
        printBoard(boardReadable);
        userTurn = ~userTurn; 
    end

    % check if game has ended
    if(boardReadable(2,2) == 15)
        % user won
        whoWon = ID.USER; 
        fprintf('User Won');
    elseif(boardReadable(1,27) == 15)
        % agent won
        whoWon = ID.AI; 
        fprintf('Agent Won');  
    else
        
        % Doubling Decision
%         if(userTurn)
%             % ask user for double decision
%             userPropose = str2num(input('Would you Like to double? (0 or 1):', 's'));
%             if(userPropose)
%                 % give user owner ship of cube
%                 doublingCube(2) = 1;
%                 % ask agent to accept double
%                 agentAccept = evalDoubling(favorability,ID.AI,opponentSkill,doublingCube);
%                 if (agentAccept)
%                     %give ownership to agent
%                 else
%                     % user won
%                     whoWon = ID.USER; 
%                     fprintf('User Won');
%                 end
%             end
%         else
%             % ask agent for double decision
%             agentPropose = evalDoubling(favorability,ID.AI,opponentSkill,doublingCube);
%             if(agentPropose)
%                 % ask user to accept double
%                 userAccept = str2num(input('Will you accept a double? (0 or 1):', 's'));
%                 if (userAccept)
%                     %give owner ship to user
%                 else
%                     % agent won
%                     whoWon = ID.AI; 
%                     fprintf('Agent Won');
%                 end
%             end
%         end
        
    end
         
end
