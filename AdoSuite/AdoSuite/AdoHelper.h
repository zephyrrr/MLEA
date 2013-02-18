using namespace System;

//-----------------------------------------------------------------------
enum ENUM_ADOTYPES
{
   ADOTYPE_BOOL      = 1,
   ADOTYPE_LONG      = 2,
   ADOTYPE_DOUBLE    = 3,
   ADOTYPE_STRING    = 4,
   ADOTYPE_DATETIME  = 5
};

//-----------------------------------------------------------------------
ref class AdoHelper
{
public:
	static int GetAdoType(Object^ o)
	{
		if (o == nullptr) return -1;
		return GetAdoType(o->GetType());
	}

	static int GetAdoType(Type^ t)
	{
		String^ name = t->Name;

		if (name->Contains("Int") || name == "Byte") return ADOTYPE_LONG;
		if (name == "String") return ADOTYPE_STRING;
		if (name == "Boolean") return ADOTYPE_BOOL;
		if (name == "Single" || name == "Double" || name == "Decimal") return ADOTYPE_DOUBLE;
		if (name == "DateTime") return ADOTYPE_DATETIME;

		return -1;
	}
};