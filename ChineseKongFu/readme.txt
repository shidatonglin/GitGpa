https://www.forexfactory.com/showthread.php?t=654736


in this post i will explain how to use this system.
first i classify the market into trend , notrend(forgive this word ,you know what i mean) and "nothing".

uptrend: white2>yellow1 white2[0]>white2[1]
downtrend: white1<yellow2 white1[0]<white1[1]

the picture will show you what is white[0] or white[1] . white arrow is white[0] yellow arrow is white[1]. means white[0] is NOW, white[1] is last candle
do you understand???

so this picture is in an uptrend (white2>yellow1 white2[0]>white2[1])


but this picture is in "nothing" nothing is not trend or notrend. remember that.
uptrend nothing: white2>yellow1 white2[0]<white2[1]
downtrend nothing: white1<yellow2 white1[0]>white1[1]

"uptrend nothing" and "downtrend nothing" are all nothing we don't trade in "nothing"


can you guys understand what is trend or "nothing"?

next i will tell you what is "notrend"
this picture is "notrend"
"notrend" is very importand and it's difficult to understand ,but i can explain it in Mathematical method
pay attention,
"notrend": both white1 and white2 are between yellow1 and yellow2 . AND white1&white2 are in opposition to yellow1&yellow2 look at the second picture, two arrows shoot two direction,up and down.


now the most important thing coming!

entry in uptrend: first make sure you are in an uptrend by the way i posted, then when price touch white2,here is the entry for long.
entry in downtrend: first make sure you are in an downtrend by the way i posted, then when price touch white1,here is the entry for short.

tp:20pips(if you are new in this system or you can choose 40pips)
sl:30pips

exit in uptrend:if the uptrend become "nothing " you should close your trade
exit in downtrend:if the downtrend become "nothing " you should close your trade

this picture show two entries short and long ,and both of them get tp


1 run in USD/JPY only . very important. if your CAD/JPY spread less than 2.0 you can try CAD/JPY also.but USD/JPY is your mainly currency
2 run in 2h chart only! second important thing ,only run in 2h chart!


now the most important thing coming!

entry in uptrend: first make sure you are in an uptrend by the way i posted, then when price touch white2,here is the entry for long.
entry in downtrend: first make sure you are in an downtrend by the way i posted, then when price touch white1,here is the entry for short.

tp:20pips(if you are new in this system or you can choose 40pips)
sl:30pips

exit in uptrend:if the uptrend become "nothing " you should close your trade
exit in downtrend:if the downtrend become "nothing " you should close your trade

this picture show two entries short and long ,and both of them get tp


one more important thing i forget.
just trade one time in a trend or notrend, what ever win or lose. the first trade you made must be the best entry in this trend or notrend
  
1 in the uptrend , white2[0]>white2[1] should be comfired all the time . if not,market are become nothing.
2 white2[0]>white2[1]means now the white2 line is upper than the previous candle's white2 line.
clear?
  
https://www.forexfactory.com/showthread.php?p=9752659#post9752659

https://www.forexfactory.com/showthread.php?p=9752791#post9752791

https://www.forexfactory.com/showthread.php?p=9756866#post9756866

https://www.forexfactory.com/showthread.php?p=9756932#post9756932

Both white lines inside yellow lines and all moving towards same direction is also NOTHING.


Hi,

How about this

white_10 = iCustom(Symbol(),Period(),"liun_interval_index", 1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 1, 0);
white_11 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 1, 1);

white_20 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 0, 0);
white_21 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 0, 1);

yellow_10 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 0, 0);
yellow_11 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 0, 1);

yellow_20 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 1, 0);
yellow_21 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 1, 1);


Try this,

upTrend = false;
if (white_21 > yellow_11 && white_20 > white_21)
{
upTrend = true;
}

if (!previousUptrend && upTrend && nbrOfBuyTrades == 0)
{
// look for touch of W2
if (Ask < white_20)
{
// open buy trade
OrderSendReliable(_symb, OP_BUY, startVolume, Ask, slippage, 0.0, 0.0, magicNumberBuy, "Uptrend trade", 0, 0);
previousUptrend = upTrend;
}
}

if (!upTrend) { previousUptrend = false;}

BR
 1 
