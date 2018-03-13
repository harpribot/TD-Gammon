# TD-Gammon

This project studies methods of reinforcement learning to solve the complex problem of playing backgammon.<br/>Playing at an expert level requires excellent judgment on vague positional battles where calculation alone is not enough.<br/>A neural network was created to evaluate backgammon using TD(lambda) as the learning method while playing 191k training games. The trained network produced reliable evaluations to be used in the doubling strategy and a 1-ply search for the best move. To improve the doubling strategy we added additional considerations for suboptimal opponents.

## Getting Started

### Training

Learning Method TD(lambda)<br/>
Weights updated with backpropagation<br/>
alpha  = 0.2<br/>
lambda = 0.8<br/>
To run the TD-Learning algorithm run the line below in MatLab or command line:
```
>> TD_Gammon.m
```

### How to Play

Currently you will be playing against an AI that was trained for 191k games.<br/>
To play against the trained AI run the line below in MatLab or command line:
```
>> GameSimulator.m
```
The starting board state is shown below.<br/> 
Simply follow the standard rules of backgammon and try to move your peices left toward position 0 while the AI tries to move his pieces right toward position 25. The first player to move all their pieces to the home position wins. Enter moves in vector format and doubling decicions when prompted.

![Game Board](https://cloud.githubusercontent.com/assets/7111116/24832412/3949c0f6-1c75-11e7-8d39-88f32585ad73.PNG)

### MLP Network Architecture

Input Pattern : raw board encoding vector of 199 inputs<br/>
Hidden Layer  : 51 nodes with sigmoid activation function<br/>
Output Layer  : 1 node with sigmoid activation function, output is the probability of winning (0 to 1)<br/>

![Gammon Network Architecture](https://cloud.githubusercontent.com/assets/7111116/24832397/f46e7b34-1c74-11e7-9e5e-926febf2b423.png)

### Doubling Desisions

The neural network produces a game evaluation from 0 to 1, 1 being the AI has 100% chance of winning.<br/>
The doubling strategy is based on an acceptance and rejection threshold determined from a theoretical formula.<br/>

>![Evaluation Calculation](https://cloud.githubusercontent.com/assets/7111116/24832398/f71f6c6c-1c74-11e7-9151-8f05c38498d6.PNG)

#### Optimal Opponent
accept/propose when there is greater than or equal to 80% chance of winning<br/>
reject when there is less than or equal to 20% chance of winning<br/>
#### Sub-Optimal Opponent
It is often not the case that your opponent plays perfectly optimal, so we found it benificial to research doubling methods that take suboptimal opponents into consideration. We found that the doubling acceptance and rejection threshold should be dynamically shifted to account for suboptimal opponents during the game. The program implements this by tracking the number of suboptimal moves made by the user and the average error. We then shift the thresholds for the skill of the opponent. We also took into consideration other aspects such as what phase the game is in. These additions to the doubling strategy allow the AI to be more or less agressive with doubling just as a human player would be.

## Authors

* **Garrett Kaiser and Tim Sheppard**
* **Harshal Priyadarshi** - *Initial work* - [TD-Gammon](https://github.com/harpribot/TD-Gammon)

See also the list of [contributors](https://github.com/garetWk/TD-Gammon/graphs/contributors) who participated in this project.

## License
This project is licensed under the MIT License - see the [LICENSE.md](License.md) file for details

## Acknowledgments
Hat tip to anyone who's code was used and papers referenced
#### Resources
>G. Tesauro, “Temporal difference learning and td-gammon,”<br/>
>Communications of the ACM, vol. 38, no. 3, pp. 58–68, 1995.<br/>
>http://www.bkgm.com/articles/tesauro/tdl.html#ref16<br/>

>A. Webb, “Be a PRAT, by Alan Webb,” Be a PRAT, 06-Feb-2000.<br/>
>http://www.bkgm.com/articles/Webb/BeAPrat/<br/>

>N.  Zadeh  and  G.  Kobliska, “On  optimal  doubling  in  backgammon,”<br/>
>Management Science, vol. 23, no. 8, pp. 853–858, 1977.<br/>
>http://www.bkgm.com/articles/Zadeh/OnDoublingInTournamentBackgammon/<br/>

>N. Zadeh, “On doubling in tournament backgammon,”<br/>
>Management Science, vol. 23, no. 9, pp. 986–993, 1977.<br/>
>http://www.bkgm.com/articles/Zadeh/OnDoublingInTournamentBackgammon/<br/>

>E. B. Keeler and J. Spencer, “Optimal doubling in backgammon,”<br/>
>Operations Research, vol. 23, no. 6, pp. 1063–1071, 1975.<br/>
>http://www.bkgm.com/articles/KeelerSpencer/OptimalDoublingInBackgammon/index.html<br/>

>K. V. Katsikopoulos and O. Simsek, “Optimal doubling strategy against a suboptimal opponent,”<br/>
>Journal of applied probability, vol. 42, no. 03, pp. 867–872, 2005.<br/>
>http://www.jstor.org/stable/30040863<br/>

>J. P. White, “Backgammon Forum Archive,” Backgammon Forum Archive, 28-Dec-2000.<br/>
>http://www.bkgm.com/rgb/rgb.cgi?view%2B712<br/>





