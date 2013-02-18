
#include "thread.h"
#include "CApp.h"
#include "CLogWnd.h"
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include "resource.h"
#define lStr(str)	(wmemset(buff_str,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str,sizeof(buff_str)),buff_str)
#define lStr2(str)	(wmemset(buff_str2,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str2,sizeof(buff_str2)),buff_str2)
#define INITLSTR()	wchar_t buff_str[1024];wmemset(buff_str,'\0',1024);wchar_t buff_str2[1024];wmemset(buff_str2,'\0',1024)
extern std::map <HWND,CLogWnd> mLogWnd;
extern CApp App;
extern int semafor;
extern int countThread;
extern CRITICAL_SECTION cs_CountThread;
int semafor;

void TreeViewFindCheck(HTREEITEM parent=NULL,bool force=false);

unsigned int WINAPI ThreadScanFolder(void* pvParam)
{
	EnterCriticalSection(&cs_CountThread);
	countThread++;
	LeaveCriticalSection(&cs_CountThread);
	HTREEITEM hti,child;
	std::vector <std::wstring> vNames;
	hti = (HTREEITEM)pvParam;
	TVITEM tvit;
	bool first=true;
	int prevCountCategory=0;
	wchar_t buff[1024];
	memset(buff,'\0',sizeof(buff));
	tvit.mask = TVIF_TEXT | TVIF_PARAM;
	tvit.pszText = buff;
	tvit.cchTextMax = sizeof(buff);
	tvit.hItem = hti;
	TreeView_GetItem(App.hTreeView,&tvit);
	if (App.vRunSP.end()!=std::find(App.vRunSP.begin(),App.vRunSP.end(),tvit.pszText))
	{
		LeaveCriticalSection(&App.CS_ScanProject);
		semafor=0;
		EnterCriticalSection(&cs_CountThread);
		countThread--;
		LeaveCriticalSection(&cs_CountThread);
		return(0);
	}
	EnterCriticalSection(&App.CS_ScanProject);
	App.vRunSP.push_back(tvit.pszText);
	LeaveCriticalSection(&App.CS_ScanProject);

	while (child=TreeView_GetChild(App.hTreeView,tvit.hItem))
	{
		TreeView_DeleteItem(App.hTreeView,child);
	}
	while (!App.stop)
	{
		
		App.ParseLogFolder(tvit.pszText,hti,vNames);
		if (first)
		{semafor=0;first=false;}
		
		Sleep(5000);
	}
	//Sleep(1000);
	//App.TreeViewAddProject(tvit.pszText,hti);
	EnterCriticalSection(&cs_CountThread);
	countThread--;
	LeaveCriticalSection(&cs_CountThread);
	return (0);
}

unsigned int WINAPI ThreadScanFile(void* pvParam)
{
	INITLSTR();
	EnterCriticalSection(&cs_CountThread);
	countThread++;
	LeaveCriticalSection(&cs_CountThread);
	bool first=true;
	std::map <std::wstring,int> mCateg;
	wchar_t pathFile[10024];
	wmemset(pathFile,'\0',10024);
	wcscat_s(pathFile,10024,App.path);
	wchar_t buff[32768],buffFName[2048],buffProjName[2048];
	wchar_t buffCateg[32768];
	int prevCountCategory=0;
	HTREEITEM hti = (HTREEITEM)pvParam,child=NULL;
	TVITEM tvit;
	wmemset(buff,'\0',32768);
	wmemset(buffFName,'\0',2048);
	wmemset(buffProjName,'\0',2048);
	tvit.mask = TVIF_TEXT | TVIF_PARAM;
	tvit.pszText = buff;
	tvit.cchTextMax = sizeof(buff);
	tvit.hItem = hti;
	TreeView_GetItem(App.hTreeView,&tvit);
	wcscat_s(buffProjName,2048,tvit.pszText);
	
	tvit.hItem = TreeView_GetParent(App.hTreeView,tvit.hItem);
	TreeView_GetItem(App.hTreeView,&tvit);
	wcscat_s(buffFName,2048,tvit.pszText);
	wcscat_s(buffFName,2048,L"\\");
	wcscat_s(buffFName,2048,buffProjName);

	if (App.vRunSF.end()!=std::find(App.vRunSF.begin(),App.vRunSF.end(),buffFName))
	{
		semafor=0;
		EnterCriticalSection(&cs_CountThread);
		countThread--;
		LeaveCriticalSection(&cs_CountThread);
		return(0);
	}
	App.vRunSF.push_back(buffFName);
	wcscat_s(pathFile,10024,buffFName);
	HANDLE file = CreateFileW(pathFile,GENERIC_READ,FILE_SHARE_READ | FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,0,NULL);
	if (file==INVALID_HANDLE_VALUE)
	{	MessageBox(NULL,lStr(UEOPENFILE),lStr2(UERROR),MB_OK);	}
	SetFilePointer(file,2,NULL,FILE_BEGIN);
	DWORD count;
	while (!App.stop)
	{
		wmemset(buff,'\0',32768);
		wmemset(buffCateg,'\0',32768);
		do {
			ReadFile(file,&buff,32768*2,&count,NULL);
			wchar_t tmp[32768];
			wmemset(tmp,L'\0',32768);
			for (int i=0;i<((int)count)/2;i++)
			{
				if (buff[i]==L'\r') {continue;}
				if (buff[i]==L'\n') 
				{ 
					int pos = wcscspn(tmp,L":|:");
					if (pos==wcslen(tmp))
					{	continue;	}
					wcsncpy_s(buffCateg,32768,tmp,pos);
					mCateg[buffCateg]++;
					wmemset(tmp,L'\0',32768); 
					continue;	
				}
				tmp[wcslen(tmp)]=buff[i];
			}
			SetFilePointer(file,(0-wcslen(tmp)*2)-2,0,FILE_CURRENT);
		
		if (App.stop)
		{break;}

		if (prevCountCategory==0)
		{
			child=TreeView_GetChild(App.hTreeView,hti);
			TreeView_DeleteItem(App.hTreeView,child);
		}
		if (mCateg.size()!=0)
		{
			int allCateg = 0;
			wchar_t buffNameLogCategory[1024];
			std::map <std::wstring,int>::iterator iter;
			for (iter=mCateg.begin();iter!=mCateg.end();iter++)
			{
				wmemset(buffNameLogCategory,'\0',1024);
				wcscat_s(buffNameLogCategory,1024,(*iter).first.c_str());
				wcscat_s(buffNameLogCategory,1024,L" (");
				wchar_t tmpBuff[100]; wmemset(tmpBuff,'\0',100); _itow_s((*iter).second,tmpBuff,100,10);
				wcscat_s(buffNameLogCategory,1024,tmpBuff);
				wcscat_s(buffNameLogCategory,1024,L")");
				App.TreeViewAddLog(buffNameLogCategory,hti);

				allCateg += (*iter).second;
			}
			wmemset(buffNameLogCategory,'\0',1024);
			wcscat_s(buffNameLogCategory,1024,L"All");
			wcscat_s(buffNameLogCategory,1024,L" (");
			wchar_t tmpBuff[100]; wmemset(tmpBuff,'\0',100); _itow_s(allCateg,tmpBuff,100,10);
			wcscat_s(buffNameLogCategory,1024,tmpBuff);
			wcscat_s(buffNameLogCategory,1024,L")");
			App.TreeViewAddLog(buffNameLogCategory,hti);
		}
		else
		{
			App.TreeViewAddEmpty(lStr(UEMPTY),hti);
		}
		prevCountCategory=mCateg.size();
		
		}
		while (count==32768*2 && !App.stop);
		if (App.stop)
		{break;}
		if (first)
		{semafor=0;first=false;}
		Sleep(5000);
	}
	CloseHandle(file);
	EnterCriticalSection(&cs_CountThread);
	countThread--;
	LeaveCriticalSection(&cs_CountThread);
	return(0);
}


unsigned int WINAPI LogWindow(void* pvParam)
{
	MSG msg;
	HWND hWnd;
	EnterCriticalSection(&cs_CountThread);
	countThread++;
	LeaveCriticalSection(&cs_CountThread);
	EnterCriticalSection(&App.CS_LogWindow);
	hWnd=CLogWnd::CreateWnd((HTREEITEM)pvParam);
	LeaveCriticalSection(&App.CS_LogWindow);
	_beginthreadex(NULL,0,ThreadParseLogFile,(void *)mLogWnd[hWnd].hWnd,0,NULL);
	while(GetMessage(&msg,0,0,0)==TRUE)
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	EnterCriticalSection(&cs_CountThread);
	countThread--;
	LeaveCriticalSection(&cs_CountThread);
	return(0);
}
unsigned int WINAPI ThreadParseLogFile(void* pvParam)
{
	INITLSTR();
	EnterCriticalSection(&cs_CountThread);
	countThread++;
	LeaveCriticalSection(&cs_CountThread);
	HWND hWnd=(HWND)pvParam;
	wchar_t buff[32768],buffCateg[32768],pathFile[2048];
	wchar_t buffFName[2048],buffProjName[2048],buffFilterCategory[2048];
	TVITEM tvit;
	wmemset(buff,'\0',32768);
	wmemset(buffFName,'\0',2048);
	wmemset(buffProjName,'\0',2048);
	wmemset(buffFilterCategory,'\0',2048);
	
	tvit.mask = TVIF_TEXT | TVIF_PARAM;
	tvit.pszText = buffFilterCategory;
	tvit.cchTextMax = 2048;
	tvit.hItem = mLogWnd[hWnd].hti;
	TreeView_GetItem(App.hTreeView,&tvit);

	
	tvit.mask = TVIF_TEXT | TVIF_PARAM;
	tvit.pszText = buff;
	tvit.cchTextMax = sizeof(buff);
	tvit.hItem = TreeView_GetParent (App.hTreeView,mLogWnd[hWnd].hti);
	TreeView_GetItem(App.hTreeView,&tvit);
	wcscat_s(buffProjName,2048,tvit.pszText);
	
	tvit.hItem = TreeView_GetParent(App.hTreeView,tvit.hItem);
	TreeView_GetItem(App.hTreeView,&tvit);
	wcscat_s(buffFName,2048,tvit.pszText);
	wcscat_s(buffFName,2048,L"\\");
	wcscat_s(buffFName,2048,buffProjName);
	
	wmemset(pathFile,'\0',2048);
	wcscat_s(pathFile,2048,App.path);
	wcscat_s(pathFile,2048,buffFName);
	SendMessage(mLogWnd[hWnd].hWnd,WM_SETTEXT,0,(LPARAM)pathFile);
	HANDLE file = CreateFileW(pathFile,GENERIC_READ,FILE_SHARE_READ | FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,0,NULL);
	if (file==INVALID_HANDLE_VALUE)
	{	MessageBox(NULL,lStr(UEOPENFILE),lStr2(UERROR),MB_OK |MB_ICONERROR);	}
	SetFilePointer(file,2,NULL,FILE_BEGIN);
	DWORD count;
	while (!mLogWnd[hWnd].exit && !App.stop)
	{
		wmemset(buff,'\0',32768);
		wmemset(buffCateg,'\0',32768);
		do {
			ReadFile(file,&buff,32768*2,&count,NULL);
			wchar_t tmp[32768];
			wmemset(tmp,L'\0',32768);
			for (int i=0;i<((int)count)/2;i++)
			{
				if (buff[i]==L'\r') {continue;}
				if (buff[i]==L'\n') 
				{ 
					int pos = wcscspn(tmp,L":|:");
					if (pos==wcslen(tmp))
					{	continue;	}
					wcsncpy_s(buffCateg,32768,tmp,pos);
					// here we do something with line
					bool in = _wcsnicmp(buffCateg,buffFilterCategory,wcscspn(buffFilterCategory,L"(")-1)==0
						&& wcslen(buffCateg) == wcscspn(buffFilterCategory,L"(")-1;
					if (!in)
					{
						wmemset(buffCateg,'\0',32768);
						wcsncpy_s(buffCateg,32768,L"All",3);
						in = _wcsnicmp(buffCateg,buffFilterCategory,wcscspn(buffFilterCategory,L"(")-1)==0
							&& wcslen(buffCateg) == wcscspn(buffFilterCategory,L"(")-1;
					}
					if (in)
					{ 
						mLogWnd[hWnd].vList.push_back(tmp); 
					}
					//
					wmemset(tmp,L'\0',32768); 
					continue;	
				}
				tmp[wcslen(tmp)]=buff[i];
			}
			SetFilePointer(file,(0-wcslen(tmp)*2)-2,0,FILE_CURRENT);
			}
		while (count==32768*2 && !mLogWnd[hWnd].exit && !App.stop);
		ListView_SetItemCountEx(mLogWnd[hWnd].hListView,mLogWnd[hWnd].vList.size(),LVSICF_NOSCROLL);
		if (SendMessage(mLogWnd[hWnd].hToolBar,TB_ISBUTTONCHECKED,124,0))
		{	
			ListView_EnsureVisible(mLogWnd[hWnd].hListView,mLogWnd[hWnd].vList.size()-1,TRUE);	
		}
		Sleep(1000);
	}
	CloseHandle(file);
	SendMessage(hWnd,WM_DESTROY,0,0);
	//DestroyWindow(hWnd);
	mLogWnd.erase(hWnd);
	EnterCriticalSection(&cs_CountThread);
	countThread--;
	LeaveCriticalSection(&cs_CountThread);
	return (0);
}

unsigned int WINAPI ThreadPrepareMon(void* pvParam)
{
	App.ShowTrayIcon();
	TreeViewFindCheck ();
	App.readyMon=true;
	return (0);
}

unsigned int WINAPI ThreadAlert(void* pvParam)
{
	if (!App.readyMon)
	{return(0);}
	HTREEITEM hti = (HTREEITEM) pvParam;
	App.readyMon=false;
	ShowWindow(App.hWnd,SW_SHOW);
	ShowWindow(App.hWnd,SW_RESTORE);
	SetForegroundWindow(App.hTreeView);
	App.DeleteTrayIcon();
	int sleep=100;
	App.alert=true;
	TreeView_EnsureVisible(App.hTreeView,hti);
	TreeView_Select(App.hTreeView,hti,TVGN_CARET);
	while (App.alert)
	{
		if (::GetFileAttributes(L"alert.wav") != DWORD(-1))
		{	
			PlaySound(L"alert.wav", NULL, SND_FILENAME | SND_SYNC);
		}
		else
		{
			PlaySound(MAKEINTRESOURCE(IDR_WAVE1), NULL, SND_RESOURCE | SND_SYNC);	
		}
		
		Sleep(sleep+=1000);
		TreeView_EnsureVisible(App.hTreeView,hti);
		TreeView_Select(App.hTreeView,hti,TVGN_CARET);
	}
	return(0);
}

