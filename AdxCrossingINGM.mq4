//+------------------------------------------------------------------+
//|                                              AdxCrossingINGM.mq4 |
//|                                         Copyright 2020, rpanchyk |
//|       Based on 'ADX Crossing.mq4' from Amir - http://forexbig.ru |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2020, rpanchyk"
#property link        "https://github.com/rpanchyk/mt4-adx-crossing-ind"
#property description "Indicator shows possible entry points by ADX"
#property version     "1.2"
#property strict

#property indicator_chart_window
#property indicator_buffers 2

// input parameters
extern string _010 = "==== Common parameters ====";
extern int maxBars = 400; // Max number of bars to analylize

extern string _020 = "==== ADX parameters ====";
extern int adxPeriod = 14; // Period
extern ENUM_APPLIED_PRICE adxAppliedPrice = PRICE_CLOSE; // Applied price

extern string _030 = "==== Visual parameters ====";
extern int arrowDistance = 10; // Visual distance for arrow
extern int arrowWidth = 1; // Thickness of arrow
extern color buyArrowColor = clrLime; // Color of buy signal arrow
extern color sellArrowColor = clrRed; // Color of sell signal arrow

// buffers
double buyBuffer[];
double sellBuffer[];

// runtime
double b4plusdi;
double nowplusdi;
double b4minusdi;
double nowminusdi;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);

   SetIndexBuffer(0, buyBuffer);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, arrowWidth, buyArrowColor);
   SetIndexArrow(0, 108);

   SetIndexBuffer(1, sellBuffer);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, arrowWidth, sellArrowColor);
   SetIndexArrow(1, 108);

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int availableBars = maxBars >= Bars ? Bars : maxBars;

   SetIndexDrawBegin(0, Bars - availableBars);
   SetIndexDrawBegin(1, Bars - availableBars);

   int countedBars = IndicatorCounted();

   if(countedBars < 0) // check for possible errors
     {
      Print("Error: No counted bars");
      return -1;
     }

   if(countedBars < 1) // initial zero
     {
      for(int i = 1; i <= availableBars; i++)
        {
         buyBuffer[availableBars - i] = 0;
         sellBuffer[availableBars - i] = 0;
        }
     }

   for(int i = availableBars; i >= 0; i--)
     {
      b4plusdi = iADX(NULL, 0, adxPeriod, adxAppliedPrice, MODE_PLUSDI, i - 1);
      nowplusdi = iADX(NULL, 0, adxPeriod, adxAppliedPrice, MODE_PLUSDI, i);
      b4minusdi = iADX(NULL, 0, adxPeriod, adxAppliedPrice, MODE_MINUSDI, i - 1);
      nowminusdi = iADX(NULL, 0, adxPeriod, adxAppliedPrice, MODE_MINUSDI, i);

      if(b4plusdi > b4minusdi && nowplusdi < nowminusdi)
        {
         buyBuffer[i] = Low[i] - arrowDistance * Point;
        }

      if(b4plusdi < b4minusdi && nowplusdi > nowminusdi)
        {
         sellBuffer[i] = High[i] + arrowDistance * Point;
        }
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
