% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function legal_moves = get_legal_moves(board,die,userChance)
% get all the legal moves for throw of just one die
% General Knowledge - (3,1) is 1 pair of die which has 2 die
% board - present state of readable board
% die - the die for which we are generating the move
% userChance - 0 - agent's chance
%              1 - user's chance
% state --> 0 - bar state
%           1 - bearing Off State
%           2 - all other situation

legal_moves = [];

%% what is the present State of the board
% the game is over so no move possible- return
if(board(2,2) == 15 || board(1,27) == 15)
    legal_moves = [];
    return;
% bar state
elseif(board(userChance + 1,1) ~= 0)
    state = 0;
% can start bearing off
elseif(bearOffPossible(board,userChance) == true)
    state = 1;
% all other situation
else
    state = 2;
end
% start from location fartherst away from home for the moving side
if(userChance == 1)
    position = 24;
else
    position = 1;
end

if(userChance == 1)
    while(position > 0)
        if(state == 0)
            positionStart = -1;
            positionEnd = 25 - die;
            if(board(1, positionEnd + 2) >= 2)
                break; % come out of the loop and return NULL legal_moves
            else
                legal_moves = [positionStart,positionEnd];
                break; % come out of the loop as with one die and checker
                       % on the bar only one move is possible
            end
        elseif(state == 1)
            % case 1: Checker available at the exact place for bearing off
               if(board(2,die + 2) > 0)
                   legal_moves = [die,0];
                   break;
               end
               % case1 fails - check presence of case2
               % case2: legal move from higher position checker
               case2passed = false;
               for i = 6:-1:(die + 1)
                   % if user checkers available and die move possible
                   if(board(2,i + 2) > 0 && board(1,i + 2 - die) < 2)
                       positionStart = i;
                       positionEnd = i - die;
                       legal_moves = [legal_moves;[positionStart,positionEnd]];
                       case2passed = true;                   
                   end
               end
               %legal_moves
               if(case2passed == true) % case 2 pass - break and move on.
                   break;
               end
               % case 2 fails - check presence of case 3
               % case 3: bear off the nearest lower checker from the exact
               % bearing off position - if case1 & case 2 fails- case3
               % always passes
               case3passed = false;
               for i = (die - 1):-1:1
                   if(board(2,i + 2) > 0)
                       positionStart = i;
                       positionEnd = 0;
                       legal_moves = [positionStart, positionEnd];
                       case3passed = true;
                       break;
                   end
               end
               % break away as job is done
               if(case3passed == true)
                   break;
               else
                   legal_moves = [];
                   return;
               end
        else % normal case
            % if movement possible for that move
            if(position - die > 0)
                if(board(2,position + 2) > 0 && board(1, position + 2 - die) < 2)
                    positionStart = position;
                    positionEnd = position - die;
                    legal_moves = [legal_moves;[positionStart,positionEnd]];
                    position = position - 1;
                else
                    position = position - 1;
                end
            else
                position = position - 1;
            end
        end                  
    end
% agent's chance    
else
    while(position < 25)
        if(state == 0)
            positionStart = -1;
            positionEnd = die;
            if(board(2, positionEnd + 2) >= 2)
                break; % come out of the loop and return NULL legal_moves
            else
                legal_moves = [positionStart,positionEnd];
                break; % come out of the loop as with one die and checker
                       % on the bar only one move is possible
            end
        elseif(state == 1)
            % case 1: Checker available at the exact place for bearing off
               if(board(1,25 - die + 2) > 0)
                   legal_moves = [25 - die,25];
                   break;
               end
               % case1 fails - check presence of case2
               % case2: legal move from higher position checker
               case2passed = false;
               for i = 6:-1:(die + 1)
                   % if user checkers available and die move possible
                   if(board(1,25 - i + 2) > 0 && board(2,25 - i + 2 + die) < 2)
                       positionStart = 25 - i;
                       positionEnd = (25 - i) + die;
                       legal_moves = [legal_moves;[positionStart,positionEnd]];
                       case2passed = true;
                   end
                       
               end
               if(case2passed == true) % case 2 pass - make legal move
                   break;
               end
               % case 2 fails - check presence of case 3
               % case 3: bear off the nearest lower checker from the exact
               % bearing off position - if case1 & case 2 fails- case3
               % always passes
               case3passed = false;
               for i = (die - 1):-1:1
                   if(board(1,25 - i + 2) > 0)
                       positionStart = 25 - i;
                       positionEnd = 25;
                       legal_moves = [positionStart, positionEnd];
                       case3passed = true;
                       break;
                   end
               end
               % break away as job is done
               if(case3passed == true)
                   break;
               else
                   legal_moves = [];
                   return;
               end
        else % normal case
            % if movement possible for that move
            if(position + die < 25)
                if(board(1,position + 2) > 0 && board(2, position + 2 + die) < 2)
                    positionStart = position;
                    positionEnd = position + die;
                    legal_moves = [legal_moves;[positionStart,positionEnd]];
                    position = position + 1;
                else
                    position = position + 1;
                end
            else
                position = position + 1;
            end
        end                  
    end
end
end

