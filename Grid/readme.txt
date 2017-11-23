https://www.forexfactory.com/showthread.php?t=597960
Hi everyone.

I've been following all the Threads around grid martingales lately (Remon Accumulative Grid, Bauta's Expanding Grid, Keydcuk Piggy..) and tried to draw the best of each.
I've been working on some Grid enhancement these months, SWB Grid, Viper grid, and the good old Ilan/Auto-Profit/GridMeUp strategies.

Here is a dynamic TP/Pipstep version of Auto-Profit 3.0 that I had translated from russian and recoded from scratch.
I use an hybrid formula based on HiLo / ATR / raw pips (in % of the price) to determine my targets.

This EA will always be free and I do not intend to sell anything.
__________________________________________________

Disclaimer :

Autop is an EA meant to trade ranging pairs swing by scaling in (mean-reversion style) as the price moves against its TP.
Autop's money management is exponent-based, hence it makes the EA able to recover fast from its drawdown but exposes your equity considerably.
Trading martingales and other scale-in alternatives is dangerous and one often risks his entire account for doing so.
I am not responsible for what you peeps will do with this EA and advise you to ask for settings check-up before running this live.

New release : version 5.3

Now available:

- Trend filter (ADX / ADXMA based)
- Days of the Week filter
- Spread filter
- Time filter (hh:mm starts / hh:mm ends)
- ability to move the InfoBox (hud) from top right to top left
- Survival mode
- ADX Trend Hedge : hedge your current position when the filter switches On. This position will close as your current cycle closes.
- hedge over time filter (i.e. you can just hedge your trades as the time filter is on without having to close them in loss.)
- sharp entries option : the trades are confirmed by the ADX
- one-sided trend filter : allow the expert to take trades toward the momentum in trend
- Disable Short Cycles (disabling short cycles will still allow the EA to open short hedges on long cycles)
- Disable Long Cycles (disabling Long cycles will still allow the EA to open long hedges on short cycles)

Trading Idea: Opportunity mode

By running 2 instances of the EA on 2 charts of the same pair, one with Long Cycles disabled, the other with Short Cycles disabled, and using the one-sided trend filter on both, we will make sure that the EA makes money of big moves whatever the direction even if the other gets stuck into a cycle.
Edit: Make sure to change the Magic Numbers of the EA on the 2 charts so that they don't interfere with each-other

Thank you for helping on this development bros,
Edo

Last updated on the 22/07/2016


Short TF such as M1 / M5 should be favored. Pairs that retrace such as EURUSD / USDCAD / EURCHF theoretically would give better results.



New version released: 4.3

Now available:
- News filter (to be tested)
- Trend filter (ADX / ADXMA based)
- Time filter (hh:mm starts / hh:mm ends)
- ability to move the InfoBox (hud) from top right to top left

Much more to come.
​
Version is updated on post 1 but you can find it here as well with the indicators it lays on.


Thanks Edorenta. Another thing, may you suggest some scalping settings? With shorter take profit and shorter steps? What can we change to achieve this, even it's means it's more dangerous. Thanks...
Lower the HiLo/ATR weight to less than 0.25 each (i.e. 0.16 each) with raw pip offset > your spread (i.e. 2 pips), use a multiplicator over 1.6, use a step*x under 1.1 (i.e 0.9) and use the EA on M1 / M5, then you should get something similar to a martingaling scalper.
I'd advise you to use the trend filter though, using an ADX under 20 and an ADXMA under 50.


Looking Better now! thanks~

The next step for this EA is to increase profit, i suggest you take remon hunt v26 as a model.

What i mean is to give this EA a safety threshold when in a trending market.

EX. supposing we put it on H1, if the trend is really strong, it will buy at every bearish candle with a max limit of 3 orders. 
That's the way remon increase profit for his EA.


You can find enclosed a version that doesn't clean up the chart on deinitialization.
As for the ADX trend, as Kornrogers figured, the ea simply does not trade when this kind of move occurs. This is done in order to focus on ranging markets.

Let me remind you that this is not a trend-trading EA, it has no mean to trade such moves.


If stuck in buy and distance from the first BUY order > XX points ( depending on ATR), sell function will be activated. viceversa Another easy approach is Total BUY lots >= 4 X lot size, start sell (with increased lot maybe?). Total SELL lots >= 4 X lot size, start BUY
What you're describing here my friend is an hedging approach, as I said I don't plan on working on an hedging EA yet.


listen to me my friend, hedging will double your profit with no more risk.

EX. stuck in buy for 2-3 days, switch to sell does not cost your money but only increase your profit.

For the trend filter can not save your EA from the big fall, counter trading is the only way to get out.


Hedging is easy to implement. Getting out of a hedged scenario (profitably) is not so easy... How would you recommend this be done?


New release: version 4.5

- ADX trend filter is now external
- Some bugs corrected (JPY pairs)
- Survival mode (!!!!!! Remon Style, but better  )
- TSD Cal news filter has been disabled, I'll focus on a pure FFCal addon.


i everyone,

New release : version 4.6 (corr 4.7)

- Survival mode is now fixed
- New option called "ADX Trend Hedge" meant to hedge your current position when the filter switches On. This position will close as your current cycle closes.
This option has proven to lower the DD heavily on many of my tests.

I'm working on some optimization to run a trade explorer that I will attach to the thread.

Cheers,

Edo

I was wondering how the option "Keep open positions in trend" is supposed to work
Hi Barlam,

The way it works is really simple:
The ADX accelerates, indicating that a trend initiates whatever the direction it is.
If you tell the EA to close the open deals when the trend filter switches on, whatever your current profit is, it will get closed, often resulting in a loss.
I'm going to work on a better approach of this trend-exit (i.e only exit if the trend seems to be sideways relatively to our current cycle)


Autop stable release : v5.1

New features:
- hedge over time filter (i.e. you can just hedge your trades as the time filter is on without having to close them in loss.)
- sharp entries option : the trades are confirmed by the ADX
- one-sided trend filter : allow the expert to take trades toward the momentum in trend

This is the result From 13/7/2016 in my real account, I will post the details after few hours/days. Still in great condition and small drawdown 
still using 4.3 with default setting，just changed the martingale multipler to 1.1


Hoi, great EA!

I have an idea, how can it works better. I Use UniversalStrenghtMeter since 1 year, and it works fine for me. I use 2 of them, one on H1 and one on H4 both with MACD standard settings. When H1 H4 are in same direction I trade as trend, When H1 is in oposite direction I trade as countertrand. It is possible to run only sell/buy cyrcle in the direction of the trend/countertrend, and run sell+buy cyrcle when the market is in sideway.
There is a short video about the USM, the indicator what I attached is a little different, because it is a free version.


which time frame and pair is best for this nice ea?
  
Short TF such as M1 / M5 should be favored. Pairs that retrace such as EURUSD / USDCAD / EURCHF theoretically would give better results.

Idealy the ea would trade grid-style in ranging markets, and trade longer in trend. Kind of cyclical trading.
Once more thanks for the warning, I wouldn't waste time on such extended dev if I was not interested in it