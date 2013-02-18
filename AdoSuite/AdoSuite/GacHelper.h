#include "mscoree.h"
#include "fusion.h"

typedef HRESULT (__stdcall *CreateAsmCache)(IAssemblyCache **ppAsmCache, DWORD dwReserved);
typedef HRESULT (__stdcall *CreateAsmNameObj)(LPASSEMBLYNAME *ppAssemblyNameObj, LPCWSTR szAssemblyName, DWORD dwFlags, LPVOID pvReserved);
typedef HRESULT (__stdcall *CreateAsmEnum)(IAssemblyEnum **pEnum, IUnknown *pAppCtx, IAssemblyName *pName, DWORD dwFlags, LPVOID pvReserved);

wchar_t* GetFullAssemblyName(const wchar_t* shortName);