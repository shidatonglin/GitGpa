
#property copyright "Copyright © 2006, Derk Wehler"
#property link      "http://www.forexfactory.com"

#property indicator_chart_window
#property indicator_buffers 3

#define TITLE		0
#define COUNTRY	1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6

//====================================================================================

extern bool 	IncludeHigh 		= true;
extern bool 	IncludeMedium 		= true;
extern bool 	IncludeLow 			= false;   //true;
extern bool 	IncludeSpeaks 		= true; 		// news items with "Speaks" in them have different characteristics
extern bool		IsEA_Call			= false;
extern int		OffsetHours			= 0;      //-1;
extern bool		AllowWebUpdates	= true;			// Set this to false when using in another EA or Chart, so that the multiple instances of the indicator dont fight with each other
extern int		Alert1MinsBefore	= 0;			// Set to -1 for no Alert
extern int		Alert2MinsBefore	= -1;			// Set to -1 for no Alert
extern bool		ReportAllForUSD	= true;
extern bool    ReportAllForEUR   = true;
extern bool    ReportAllForGBP   = true;
                                             // added and tested by a1ra, seems working OK.
extern bool    ReportAllForNZD   = true;
extern bool    ReportAllForJPY   = true;
extern bool    ReportAllForAUD   = true;
extern bool    ReportAllForCHF   = true;
extern bool    ReportAllForCAD   = true;
extern bool    ReportAllForCNY   = false;

extern bool 	EnableLogging 		= false; 		// Perhaps remove this from externs once its working well
extern bool		ShowNextTwoEvents	= true;
extern bool		ShowVertNews		= false;
extern int 		TxtSize 			   = 10;
extern color 	TxtColorTitle 		= Gold;       //LightGray;
extern color 	TxtColorNews 		= DeepSkyBlue;
extern color 	TxtColorImpact 	= Red;
extern color 	TxtColorPrevious 	= Peru;
extern color 	TxtColorForecast 	= Lime;
extern int		VertTxtShift 		= 21;			// How far away below the ask line we want to place our vertical news text
extern int		VertLeftLineShift 	= 900;			// How far away to the left of the line we want to place our vertical news text
extern int		VertRightLineShift 	= 200;			// How far away to the left of the line we want to place our vertical news text
extern color	VertLineColor 		= SlateBlue;	// Color of our vertical news line
extern color	VertTxtColor 		= Black;		// Color of our vertical text color 
extern int		VertTxtSize 		= 8;			// Color of our vertical text
extern int		NewsCorner 			= 1;			// Choose which corner to place headlines 0=Upper Left, 1=Upper Right, 2=lower left , 3=lower right
extern bool		SaveXmlFiles		= false;		// If true, this will keep the daily XML files

int		DebugLevel = 5;


double 	ExtMapBuffer0[];	// Contains (minutes until) each news event
double 	ExtMapBuffer1[];	// Contains only most recent and next news event ([0] & [1])
double 	ExtMapBuffer2[];	// Contains impact value for most recent and next news event

//string	sUrl = "http://www.forexfactory.com/calendar.php";

string	sUrl = "http://forexfactory.com/ffcal_week_this.xml";
int 	   xmlHandle;
int 	   logHandle = -1;
int 	   BoEvent, finalend, end, i;
int		begin;
string 	mainData[100][7];
int 	   minsTillNews;
string 	sData, csvoutput;
string	commentStr;
int		tmpMins;
int		idxOfNext;
int		dispMinutes[2];
string 	dispTitle[2], 
		   dispCountry[2], 
		   dispImpact[2], 
		   dispForecast[2], 
		   dispPrevious[2];

string 	sTags[7] = { "<title>", "<country>", "<date><![CDATA[", "<time><![CDATA[", "<impact><![CDATA[", "<forecast><![CDATA[", "<previous><![CDATA[" };
string 	eTags[7] = { "</title>", "</country>", "]]></date>", "]]></time>", "]]></impact>", "]]></forecast>", "]]></previous>" };
//old tag		   	   
//string 	sTags[7] = { "<title>", "<country>", "<date>", "<time>", "<impact>", "<forecast>", "<previous>" };
//string 	eTags[7] = { "</title>", "</country>", "</date>", "</time>", "</impact>", "</forecast>", "</previous>" };

static bool NeedToGetFile = false;
static int	PrevMinute = -1;
static int	RefreshMin = 0;
static int	RefreshHour = 0;

datetime 	LastTimeAlert1 = 0;	// Used to make sure we only draw something once per annoucement. Added by MN
string 		xmlFileName;  		// Made global. added by MN

int init()
{
	if (DebugLevel > 0)
		Print("In Init()...\n");
	
	SetIndexStyle(0, DRAW_NONE);
	SetIndexBuffer(0, ExtMapBuffer0);

	SetIndexStyle(1, DRAW_NONE);
	SetIndexBuffer(1, ExtMapBuffer1);

	SetIndexStyle(1, DRAW_NONE);
	SetIndexBuffer(2, ExtMapBuffer2);

	IndicatorShortName("FFCal");
//	SetIndexLabel(0, "MinsBeforeNews");
//	SetIndexLabel(1, "MinsAfterNews"); 
	//-------------------------------------------------------------
	MathSrand(TimeLocal());               //random number
	RefreshMin  = (MathRand() % 60);
	RefreshHour = (MathRand() % 6);
	if (DebugLevel > 0)
	{  Print("RefreshMin  == ", RefreshMin);
		Print("RefreshHour == ", RefreshHour);
	}
	//------------------------------------------------------------
	
	return(0);
}


int deinit()
{
	int i2;
	
	ObjectDelete("Sponsor"); 

	ObjectDelete("Minutes"); 
	ObjectDelete("Impact");
	ObjectDelete("Previous"); 
	ObjectDelete("Forecast");

	ObjectDelete("Minutes2"); 
	ObjectDelete("Impact2");
	ObjectDelete("Previous2"); 
	ObjectDelete("Forecast2");
	
	// Cycle through all the Objects looking for the Vertical Line. //added by MN
	for(i2=ObjectsTotal()-1; i2 >= 0; i2--)
	{
		string VerticalLineName = ObjectName(i2);
		if (StringSubstr(VerticalLineName, 0, 5) != "vLine")
			continue;
      
		ObjectDelete(VerticalLineName);   
	}

	// Cycle through all the Objects looking for the HeadLine text. //added by MN
	for (i2=ObjectsTotal()-1; i2 >= 0; i2--)
	{
		string HeadlineName = ObjectName(i2);
		if (StringSubstr(HeadlineName, 0, 8) != "Headline")
			continue;
      
		ObjectDelete(HeadlineName);   
	}
   
	// Fixed one case of divide by zero where multiple charts 
	// indicator is on was trying to overwrite the same file
	xmlFileName = GetXmlFileName();
	xmlHandle   = FileOpen(xmlFileName, FILE_BIN|FILE_READ|FILE_WRITE);

	// File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
	if (xmlHandle >= 0)
	{
		// Since file exists, Close what we just opened
		FileClose(xmlHandle);
		
		// Delete our news file and redownload a new one to prevent a remainder from zero divide error
		if (!SaveXmlFiles)
			FileDelete(xmlFileName);
	}
   
	return(0);
}


string GetXmlFileName()
{
	return (Month() + "-" + Day() + "-" + Year() + "-" + Symbol() + Period() + "-" + "FFCal.xml");
}  
//C:\Program Files\IBFX Australia\experts\files\2-16-2011-EURUSD240-FFCal.xml


int start()
{
	int 		  newsIdx     =  0;
	int 		  nextNewsIdx = -1;
	int 		  next;
	string     myEvent;
	bool 		  skip;
	datetime   newsTime;
   ulong      file_size = 0;
   ulong      data_size = 0;
         
	// check to make sure we are connected, otherwise exit. Added by MN
	if (!IsConnected())
	{
		Print("News Indicator is disabled because NO CONNECTION to Broker!");
		return(0);
	}
   
	// If we are not logging, then do not output debug statements either
	if (!EnableLogging)
		DebugLevel = 0;
				
	commentStr = "FOREX FACTORY CALENDAR";
	
	// Added this section to check if the XML file already exists.  
	// If it does NOT, then we need to set a flag to go get it
	xmlFileName = GetXmlFileName();
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);
   file_size = FileSize(xmlHandle);

	// File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
	if (xmlHandle >= 0)
	{
		// Since file exists, close what we just opened
		FileClose(xmlHandle);
		NeedToGetFile = false;
	}
	else	
		NeedToGetFile = true;

	
	//added by MN. Set this to false when using in another EA or Chart, so that the multiple 
	//instances of the indicator dont fight with each other
	if (AllowWebUpdates)
	{
		// New method: Use global variables so that when put on multiple charts, it 
		// will not update overly often; only first time and every 4 hours
		if (DebugLevel > 1)
			Print(GlobalVariableGet("LastUpdateTime") + " " + (TimeCurrent() - GlobalVariableGet("LastUpdateTime")));
			
  		if (file_size == 0 || NeedToGetFile || GlobalVariableCheck("LastUpdateTime") == false || (TimeCurrent() - GlobalVariableGet("LastUpdateTime")) > 14400)
		{
			if (DebugLevel > 1)
				Print("sUrl == ", sUrl);
		
			if (DebugLevel > 0)
				Print("Grabbing Web, url = ", sUrl);
	
			// THIS CALL WAS DONATED BY PAUL TO HELP FIX THE RESOURCE ERROR
			GrabWeb(sUrl, sData);

			if (DebugLevel > 0)
			{
				Print("Opening XML file...\n");
				Print(sData);
			}

			// Delete existing file
			FileDelete(xmlFileName);
			
			// Write the contents of the ForexFactory page to an .htm file
			// If it is still open from the above FileOpen call, close it.
			xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_WRITE);
			if (xmlHandle < 0)
			{
				if (DebugLevel > 0)
					Print("Can\'t open new xml file, the last error is ", GetLastError());
				return(false);
			}
			FileWriteString(xmlHandle, sData, StringLen(sData));
			FileClose(xmlHandle);

			if (DebugLevel > 0)
				Print("Wrote XML file...\n");

			// THIS BLOCK OF CODE DONATED BY WALLY TO FIX THE RESOURCE ERROR
			//--- Look for the end XML tag to ensure that a complete page was downloaded ---//
			end = StringFind(sData, "</weeklyevents>", 0);

			if (end <= 0)
			{
				Alert("FFCal Error - Web page download was not complete!");
				return(false);
			}
			else
			{
				// set global to time of last update
				GlobalVariableSet("LastUpdateTime", TimeCurrent());
			}
			
			//-------------------------------------------------------------------------------//
		}
	} //end of allow web updates

	// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	// Perform remaining checks once per minute
	if (!IsEA_Call && Minute() == PrevMinute)
		return (true);
	PrevMinute = Minute();
//	Print("FFCal NEW MINUTE...Refreshing News from XML file...");

	// Open the log file (will not open if logging is turned off)
	OpenLog("FFCal");

	// Init the buffer array to zero just in case
	ArrayInitialize(ExtMapBuffer0, 0);
	ArrayInitialize(ExtMapBuffer1, 0);
	
	// Open the XML file
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);
	if (xmlHandle < 0)
	{
		Print("Can\'t open xml file: ", xmlFileName, ".  The last error is ", GetLastError());
		return(false);
	}

	if (DebugLevel > 0)
		Print("XML file open must be okay size = ", file_size, "  handle = ", xmlHandle);
	
	// Read in the whole XML file
	// Ave file length == ~7K, so 65536 should always read whole file

	sData = FileReadString(xmlHandle, 65536);	
	bool pnt = FileSeek(xmlHandle, 0, 0); //senza non funziona
	
   file_size = FileSize(xmlHandle);
   data_size = StringLen(sData);
	
   //if (((ulong)StringLen(sData)) < FileSize(xmlHandle))
	//   sData = sData + FileReadString(xmlHandle, FileSize(xmlHandle));	
   if (data_size < file_size)
	   sData = sData + FileReadString(xmlHandle, file_size);	

	// Because MT4 build 202 complained about too many files open and MT4 hung. Added by MN
	if (xmlHandle > 0)
		FileClose(xmlHandle);

	// Get the currency pair, and split it into the two countries
	string pair = Symbol();
	string cntry1 = StringSubstr(pair, 0, 3);
	string cntry2 = StringSubstr(pair, 3, 3);
	if (DebugLevel > 0)
		Print("cntry1 = ", cntry1, "    cntry2 = ", cntry2);
	
	if (DebugLevel > 0)
		Log("Weekly calendar for " + pair + "\n\n");

	// -------------------------------------------------
	// Parse the XML file looking for an event to report
	// -------------------------------------------------
	
	tmpMins = 10080;	// (a week)
	BoEvent = 0;

	while (true)
	{
		BoEvent = StringFind(sData, "<event>", BoEvent);
		if (BoEvent == -1)
			break;
			
		BoEvent += 7;	
		next = StringFind(sData, "</event>", BoEvent);
		if (next == -1)
			break;
	
		myEvent = StringSubstr(sData, BoEvent, next - BoEvent);
		BoEvent = next;

		begin = 0;
		skip = false;
		for (i=0; i < 7; i++)
		{
			mainData[newsIdx][i] = "";
			next = StringFind(myEvent, sTags[i], begin);

			// Within this event, if tag not found, then it must be missing; skip it
			if (next == -1)
				continue;
			else
			{
				// We must have found the sTag okay...
				begin = next + StringLen(sTags[i]);			// Advance past the start tag
				end = StringFind(myEvent, eTags[i], begin);	// Find start of end tag
				if (end > begin && end != -1)
				{
					// Get data between start and end tag
					mainData[newsIdx][i] = StringSubstr(myEvent, begin, end - begin);
				}
			}
		}
		
//		for (i=6; i >= 0; i--)
//			Print(sTags[i], "  =  ", mainData[newsIdx][i]);

		// = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =
		// Test against filters that define whether we want to 
		// skip this particular annoucement
		if (cntry1 != mainData[newsIdx][COUNTRY] && cntry2 != mainData[newsIdx][COUNTRY] &&
			((!ReportAllForUSD || mainData[newsIdx][COUNTRY] != "USD") && 
			 (!ReportAllForEUR || mainData[newsIdx][COUNTRY] != "EUR") && 
			 (!ReportAllForGBP || mainData[newsIdx][COUNTRY] != "GBP")&& 
			 (!ReportAllForNZD || mainData[newsIdx][COUNTRY] != "NZD")&& 
			 (!ReportAllForJPY || mainData[newsIdx][COUNTRY] != "JPY")&& 
			 (!ReportAllForAUD || mainData[newsIdx][COUNTRY] != "AUD")&& 
			 (!ReportAllForCAD || mainData[newsIdx][COUNTRY] != "CAD")&& 
			 (!ReportAllForCHF || mainData[newsIdx][COUNTRY] != "CHF")&& 
			 (!ReportAllForCNY || mainData[newsIdx][COUNTRY] != "CNY")))
			skip = true;

		if (!IncludeHigh && mainData[newsIdx][IMPACT] == "High") 
			skip = true;
		if (!IncludeMedium && mainData[newsIdx][IMPACT] == "Medium") 
			skip = true;
		if (!IncludeLow && mainData[newsIdx][IMPACT] == "Low") 
			skip = true;
		if (!IncludeSpeaks && (StringFind(mainData[newsIdx][TITLE], "speaks") != -1 || 
								StringFind(mainData[newsIdx][TITLE], "Speaks") != -1) ) 
			skip = true;
		if (mainData[newsIdx][TIME] == "All Day" || 
			mainData[newsIdx][TIME] == "Tentative" ||
			mainData[newsIdx][TIME] == "") 
			skip = true;
		// = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =
	   
		// If not skipping this event, then log it into the draw buffers
		if (!skip)
		{   
			// If we got this far then we need to calc the minutes until this event
			//
			// First, convert the announcement time to seconds (in GMT)
			newsTime = StrToTime(MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]));
			
			// Now calculate the minutes until this announcement (may be negative)
			minsTillNews = (newsTime - myTimeGMT()) / 60;
			if (DebugLevel > 0)
			{
				Log("FOREX FACTORY\nTitle: " + mainData[newsIdx][TITLE] + "\n" + minsTillNews + "\n\n");
			}
					
			// This "if" section added by MN
			// If minsTillNews is zero, then it's the time our news is hit
			if ((minsTillNews == 0) && (LastTimeAlert1 != newsTime))
			{
				// draw the 1st news event onto the chart vertically so 
				// we have a visual record of when it occured
				DisplayVerticalNews(dispTitle[0], dispCountry[0], 0); 

				// If there is a 2nd simultaneous news event, 
				// display the 2nd news event
				if (dispMinutes[0] == dispMinutes[1])
					DisplayVerticalNews(dispTitle[1], dispCountry[1], 1); 
				
				// only draw once per announcement
				LastTimeAlert1 = newsTime;
			}

			// This "if" section added by MN
			// Back Draw old news onto the chart. Added by MN
			if (ShowVertNews && !IsEA_Call)  
			{
				// Back draw 1st news headline
				DisplayOldNews(mainData[newsIdx][TITLE], mainData[newsIdx][COUNTRY], 0, StrToTime(MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]))); 
	
				//if there is a 2nd simultaneously occuring news headline, draw that onto the chart as well
				if (mainData[newsIdx][TIME] == mainData[newsIdx+1][TIME])
					DisplayOldNews(mainData[newsIdx+1][TITLE], mainData[newsIdx+1][COUNTRY], 1, 
						StrToTime(MakeDateTime(mainData[newsIdx+1][DATE], mainData[newsIdx+1][TIME]))); 
			}  
			
			// Keep track of the most recent news announcement.
			// Do that by saving each one until we get to the 
			// first annoucement that isn't in the past; i.e.
			// minsTillNews > 0.  Then, keep this one instead for
			// display, but only once the minutes until the next 
			// news is SMALLER than the minutes since the last.
//			Print("Mins till event: ", minsTillNews);
			if (minsTillNews < 0 || MathAbs(tmpMins) > minsTillNews)
			{
				idxOfNext = newsIdx;
				tmpMins	= minsTillNews;
			}
			
			Log("Weekly calendar for " + pair + "\n\n");
			if (DebugLevel > 0)
			{
				Log("FOREX FACTORY\nTitle: " + mainData[newsIdx][TITLE] + 
									"\nCountry: " + mainData[newsIdx][COUNTRY] + 
									"\nDate: " + mainData[newsIdx][DATE] + 
									"\nTime: " + mainData[newsIdx][TIME] + 
									"\nImpact: " + mainData[newsIdx][IMPACT] + 
									"\nForecast: " + mainData[newsIdx][FORECAST] + 
									"\nPrevious: " + mainData[newsIdx][PREVIOUS] + "\n\n");
			}
			
			// Do alert if user has enabled
			if (Alert1MinsBefore != -1 && minsTillNews == Alert1MinsBefore)
				Alert(Alert1MinsBefore, " minutes until news for ", pair, ": ", mainData[newsIdx][TITLE]);
			if (Alert2MinsBefore != -1 && minsTillNews == Alert2MinsBefore)
				Alert(Alert2MinsBefore, " minutes until news for ", pair, ": ", mainData[newsIdx][TITLE]);
				
			// Buffers are set up as so: 
			// ExtMapBuffer0 contains the time UNTIL each announcement (can be negative)
			// e.g. [0] = -372; [1] = 25; [2] = 450; [3] = 1768 (etc.)
			// ExtMapBuffer1[0] has the mintutes since the last annoucement.
			// ExtMapBuffer1[1] has the mintutes until the next annoucement.
			ExtMapBuffer0[newsIdx] = minsTillNews;
			newsIdx++;
		}
	}

	// Cycle through the events array and pick out the most recent 
	// past and the next coming event to put into ExtMapBuffer1. 
	// Put the corresponding impact for these two into ExtMapBuffer2.
	bool first = true;
	ExtMapBuffer1[0] = 99999;
	ExtMapBuffer1[1] = 99999;
	ExtMapBuffer2[0] = 0;
	ExtMapBuffer2[1] = 0;
	string outNews = "Minutes until news events for " + pair + " : ";
	for (i=0; i < newsIdx; i++)	
	{
		outNews = outNews + ExtMapBuffer0[i] + ", ";
		if (ExtMapBuffer0[i] >= 0 && first)
		{
			first = false;
			
			// Put the relevant info into the indicator buffers...

			// Minutes SINCE - - - - - - - - - - - - - - - - - - - - - - - - -
			// (does not apply if the first event of the week has not passed)
			if (i > 0)
			{
				ExtMapBuffer1[0] = MathAbs(ExtMapBuffer0[i-1]);
				ExtMapBuffer2[0] = ImpactToNumber(mainData[i-1][IMPACT]);
			}
			
			// Minutes UNTIL - - - - - - - - - - - - - - - - - - - - - - - - -
			// Check if past the last event.  
			if (ExtMapBuffer0[i] > 0 || (ExtMapBuffer0[i] == 0 && ExtMapBuffer0[i+1] > 0))
			{
				ExtMapBuffer1[1] = ExtMapBuffer0[i];
			}
			ExtMapBuffer2[1] = ImpactToNumber(mainData[i][IMPACT]);
		}
		
		// Also use this loop to set which information to display
		if (i == idxOfNext)
		{
			dispTitle[0]	= mainData[i][TITLE];
			dispCountry[0] 	= mainData[i][COUNTRY];
			dispImpact[0] 	= mainData[i][IMPACT];
			dispForecast[0] = mainData[i][FORECAST];
			dispPrevious[0] = mainData[i][PREVIOUS];
			dispMinutes[0] 	= ExtMapBuffer0[i];
		}
		
		if (i == idxOfNext + 1)
		{
			dispTitle[1]	= mainData[i][TITLE];
			dispCountry[1] 	= mainData[i][COUNTRY];
			dispImpact[1] 	= mainData[i][IMPACT];
			dispForecast[1] = mainData[i][FORECAST];
			dispPrevious[1] = mainData[i][PREVIOUS];
			dispMinutes[1] 	= ExtMapBuffer0[i];
		}
		

	}	
	// If we are past all news events, then neither one will have been 
	// set, so set the past event to the last (negative) minutes
	if (ExtMapBuffer1[0] == 0 && ExtMapBuffer1[1] == 0)
	{
		ExtMapBuffer1[0] = ExtMapBuffer0[i-1];
		ExtMapBuffer1[1] = 999999;

		// Ensures that we clean up so that we get old text 
		// left behind on old news annoumcents. Added by MN
		ObjectDelete("Impact");
		ObjectDelete("Previous"); 
		ObjectDelete("Forecast");

		ObjectDelete("Impact2");
		ObjectDelete("Previous2"); 
		ObjectDelete("Forecast2");
	}      

	
	// For debugging...Print the tines until news events, as a "Comment"
	if (DebugLevel > 0)
	{
		Print(outNews);
		Print("LastMins (ExtMapBuffer1[0]) = ", ExtMapBuffer1[0]);
		Print("NextMins (ExtMapBuffer1[1]) = ", ExtMapBuffer1[1]);
	}

	if (!IsEA_Call)
    	OutputToChart();

	if (logHandle > 0)
	{
		FileClose(logHandle);
		logHandle = -1;
	}
	
	return (0);
}


// Draws the news veritically on the Chart so that we 
// have a visual reference of when it occurs. Added by MN 
void DisplayVerticalNews(string dispVTitle, string dispVCountry, int shift)
{    
	double	Pivot, Height = 0.0;
	
	// Calculate our pivot point to determine where to place the news text
	Pivot = (iHigh(NULL, 1440, 1) + 
			iLow(NULL, 1440, 1) + 
			iClose(NULL, 1440, 1)) / 3;  
   
	// If Open price is above the Pivot determine our height
	if (Open[0] > Pivot)
		Height = Low[iLowest(NULL,0,MODE_LOW,5,0)] - VertTxtShift*Point;  
	else 
		// Otherwise Open is below Pivot
		Height = High[iHighest(NULL,0,MODE_HIGH,5,0)] + VertTxtShift*Point;          

	if (shift == 0)
	{
		// Draw a vertical line at the time of the news if it hasnt already been drawn
		if (ObjectFind("vLine" + Time[0]) == -1)
		{
			ObjectCreate("vLine" + Time[0], OBJ_TREND, 0, Time[0], 0, Time[0], High[0]); 	// experimental
			ObjectSet("vLine" + Time[0], OBJPROP_COLOR, VertLineColor);
			ObjectSet("vLine" + Time[0], OBJPROP_STYLE, STYLE_DOT);
			
			// Put object in the background behind any other object on the chart
			ObjectSet("vLine" + Time[0], OBJPROP_BACK, true);	
		}

		// Place our news if it hasnt already been placed on our chart
		if (ObjectFind("Headline" + Time[0]) == -1)
		{  
			// For x value use Time[0], for y value find the lowest 
			// bar within the last 10 bars, subtract by VertTxtShift 
			// and used that as our y coordinate
			ObjectCreate("Headline" + Time[0], OBJ_TEXT, 0, 
						Time[0] - VertLeftLineShift, Height); 
			
			// Rotate the text 90 degrees
			ObjectSet("Headline" + Time[0], OBJPROP_ANGLE, 90);
			
			ObjectSetText("Headline" + Time[0], 
							"News: " + dispVCountry + " " + dispVTitle, 
							VertTxtSize, "Arial", VertTxtColor);
		}
	}
	// Draw second news headline
	else 
	{
		//place our news if it hasnt already been placed on our chart
		if (ObjectFind("Headline" + Time[0]+"s") == -1)
		{
			// For x value use Time[0], for y value find the lowest 
			// bar within the last 10 bars, subtract by VertTxtShift 
			// and used that as our y coordinate
			ObjectCreate("Headline" + Time[0] + "s", OBJ_TEXT, 0, 
						Time[0] + VertRightLineShift, Height); 
			
			// Rotate the text 90 degrees
			ObjectSet("Headline" + Time[0] + "s", OBJPROP_ANGLE, 90);
			
			ObjectSetText("Headline" + Time[0] + "s", 
							"News: " + dispVCountry + " " + dispVTitle, 
							VertTxtSize, "Arial", VertTxtColor);
		}
	}

	//force a redraw of our chart
	WindowRedraw();

	return;
}

// Back Draw Old news veritically on the Chart so that we 
// have a visual reference of when it did occur. Added by MN 
void DisplayOldNews(string dispOTitle, string dispOCountry, int shift, datetime TheTime)
{     
	int   	BarShift;
	double 	Pivot;
	double	Height = 0.0;

	// We have TheTime, now we need the shift so we can 
	// access this Bar's High/Low/Close information
	BarShift = iBarShift(NULL, 0, TheTime);   

	// Calculate our pivot point to determine where to place the news text
	Pivot = (iHigh(NULL, 1440, BarShift) + 
			iLow(NULL, 1440, BarShift) + 
			iClose(NULL, 1440, BarShift)) / 3;

	// If open price is above the Pivot, determine our height
	if (Open[BarShift] > Pivot)
		Height = Low[iLowest(NULL, 0, MODE_LOW, 5, BarShift)] - VertTxtShift*Point;
		
	// Otherwise Open is below Pivot
	else 
		Height = High[iHighest(NULL, 0, MODE_HIGH, 5, BarShift)] + VertTxtShift*Point;

	//Print("Title recieved : " + dispTitle + " Country Recieved: " + dispCountry + " Date and time Recieved: " + TheTime);

	// We only want to vertically draw the news if it hasnt occured yet
	if (TheTime < Time[0])
	{  
		// Draw the first news headline 
		if (shift == 0)
		{
			// Draw a vertical line at the time of the 
			// news if it hasnt already been drawn
			if (ObjectFind("vLine" + TheTime) == -1)
			{
				ObjectCreate("vLine" + TheTime, OBJ_TREND, 0, TheTime, 0, TheTime, High[0]); //experimental
				ObjectSet("vLine" + TheTime, OBJPROP_COLOR, VertLineColor);
				ObjectSet("vLine" + TheTime, OBJPROP_STYLE, STYLE_DOT);
				   
				// put object in the background behind any other object on the chart
				ObjectSet("vLine" + TheTime, OBJPROP_BACK, true);
			}
  
			// Place our news if it hasnt already been placed on our chart
			if (ObjectFind("Headline" + TheTime) == -1)
			{
				// For x value use Time[0], for y value find the lowest bar within the last 10 bars, subtract by VertTxtShift and used that as our y coordinate
				ObjectCreate("Headline" + TheTime, OBJ_TEXT, 0, TheTime - VertLeftLineShift, Height); 
				
				// rotate the text 90 degrees
				ObjectSet("Headline" + TheTime, OBJPROP_ANGLE, 90);
				ObjectSetText("Headline" + TheTime, "News: " + dispOCountry + " " + dispOTitle, 
							VertTxtSize, "Arial", VertTxtColor);
			}            
		}
		
		// Draw second news headline
		else 
		{
			//place our news if it hasnt already been placed on our chart
			if (ObjectFind("Headline" + TheTime + "s") == -1)
			{
				// For x value use Time[0], for y value find the lowest bar within the 
				// last 10 bars, subtract by VertTxtShift and used that as our y coordinate
				ObjectCreate("Headline" + TheTime + "s", OBJ_TEXT, 0, 
								TheTime + VertRightLineShift, Height); 
				
				// Rotate the text 90 degrees
				ObjectSet("Headline" + TheTime + "s", OBJPROP_ANGLE, 90);
				ObjectSetText("Headline" + TheTime + "s", "News: " + dispOCountry + " " + dispOTitle, 
								VertTxtSize, "Arial", VertTxtColor);
			}   
		} // end of "if shift)
	} // end of (TheTime < ((Time[0]))+180+180)
        
	// Force a redraw of our chart
	WindowRedraw();

	return;
}


void OutputToChart()
{
	// Added by Robert for using TxtSize and TxtColor for easier reading
	int curY = 12;
	int Days, Hours, Mins; // to display time in days, hours, minutes
	string TimeStr;
	
	if (ObjectFind("Sponsor") == -1)
		ObjectCreate("Sponsor", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("Sponsor", commentStr, TxtSize, "Arial Bold", TxtColorTitle);
	ObjectSet("Sponsor", OBJPROP_CORNER, NewsCorner);
	ObjectSet("Sponsor", OBJPROP_XDISTANCE, 10);
	ObjectSet("Sponsor", OBJPROP_YDISTANCE, curY);       
	
	// If the time is 0 or negative, we want to say 
	// "xxx mins SINCE ... news event", else say "UNTIL ... news event"
	string 	sinceUntil = "until ";
	int 	dispMins = dispMinutes[0];
	if (dispMinutes[0] <= 0)
	{
		sinceUntil = "since ";
		dispMins *= -1;
	}
	curY = curY + TxtSize + 4;
	
	// added the following to show hours and days for longer durations
	// this could be enhanced to suppress 0 hours and 0 minutes
	if (dispMins == 999999)
	{
		TimeStr = " (No more events this week)";
	}
	else if (dispMins < 60)
	{
		TimeStr = dispMins + " mins ";
	}
	else // time is 60 minutes or more
	{
		Hours = MathRound(dispMins / 60);
		Mins = dispMins % 60;
		if (Hours < 24) // less than a day: show hours and minutes
		{
			TimeStr = Hours + " hrs " + Mins + " mins ";
		}
		else  // days, hours, and minutes
		{
			Days = MathRound(Hours / 24);
			Hours = Hours % 24;
			TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		}
	}
	
	if (ObjectFind("Minutes") == -1)
		ObjectCreate("Minutes", OBJ_LABEL, 0, 0, 0);

	if (dispMins == 999999)
		ObjectSetText("Minutes", TimeStr, TxtSize, "Arial Bold", TxtColorNews);
	else
		ObjectSetText("Minutes", TimeStr + sinceUntil + dispCountry[0] + ": " + dispTitle[0], TxtSize, "Arial Bold", TxtColorNews);

	ObjectSet("Minutes", OBJPROP_CORNER, NewsCorner);
	ObjectSet("Minutes", OBJPROP_XDISTANCE, 10);
	ObjectSet("Minutes", OBJPROP_YDISTANCE, curY);

	curY = curY + TxtSize + 4;
	if (ObjectFind("Impact") == -1)
		ObjectCreate("Impact", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("Impact", "Impact: " + dispImpact[0], TxtSize, "Arial Bold", TxtColorImpact);
	ObjectSet("Impact", OBJPROP_CORNER, NewsCorner);
	ObjectSet("Impact", OBJPROP_XDISTANCE, 10);
	ObjectSet("Impact", OBJPROP_YDISTANCE, curY);

	if (dispPrevious[0] != "")
	{
		curY = curY + TxtSize + 4;
		if (ObjectFind("Previous") == -1)
			ObjectCreate("Previous", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Previous", "Previous: " + dispPrevious[0], TxtSize, "Arial Bold", TxtColorPrevious);
		ObjectSet("Previous", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Previous", OBJPROP_XDISTANCE, 10);
		ObjectSet("Previous", OBJPROP_YDISTANCE, curY);
	}
	
	if (dispForecast[0] != "")
	{
		curY = curY + TxtSize + 4;
		if (ObjectFind("Forecast") == -1)
			ObjectCreate("Forecast", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Forecast", "Forecast: " + dispForecast[0], TxtSize, "Arial Bold", TxtColorForecast);
		ObjectSet("Forecast", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Forecast", OBJPROP_XDISTANCE, 10);
		ObjectSet("Forecast", OBJPROP_YDISTANCE, curY); 
	}
	
	
	
	///////////////////////////////////////////////////////////////////////////
	// Do second news event
	if (ShowNextTwoEvents && dispTitle[1] != "")
	{
		sinceUntil = "until ";
		dispMins = dispMinutes[1];
		if (dispMinutes[1] <= 0)
		{
			sinceUntil = "since ";
			dispMins *= -1;
		}

		curY = curY + TxtSize + 20;

		// added the following to show hours and days for longer durations
		// this could be enhanced to suppress 0 hours and 0 minutes
		if (dispMins == 999999)
		{
			TimeStr = " (No more events this week)";
		}
		else if (dispMins < 60)
		{
			TimeStr = dispMins + " mins ";
		}
		else // time is 60 minutes or more
		{
			Hours = MathRound(dispMins / 60);
			Mins = dispMins % 60;
			if (Hours < 24) // less than a day: show hours and minutes 
			{
				TimeStr = Hours + " hrs " + Mins + " mins ";
			}
			else // days, hours, and minutes
			{
				Days = MathRound(Hours / 24);
				Hours = Hours % 24;
				TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
			}
		}
		if (ObjectFind("Minutes2") == -1)
			ObjectCreate("Minutes2", OBJ_LABEL, 0, 0, 0);

		if (dispMins == 999999)
			ObjectSetText("Minutes", TimeStr, TxtSize, "Arial Bold", TxtColorNews);
		else
			ObjectSetText("Minutes2", TimeStr + "until " + dispCountry[1] + ": " + dispTitle[1], TxtSize, "Arial Bold", TxtColorNews);

		ObjectSet("Minutes2", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Minutes2", OBJPROP_XDISTANCE, 10);
		ObjectSet("Minutes2", OBJPROP_YDISTANCE, curY);

		curY = curY + TxtSize + 4;
		if (ObjectFind("Impact2") == -1)
			ObjectCreate("Impact2", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Impact2", "Impact: " + dispImpact[1], TxtSize, "Arial Bold", TxtColorImpact);
		ObjectSet("Impact2", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Impact2", OBJPROP_XDISTANCE, 10);
		ObjectSet("Impact2", OBJPROP_YDISTANCE, curY);

		if (dispPrevious[1] != "")
		{
			curY = curY + TxtSize + 4;
			if (ObjectFind("Previous2") == -1)
				ObjectCreate("Previous2", OBJ_LABEL, 0, 0, 0);
			ObjectSetText("Previous2", "Previous: " + dispPrevious[1], TxtSize, "Arial Bold", TxtColorPrevious);
			ObjectSet("Previous2", OBJPROP_CORNER, NewsCorner);
			ObjectSet("Previous2", OBJPROP_XDISTANCE, 10);
			ObjectSet("Previous2", OBJPROP_YDISTANCE, curY);
		}
		
		if (dispForecast[1] != "")
		{
			curY = curY + TxtSize + 4;
			if (ObjectFind("Forecast2") == -1)
				ObjectCreate("Forecast2", OBJ_LABEL, 0, 0, 0);
			ObjectSetText("Forecast2", "Forecast: " + dispForecast[1], TxtSize, "Arial Bold", TxtColorForecast);
			ObjectSet("Forecast2", OBJPROP_CORNER, NewsCorner);
			ObjectSet("Forecast2", OBJPROP_XDISTANCE, 10);
			ObjectSet("Forecast2", OBJPROP_YDISTANCE, curY); 
		}
	}
	
	return;
}


double ImpactToNumber(string impact)
{
	if (impact == "High")
		return (3);
	if (impact == "Medium")
		return (2);
	if (impact == "Low")
		return (1);
	else
		return (0);
}
   
string MakeDateTime(string strDate, string strTime)
{
	// Print("Converting Forex Factory Time into Metatrader time..."); //added by MN
	// Converts forexfactory time & date into yyyy.mm.dd hh:mm
	int n1stDash = StringFind(strDate, "-");
	int n2ndDash = StringFind(strDate, "-", n1stDash+1);

	string strMonth = StringSubstr(strDate, 0, 2);
	string strDay = StringSubstr(strDate, 3, 2);
	string strYear = StringSubstr(strDate, 6, 4); 
//	strYear = "20" + strYear;
	
	int nTimeColonPos = StringFind(strTime, ":");
	string strHour = StringSubstr(strTime, 0, nTimeColonPos);
	string strMinute = StringSubstr(strTime, nTimeColonPos+1, 2);
	string strAM_PM = StringSubstr(strTime, StringLen(strTime)-2);

	int nHour24 = StrToInteger(strHour);
	if ((strAM_PM == "pm" || strAM_PM == "PM") && nHour24 != 12)
	{
		nHour24 += 12;
	}
	if ((strAM_PM == "am" || strAM_PM == "AM") && nHour24 == 12)
	{
		nHour24 = 0;
	}
 	string strHourPad = "";
	if (nHour24 < 10) 
		strHourPad = "0";

	return(StringConcatenate(strYear, ".", strMonth, ".", strDay, " ", strHourPad, nHour24, ":", strMinute));
}


//=================================================================================================
//=================================================================================================
//====================================   GrabWeb Functions   ======================================
//=================================================================================================
//=================================================================================================
// Main Webscraping function
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// bool GrabWeb(string strUrl, string& strWebPage)
// returns the text of any webpage. Returns false on timeout or other error
// 
// Parsing functions
// ~~~~~~~~~~~~~~~~~
// string GetData(string strWebPage, int nStart, string strLeftTag, string strRightTag, int& nPos)
// obtains the text between two tags found after nStart, and sets nPos to the end of the second tag
//
// void Goto(string strWebPage, int nStart, string strTag, int& nPos)
// Sets nPos to the end of the first tag found after nStart 

bool bWinInetDebug = false;

int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 80;

#import "wininet.dll"

   #define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
   #define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache. 
   #define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.

   int InternetOpenW( string sAgent, int lAccessType, string sProxyName, string sProxyBypass, int lFlags );
   int InternetOpenUrlW(int 	hInternetSession,string 	sUrl,string 	sHeaders="",int 	lHeadersLength=0,int 	lFlags=0,int 	lContext=0);	
   int InternetReadFile(int hFile, uchar &sBuffer[],int lNumBytesToRead,int &lNumberOfBytesRead[]); 
   int InternetCloseHandle(int 	hInet);	

#import

int hSession(bool Direct)
{
	string InternetAgent;
	if (hSession_IEType == 0)
	{
		InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
		hSession_IEType = InternetOpenW(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
		hSession_Direct = InternetOpenW(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
	}
	if (Direct) 
	{ 
		return(hSession_Direct); 
	}
	else 
	{
		return(hSession_IEType); 
	}
}


bool GrabWeb(string strUrl, string& strWebPage)
{
	int 	hInternet;
	int		iResult;
	int 	lReturn[]	= {1};
	uchar sBuffer[1024];
	int 	bytes;
   uint flags=INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_PRAGMA_NOCACHE | INTERNET_FLAG_RELOAD;

   hInternet = InternetOpenUrlW(hSession(FALSE), strUrl, NULL, 0, flags);	
	//hInternet = InternetOpenUrlW(hSession(FALSE), strUrl, "0", 0, 
	//							INTERNET_FLAG_NO_CACHE_WRITE | 
	//							INTERNET_FLAG_PRAGMA_NOCACHE | 
	//							INTERNET_FLAG_RELOAD, 0);
								
	if (bWinInetDebug) 
		Log("hInternet: " + hInternet);   
	if (hInternet == 0) 
		return(false);

	Print("Reading URL: " + strUrl);	   //added by MN	
	iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
	
	if (bWinInetDebug) Log("iResult: " + iResult);
	if (bWinInetDebug) Log("lReturn: " + lReturn[0]);
	if (bWinInetDebug) Log("iResult: " + iResult);
	if (bWinInetDebug) Log("sBuffer: " +  CharArrayToString(sBuffer, 0, lReturn[0]));
	if (iResult == 0)  return(false);
	bytes = lReturn[0];
	strWebPage = CharArrayToString(sBuffer, 0, lReturn[0]);
	
	//If there's more data then keep reading it into the buffer
	while (lReturn[0] != 0)
	   {
		iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
		if (lReturn[0]==0) break;
		bytes = bytes + lReturn[0];
		strWebPage = strWebPage + CharArrayToString(sBuffer, 0, lReturn[0]);
   	}
	Print("Closing URL web connection");   //added by MN
	iResult = InternetCloseHandle(hInternet);
	if (iResult == 0) return(false);		
	
	return(true);
}

//=================================================================================================
//=================================================================================================
//===================================   LogUtils Functions   ======================================
//=================================================================================================
//=================================================================================================

void OpenLog(string strName)
{
	if (!EnableLogging) 
		return;

	if (logHandle <= 0)
	{
		string strMonthPad = "";
 	 	string strDayPad = "";
  		if (Month() < 10) 
  			strMonthPad = "0";
  		if (Day() < 10) 
  			strDayPad = "0";
  			
  		string strFilename = StringConcatenate(strName, "_", Year(), strMonthPad, Month(), strDayPad, Day(), "_log.txt");
  		
		logHandle = FileOpen(strFilename,FILE_CSV|FILE_READ|FILE_WRITE);
		Print("logHandle =================================== ", logHandle);
	}
	if (logHandle > 0)
	{
		FileFlush(logHandle);
		FileSeek(logHandle, 0, SEEK_END);
	}
}


void Log(string msg)
{
	if (!EnableLogging) 
		return;
		
	if (logHandle <= 0) 
		return;
		
	msg = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS) + " " + msg;
	FileWrite(logHandle,msg);
}

//=================================================================================================
//=================================================================================================
//===================================   Timezone Functions   ======================================
//=================================================================================================
//=================================================================================================


#import "kernel32.dll"
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

#define TIME_ZONE_ID_UNKNOWN   0
#define TIME_ZONE_ID_STANDARD  1
#define TIME_ZONE_ID_DAYLIGHT  2

int TZInfoArray[43];	

datetime myTimeGMT() 
{
	int DST = GetTimeZoneInformation(TZInfoArray);
	if (DST == 1)
		DST = 3600;
	else 
		DST = 2;

	return( TimeLocal() + DST + (OffsetHours * 3600) + (TZInfoArray[0] + TZInfoArray[42]) * 60 );
}


//=================================================================================================
//=================================================================================================
//=================================   END IMPORTED FUNCTIONS  =====================================
//=================================================================================================
//=================================================================================================


