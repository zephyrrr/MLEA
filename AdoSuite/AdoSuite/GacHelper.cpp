#include "stdafx.h"
#include "GacHelper.h"

//---------------------------------------------------------------------
wchar_t* GetFullAssemblyName(const wchar_t* shortName)
{
	if (shortName == NULL) return NULL;

	wchar_t* result = L"";
	
	// defining functions
	HMODULE g_FusionDll = NULL;
	CreateAsmCache g_pfnCreateAssemblyCache = NULL;
	CreateAsmNameObj g_pfnCreateAssemblyNameObject = NULL;
	CreateAsmEnum g_pfnCreateAssemblyEnum = NULL;

	// importing functions
	LoadLibraryShim(L"fusion.dll", 0, 0, &g_FusionDll);
	g_pfnCreateAssemblyCache = (CreateAsmCache)GetProcAddress(g_FusionDll, "CreateAssemblyCache");
	g_pfnCreateAssemblyNameObject = (CreateAsmNameObj)GetProcAddress(g_FusionDll, "CreateAssemblyNameObject");
	g_pfnCreateAssemblyEnum = (CreateAsmEnum)GetProcAddress(g_FusionDll, "CreateAssemblyEnum");
	 
	// defining neccessary variables
	LPWSTR pszAssemblyName = (LPWSTR)shortName;
	IAssemblyName*  pNameFilter = NULL;
	IAssemblyEnum* pEnum = NULL;
	IAssemblyName* pAsmName = NULL;
	DWORD  dwDisplayFlags = ASM_DISPLAYF_VERSION
							| ASM_DISPLAYF_CULTURE
							| ASM_DISPLAYF_PUBLIC_KEY_TOKEN;
	DWORD dwLen = 0;
	LPWSTR szDisplayName = NULL;
	 
	// creating a filter for our assembly name
	g_pfnCreateAssemblyNameObject(&pNameFilter, pszAssemblyName, CANOF_PARSE_DISPLAY_NAME, NULL);
	 
	// create the IAssemblyEnum for GAC
	g_pfnCreateAssemblyEnum(&pEnum, NULL, pNameFilter, ASM_CACHE_GAC,  NULL);
	 
	// enumerating matching assemblies
	while (pEnum->GetNextAssembly(NULL, &pAsmName, 0) == S_OK)
	{
		dwLen = 0;
		pAsmName->GetDisplayName(NULL, &dwLen, dwDisplayFlags);
		
		szDisplayName = new WCHAR[dwLen];
		pAsmName->GetDisplayName(szDisplayName, &dwLen, dwDisplayFlags);

		result = (wchar_t*)szDisplayName;

		pAsmName->Release();
	}

	// releasing resources
	pEnum->Release();
	pNameFilter->Release();
	FreeLibrary(g_FusionDll);

	return result;
}

