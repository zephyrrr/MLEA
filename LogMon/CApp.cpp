#define WM_TRAYMSG (WM_APP+1)

//#include "windows.h"
//#include <commctrl.h>
#include "resource.h"
#include "thread.h"
//#include <string>
#define lStr(str)	(wmemset(buff_str,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str,sizeof(buff_str)),buff_str)
#define lStr2(str)	(wmemset(buff_str2,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str2,sizeof(buff_str2)),buff_str2)
#define INITLSTR()	wchar_t buff_str[1024];wmemset(buff_str,'\0',1024);wchar_t buff_str2[1024];wmemset(buff_str2,'\0',1024)
#include "CApp.h"
extern int countThread;
unsigned int WINAPI ThreadAlert(void* pvParam);
CApp::CApp(void)
{
	ZeroMemory(path,sizeof(path));
	//ZeroMemory(buff,sizeof(buff));
	file = NULL;
	readyMon = false;
	InitializeCriticalSection(&CS_ScanProject);
	InitializeCriticalSection(&CS_ScanFile);
	InitializeCriticalSection(&CS_LogWindow);
	//InitializeCriticalSection(&CS_TreeView);
}

CApp::~CApp(void)
{
	DeleteCriticalSection(&CS_ScanProject);
	DeleteCriticalSection(&CS_ScanFile);
	DeleteCriticalSection(&CS_LogWindow);
	//DeleteCriticalSection(&CS_TreeView);
}

void CApp::CreateRichEdit(HWND hwndOwner,int x,int y,int width, int height,DWORD dwStyle,HINSTANCE hinst)
{
    LoadLibrary(L"RICHED20.DLL");
	hRichEdit = CreateWindowEx(0, RICHEDIT_CLASS, L"Empty",
		dwStyle, 
        x, y, width, height, 
        hwndOwner, NULL, hinst, NULL);
	CreateWindow(L"button", L"Press me", WS_CHILD|WS_VISIBLE|BS_AUTOCHECKBOX,
        2, 2, 80, 20, hWnd, (HMENU)10001, hinst, NULL);
	
}

void CApp::CreateWnd(HINSTANCE hInstance,LPSTR lpCmdLine,int nShowCmd,WNDPROC WndProc)
{
	WNDCLASSEX wndclass;
	hIns = hInstance;
	wndclass.cbSize = sizeof(WNDCLASSEX);        // Size of structure
	wndclass.style = CS_HREDRAW | CS_VREDRAW;    // Style
	wndclass.lpfnWndProc = WndProc;              // Pointer to function of processing messages
	wndclass.cbWndExtra = 0;                     // Junk
	wndclass.cbClsExtra = 0;                     // Junk
	wndclass.hInstance = hInstance;              // Reference to program instance 
	wndclass.hIcon = LoadIcon(0,IDI_WARNING);    // Icon
	wndclass.hCursor = LoadCursor(0,IDC_ARROW);  // Cursor
	wndclass.hbrBackground = static_cast<HBRUSH>(GetStockObject(LTGRAY_BRUSH)); // Brush
	wndclass.lpszMenuName = 0;                   // Menu resource name
	wndclass.lpszClassName = L"profWndClass";
	wndclass.hIconSm = NULL;                     // Small icon
	
	RegisterClassEx(&wndclass);                  // Register window class 
	
   hWnd=CreateWindowW(                          // Create window
		L"profWndClass",
		L"LogMon",
		WS_OVERLAPPEDWINDOW,
		100,
		200,
		300,
		400,
		0,
		0,
		hInstance,
		0	);
	GetClientRect(hWnd,&rect);                   // Get window size
	GetCurrentDirectory(10024,path);             // Remember current folder
	wcscat_s(path,10024,L"\\Files\\log\\");
	ShowWindow(hWnd,nShowCmd);

	/*HWND hwndButton = CreateWindow( 
    L"BUTTON",   // Predefined class; Unicode assumed. 
    L"OK",       // Button text. 
    WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,  // Styles. 
    10,         // x position. 
    10,         // y position. 
    100,        // Button width.
    100,        // Button height.
    hWnd,       // Parent window.
    NULL,       // No menu.
	hIns, 
    NULL);      // Pointer not needed.*/
}

void CApp::CreateTreeView()
{
	hTreeView = CreateWindowEx(0,WC_TREEVIEW,TEXT("Tree View"),
		WS_VISIBLE | WS_CHILD | WS_BORDER | TVS_HASLINES | TVS_CHECKBOXES | TVS_SHOWSELALWAYS, 
        0,44,rect.right,rect.bottom-44,hWnd, 
		NULL,hIns,NULL);
	HBITMAP hBitMap;                                         // Bitmap handler
	HIMAGELIST hImageList;                                   // List of images
	hImageList=ImageList_Create(16,16,ILC_COLOR16,4,10);     // Create list of images
	hBitMap=LoadBitmap(hIns,MAKEINTRESOURCE(IDB_TREE));      // Load picture from the resource
    ImageList_Add(hImageList,hBitMap,NULL);
	DeleteObject(hBitMap);                                   // Delete icon

	hBitMap=LoadBitmap(hIns,MAKEINTRESOURCE(IDB_BITMAP1));   // Load picture from the resource
    ImageList_Add(hImageList,hBitMap,NULL);
	DeleteObject(hBitMap);

	hBitMap=LoadBitmap(hIns,MAKEINTRESOURCE(IDB_BITMAP2));   // Load picture from the resource
    ImageList_Add(hImageList,hBitMap,NULL);
	DeleteObject(hBitMap);

	hBitMap=LoadBitmap(hIns,MAKEINTRESOURCE(IDB_BITMAP3));   // Load picture from the resource
    ImageList_Add(hImageList,hBitMap,NULL);
	DeleteObject(hBitMap);
	// Match list of images and TreeView
	TreeView_SetImageList(hTreeView,hImageList,TVSIL_NORMAL);
	
}

void CApp::CreateToolBar()
{
	TBBUTTON tbButtons[]=
	{
		{100, 123,  TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0},
		{0, 123,  TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0},
		{3, 126,  TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0},
		{2, 125,  TBSTATE_ENABLED, TBSTYLE_CHECK, 0L, 0},
		{1, 124,  TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	};
	hToolBar = CreateWindowEx(0, TOOLBARCLASSNAME, NULL, 
		WS_CHILD | WS_BORDER | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
		0, 0, 0, 44, hWnd, 
		(HMENU) 0, hIns, NULL);
	SendMessage(hToolBar, TB_BUTTONSTRUCTSIZE, 
				(WPARAM) sizeof(TBBUTTON), 0);
	HIMAGELIST hImageList = ImageList_Create(32, 32, ILC_COLOR32 | ILC_MASK, 4, 0);
	HBITMAP bitmap;
	bitmap = LoadBitmap(hIns,MAKEINTRESOURCE(IDB_TBDESTROY));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);

	bitmap = LoadBitmap(hIns,MAKEINTRESOURCE(IDB_TBMON));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);
	
	bitmap = LoadBitmap(hIns,MAKEINTRESOURCE(IDB_TBTOP));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);
	
	bitmap = LoadBitmap(hIns,MAKEINTRESOURCE(IDB_BITMAPABOUT));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);
	
	SendMessage(hToolBar, TB_SETIMAGELIST, 0, (LPARAM)hImageList);
	
	SendMessage(hToolBar, TB_ADDBUTTONS, (WPARAM)5, 
	(LPARAM)&tbButtons);
	SendMessage(                  // returns LRESULT in lResult
        hToolBar,                // handle to destination control
        TB_SETBUTTONSIZE,        // message ID
        (WPARAM) 0,              // = 0; not used, must be zero 
        (LPARAM) MAKELONG(32,32) // = (LPARAM) MAKELONG (dxButton, dyButton)
        );
	SendMessage(App.hToolBar,TB_AUTOSIZE,0,0);
	GetWindowRect(hWnd,&rect);
	SetWindowPos(hWnd,0,0,0,rect.right-rect.left+4,rect.bottom-rect.top,SWP_NOZORDER | SWP_NOMOVE);
}


void CApp::TreeViewAddProject(const wchar_t *name,HTREEITEM parent,int parentIcon,int childIcon)
{
	INITLSTR();
	TVINSERTSTRUCT tvInsertStruct;
	TVITEM tvItem;
	HTREEITEM locParent;
	
	tvInsertStruct.hInsertAfter = TVI_LAST;
	tvInsertStruct.hParent = parent;
	tvItem.mask = TVIF_TEXT | TVIF_PARAM | TVIF_IMAGE | TVIF_SELECTEDIMAGE;
	tvItem.lParam = (parent==TVI_ROOT)?(LPARAM)10:(LPARAM)20;
	tvItem.iImage = (parent==TVI_ROOT)?0:1;
	tvItem.iSelectedImage = (parent==TVI_ROOT)?0:1;
	tvItem.pszText = const_cast <LPWSTR>(name);
	tvItem.cchTextMax = wcslen(name);
	tvInsertStruct.item = tvItem;
	locParent=TreeView_InsertItem(hTreeView,&tvInsertStruct);

	if (parent!=TVI_ROOT && TreeView_GetCheckState(App.hTreeView,parent)==1)
	{
		_beginthreadex(NULL,0,ThreadAlert,(void *)locParent,0,NULL);
	}

	// Insert empty element for visual aid
	tvInsertStruct.hInsertAfter = TVI_SORT;
	tvInsertStruct.hParent = locParent;
	tvItem.mask = TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
	tvItem.lParam = (LPARAM)0;
	tvItem.pszText = lStr(USCAN);
	tvItem.cchTextMax = wcslen(lStr(USCAN));
	tvItem.iImage = 1;
	tvItem.iSelectedImage = 1;
	tvInsertStruct.item = tvItem;
	TreeView_InsertItem(hTreeView,&tvInsertStruct);
}

void CApp::TreeViewAddEmpty(const wchar_t *name,HTREEITEM parent)
{
	TVINSERTSTRUCT tvInsertStruct;
	TVITEM tvItem;
	HTREEITEM locParent;
	tvInsertStruct.hInsertAfter = TVI_SORT;
	tvInsertStruct.hParent = parent;
	tvItem.mask = TVIF_TEXT | TVIF_PARAM | TVIF_IMAGE | TVIF_SELECTEDIMAGE;
	tvItem.lParam = (LPARAM)0;
	tvItem.iImage = 2;
	tvItem.iSelectedImage = 2;
	tvItem.pszText = const_cast <LPWSTR>(name);
	tvItem.cchTextMax = wcslen(name);
	tvInsertStruct.item = tvItem;
	locParent=TreeView_InsertItem(hTreeView,&tvInsertStruct);
}

void CApp::TreeViewAddLog(const wchar_t *name, HTREEITEM parent)
{
	TVINSERTSTRUCT tvInsertStruct;
	TVITEM tvItem;
	ZeroMemory(&tvItem,sizeof(TVITEM));
	HTREEITEM hti;
	wchar_t buff[2048]; wmemset(buff,'\0',2048);
	

	if (hti=TreeView_GetChild(App.hTreeView,parent))
	{
		do
		{
			tvItem.mask = TVIF_HANDLE | TVIF_TEXT;
			tvItem.hItem = hti;
			tvItem.pszText = buff;
			tvItem.cchTextMax = 2048;
			TreeView_GetItem(App.hTreeView,&tvItem);
			if (wcsncmp(tvItem.pszText,name,wcscspn(name,L"("))==0)
			{
				if (wcscmp(tvItem.pszText,name)==0)
				{	return;	}
				tvItem.mask = TVIF_TEXT;
				tvItem.pszText = const_cast <LPWSTR>(name);
				tvItem.cchTextMax = 2048;
				TreeView_SetItem(App.hTreeView,&tvItem);
				if (TreeView_GetCheckState(App.hTreeView,hti)==1 ||
					TreeView_GetCheckState(App.hTreeView,
					TreeView_GetParent(App.hTreeView, hti))==1 ||
					TreeView_GetCheckState(App.hTreeView,
					TreeView_GetParent(App.hTreeView, TreeView_GetParent(App.hTreeView,hti)))==1
					)
				{
					_beginthreadex(NULL,0,ThreadAlert,(void *)hti,0,NULL);
				}
				return;
			}
		}
		while(hti=TreeView_GetNextSibling(App.hTreeView,hti));
	}
	
	tvInsertStruct.hInsertAfter = TVI_SORT;
	tvInsertStruct.hParent = parent;
	tvItem.mask = TVIF_TEXT | TVIF_PARAM | TVIF_IMAGE | TVIF_SELECTEDIMAGE;
	tvItem.lParam = (LPARAM)30;
	tvItem.iImage = 3;
	tvItem.iSelectedImage = 3;
	tvItem.pszText = const_cast <LPWSTR>(name);
	tvItem.cchTextMax = wcslen(name);
	tvInsertStruct.item = tvItem;
	hti=TreeView_InsertItem(hTreeView,&tvInsertStruct);
	if (TreeView_GetCheckState(App.hTreeView,hti)==1 ||
		TreeView_GetCheckState(App.hTreeView,
		TreeView_GetParent(App.hTreeView, hti))==1 ||
		TreeView_GetCheckState(App.hTreeView,
		TreeView_GetParent(App.hTreeView, TreeView_GetParent(App.hTreeView,hti)))==1
		)
	{
		_beginthreadex(NULL,0,ThreadAlert,(void *)hti,0,NULL);
	}
}


void CApp::TreeViewDelFile(HTREEITEM hti)
{
	INITLSTR();
	TVITEM tvit;
	tvit.mask = TVIF_TEXT | TVIF_PARAM;
	wchar_t buffName[1024]; wmemset(buffName,'\0',1024);
	wchar_t buffFileName[1024]; wmemset(buffFileName,'\0',1024);
	wchar_t buffTmpFileName[1024]; wmemset(buffTmpFileName,'\0',1024);
	SHFILEOPSTRUCT fo;
	if (hti!=0)
	{
		ZeroMemory(&fo, sizeof(fo));
		fo.hwnd   = App.hWnd;  // Handle of progress dialog parent window
		fo.wFunc  = FO_DELETE;
		fo.fFlags = FOF_NOCONFIRMATION;
	
		tvit.pszText = buffName;
		tvit.cchTextMax = 1024;
		tvit.hItem = hti;
		wcscat_s(buffFileName,1024,path);
		TreeView_GetItem(App.hTreeView,&tvit);
		if (tvit.lParam == 10)
		{
			wcscat_s(buffFileName,1024,buffName);	
		}
		if (tvit.lParam == 30)
		{
			tvit.hItem = TreeView_GetParent(App.hTreeView,tvit.hItem);
			TreeView_GetItem(App.hTreeView,&tvit);
		}
		if (tvit.lParam > 10)
		{
			wcscpy_s (buffTmpFileName,1024,buffName);
			tvit.hItem = TreeView_GetParent(App.hTreeView,tvit.hItem);
			TreeView_GetItem(App.hTreeView,&tvit);
			wcscat_s(buffFileName,1024,buffName);
			wcscat_s(buffFileName,1024,L"\\");
			wcscat_s(buffFileName,1024,buffTmpFileName);
		}

		
	}
	stop=true;
	while (countThread!=0)
	{Sleep(500);}
	stop = false;
	
	if (hti!=0)
	{
		wmemset(buffFileName+wcslen(buffFileName),'\0',2);
		fo.pFrom = buffFileName;
		int res=SHFileOperation(&fo);
		if (res!=0)
		{	MessageBox(App.hWnd,lStr(UEDELETE),lStr2(UERROR),MB_OK | MB_ICONERROR);	}
	}
	TreeView_DeleteAllItems(App.hTreeView);
	App.vRunSF.clear();
	App.vRunSP.clear();
	App.ParseMainFolder();
}


void CApp::ParseMainFolder()
{
	WIN32_FIND_DATA fd;
	wchar_t root[10024];
	wmemset(root,'\0',10024);
	wcscpy_s(root,10024,path);
	wcscat_s(root,1024,L"log_*");
	HANDLE hFind=::FindFirstFile(root, &fd);
	INITLSTR();
    if(hFind != INVALID_HANDLE_VALUE)
    {
        do{
            if ((fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			{
				this->TreeViewAddProject(fd.cFileName);
			}
		}while(::FindNextFile(hFind, &fd));

        ::FindClose(hFind);
    }
	else
	{
		this->TreeViewAddEmpty(lStr(UNFOUNDFOLDER));
	}
}

void CApp::ParseLogFolder(const wchar_t *projectName,HTREEITEM hti,std::vector<std::wstring> &vNames)
{
	WIN32_FIND_DATA fd;
	HTREEITEM child;
	wchar_t root[10024];
	wmemset(root,'\0',10024);
	wcscpy_s(root,10024,path);
	wcscat_s(root,1024,projectName); 
	wcscat_s(root,2024,L"\\log_*");
	HANDLE hFind=::FindFirstFile(root, &fd);
	INITLSTR();
    if(hFind != INVALID_HANDLE_VALUE)
    {
        do{
            if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			{
				if (vNames.size()==0)
				{
					child=TreeView_GetChild(App.hTreeView,hti);
					if (child!=NULL)
					TreeView_DeleteItem(App.hTreeView,child);
				}
				if (vNames.end()==std::find(vNames.begin(),vNames.end(),fd.cFileName))
				{
					vNames.push_back(fd.cFileName);
					this->TreeViewAddProject(fd.cFileName,hti);
				}
			}
		}while(::FindNextFile(hFind, &fd));
		::FindClose(hFind);
    }
	else
	{
		child=TreeView_GetChild(App.hTreeView,hti);
		if (child!=NULL)
		TreeView_DeleteItem(App.hTreeView,child);
		this->TreeViewAddEmpty(lStr(UEMPTY),hti);
	}

}

void CApp::ShowTrayIcon(void)
{
	memset(&NotifyIconData, 0, sizeof(NOTIFYICONDATA));
	NotifyIconData.cbSize = sizeof(NOTIFYICONDATA);
	NotifyIconData.hWnd = hWnd;
	NotifyIconData.uID = 123;
	NotifyIconData.uFlags = NIF_ICON | NIF_MESSAGE;
	NotifyIconData.uCallbackMessage = WM_TRAYMSG;
	NotifyIconData.hIcon = LoadIcon(hIns, MAKEINTRESOURCE(IDI_ICON1));
	Shell_NotifyIcon(NIM_ADD, &NotifyIconData);
}

void CApp::DeleteTrayIcon(void)
{
	Shell_NotifyIcon(NIM_DELETE, &NotifyIconData);
	DestroyIcon(NotifyIconData.hIcon);
}

