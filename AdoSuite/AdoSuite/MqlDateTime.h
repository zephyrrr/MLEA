using namespace System;
using namespace System::Runtime::InteropServices;

[StructLayout(LayoutKind::Sequential)]
value class MqlDateTime
{
public:
	Int32 year;
	Int32 mon;
	Int32 day;
	Int32 hour;
	Int32 min;
	Int32 sec;
	Int32 day_of_week;
	Int32 day_of_year;

	static MqlDateTime FromDateTime(DateTime t)
	{
		MqlDateTime m;
		m.year = t.Year;
		m.mon = t.Month;
		m.day = t.Day;
		m.hour = t.Hour;
		m.min = t.Minute;
		m.sec = t.Second;
		m.day_of_week = (int)t.DayOfWeek;
		m.day_of_year = t.DayOfYear;
		return m;
	}

	DateTime ToDateTime()
	{
		return DateTime(year, mon, day, hour, min, sec);
	}
};