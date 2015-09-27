# TC-130 Random Damage Predictor

The TC-130 Random Damage Predictor will calculate the odds of different spreads of damage 
from random spells like Arcane Missiles, Avenging Wrath, or Mad Bomber.

Use it live here: http://pindia.github.io/hs-predictor

On the top row, input the amount of random damage coming from sources that target enemies only (e.g. Arcane Missiles> on the 
left and the amount that target all characters (e.g. Mad Bomber) on the right. Input the enemy board state on the middle row
and your board state on the bottom.

Under each characters its probability distribution will appear. The number is an amount of damage it might receive, and the 
percent is the probability of exactly that amount being received.

## How does it work?

Unlike similar tools, which run a large number of simulated trials to get results, TC-130 is able to calculate results **exactly** in most cases. It's the
difference between calculating the odds of getting ten heads in a row is (1/2)^10 = 1/1024 = .09765625% and actually flipping the coin 10,000 times, getting 9 
heads, and saying the odds are 9/10000 = .09%.

Internally it uses a recursive algorithm that is conceptually similar to drawing a [probability tree](http://www.onlinemathlearning.com/image-files/cliprob52.gif).
Combined with a super-optimized undo system, it's able to multiply and sum the odds of all the possiblities very fast.

For simple scenarios this is actually faster than simulation. However for situations with many minions or lots of damage it slows down very quickly. For these
complex situations TC-130 will automatically switch to the simulation method. (For you techies out there, the problem is that calculation is `O(2^n)` while
simulation is `O(n*m)` where n is the amount of damage and m is the number of trials to simulate.)