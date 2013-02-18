// HashTable.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"

#include <iostream>
#include <string>
#include <hash_map>

using namespace std;

stdext::hash_map<wstring, wstring> myHash;

//_DLLAPI bool __stdcall Create()
//{
//	return true;
//}

_DLLAPI bool __stdcall Put(const wchar_t* key, const wchar_t* value)
{
	if (key == NULL || value == NULL)
		return false;

	/*FILE * pFile = _wfopen (L"c:\\myfile.txt",L"a");*/
	wstring skey = wstring(key);
	wstring svalue = wstring(value);

	if (myHash.find(skey) == myHash.end())
	{
		myHash[skey] = svalue;
		//fwprintf(pFile, L"Succeed %ls %ls\n", skey, svalue);
		return true;
	}
	else
	{
		//fwprintf(pFile, L"Fail %ls %ls\n", skey, svalue);
		return false;
	}
	//fclose (pFile);
}

_DLLAPI const wchar_t* __stdcall Get(const wchar_t* key)
{
	wstring skey = wstring(key);
	if (myHash.find(skey) == myHash.end())
		return NULL;
	else
		return myHash[skey].c_str();
}

_DLLAPI bool __stdcall IsContain(const wchar_t* key)
{
	wstring skey = wstring(key);
	if (myHash.find(skey) == myHash.end())
		return false;
	else
		return true;
}

_DLLAPI int __stdcall GetSize()
{
	return myHash.size();
}
