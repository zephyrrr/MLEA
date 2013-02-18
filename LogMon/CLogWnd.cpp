#define WND mLogWnd[hWnd]

#include "CLogWnd.h"
#include "CApp.h"
#include "uxtheme.h"
#include "resource.h"
#include <algorithm>
#define lStr(str)	(wmemset(buff_str,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str,sizeof(buff_str)),buff_str)
#define lStr2(str)	(wmemset(buff_str2,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str2,sizeof(buff_str2)),buff_str2)
#define INITLSTR()	wchar_t buff_str[1024];wmemset(buff_str,'\0',1024);wchar_t buff_str2[1024];wmemset(buff_str2,'\0',1024)
extern std::map <HWND,CLogWnd> mLogWnd;
LRESULT CALLBACK WndProcViewLog(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM lParam );

LRESULT CALLBACK WndProcSubClass(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM lParam );

CLogWnd::CLogWnd(void)
{
	hWnd=NULL;
}
CLogWnd::~CLogWnd(void)
{
	
}
HWND CLogWnd::CreateWnd(HTREEITEM hti)
{
	INITLSTR();
	WNDCLASSEX wndclass;
	wndclass.cbSize = sizeof(WNDCLASSEX);        // Size of structure
	wndclass.style = CS_HREDRAW | CS_VREDRAW;    // Style
	wndclass.lpfnWndProc = WndProcViewLog;       // Pointer to function of processing messages
	wndclass.cbWndExtra = 0;                     // Junk
	wndclass.cbClsExtra = 0;                     // Junk
	wndclass.hInstance = App.hIns;               // Reference to program instance 
	wndclass.hIcon = LoadIcon(0,IDI_WARNING);    // Icon
	wndclass.hCursor = LoadCursor(0,IDC_ARROW);  // Cursor
	wndclass.hbrBackground = static_cast<HBRUSH>(GetStockObject(LTGRAY_BRUSH)); //Brush
	wndclass.lpszMenuName = 0;                   // Menu resource name
	wndclass.lpszClassName = L"profWndClassLogWnd";
	wndclass.hIconSm = NULL;                     // Small icon
	
   RegisterClassEx(&wndclass);                  // Register window class 
	
	HWND hWnd;                                   // Create window
	hWnd=CreateWindowW( 
		L"profWndClassLogWnd",
		L"LogWnd",
		WS_OVERLAPPEDWINDOW,
		410,
		110,
		650,
		450,
		0,
		0,
		App.hIns,
		0	);
	mLogWnd[hWnd].hWnd=hWnd;                     // Create CLogWnd instance
	mLogWnd[hWnd].hti = hti;
	ShowWindow(hWnd,1);
	mLogWnd[hWnd].hListView=CreateWindowEx(NULL,WC_LISTVIEW,L"",
		WS_VISIBLE | WS_CHILD | WS_BORDER | LVS_OWNERDATA | LVS_REPORT  | LVS_SINGLESEL | LVS_SHOWSELALWAYS,
		0,0,200,400,hWnd,0,App.hIns,0);
	ListView_SetExtendedListViewStyleEx(mLogWnd[hWnd].hListView,LVS_EX_DOUBLEBUFFER | LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES,LVS_EX_DOUBLEBUFFER | LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES);
	LVCOLUMN lcol;
	lcol.mask = LVCF_TEXT | LVCF_WIDTH;
	lcol.pszText = lStr(ULOGMSG);
	lcol.cchTextMax = wcslen(lStr(ULOGMSG));
	lcol.cx = 200;
	ListView_InsertColumn(mLogWnd[hWnd].hListView,0,&lcol);
	ListView_SetItemCount(mLogWnd[hWnd].hListView,0);
	ShowWindow(mLogWnd[hWnd].hListView,1);
	
	mLogWnd[hWnd].CreateLogToolBar();
	mLogWnd[hWnd].exit=false;
	
	return(hWnd);
}

void CLogWnd::CreateLogToolBar()
{
	INITLSTR();
	TBBUTTON tbButtons[]=
	{
		{200, 0,  TBSTATE_ENABLED, BTNS_SEP, 0L, 0},
		{0, 123,  TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0},
		{2, 125,  TBSTATE_ENABLED, TBSTYLE_CHECK, 0L, 0},
		{1, 124,  TBSTATE_ENABLED, TBSTYLE_CHECK, 0L, 0}

		
	};
	hToolBar = CreateWindowEx(0, TOOLBARCLASSNAME, NULL, 
		WS_CHILD | WS_BORDER | WS_VISIBLE | TBSTYLE_TOOLTIPS | TBSTYLE_AUTOSIZE | CCS_ADJUSTABLE,
		0, 0, 0, 24, hWnd, 
		(HMENU) 0, App.hIns, NULL);
	//FIND TEXT CONTROL
	hFindText = CreateWindowEx(WS_EX_CLIENTEDGE, L"edit", lStr(UFIND), WS_CHILD | WS_VISIBLE | ES_RIGHT,
		10, 2, 150, 20, hToolBar, (HMENU)10000, App.hIns, NULL);
	//SetWindowPos(hFindText,HWND_DESKTOP,0,0,0,0,SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
	SendMessage(hToolBar, TB_BUTTONSTRUCTSIZE, 
				(WPARAM) sizeof(TBBUTTON), 0);
	HIMAGELIST hImageList = ImageList_Create(16, 16, ILC_COLOR32 | ILC_MASK, 3, 0);
	HBITMAP bitmap;
	bitmap = LoadBitmap(App.hIns,MAKEINTRESOURCE(IDB_FINDBUTTON));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);
	
	bitmap = LoadBitmap(App.hIns,MAKEINTRESOURCE(IDB_ASCROLL));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);
	
	bitmap = LoadBitmap(App.hIns,MAKEINTRESOURCE(IDB_TBTOP16));
	ImageList_Add(hImageList,bitmap,NULL);
	DeleteObject(bitmap);

	SendMessage(hToolBar, TB_SETIMAGELIST, 0, (LPARAM)hImageList);
	
	SendMessage(hToolBar, TB_ADDBUTTONS, (WPARAM)4, 
	(LPARAM)&tbButtons);
	SendMessage(           // returns LRESULT in lResult
        hToolBar,              // handle to destination control
        TB_SETBUTTONSIZE,         // message ID
        (WPARAM) 0,                 // = 0; not used, must be zero 
        (LPARAM) MAKELONG(16,16)                  // = (LPARAM) MAKELONG (dxButton, dyButton)
        );
	SendMessage(hToolBar,TB_AUTOSIZE,0,0);
	wndProc = SetWindowLong(hFindText,GWL_WNDPROC,(LONG)WndProcSubClass);
	RECT rect;
	GetWindowRect(hWnd,&rect);
	CreateProgressBar();
	SetWindowPos(hWnd,0,0,0,rect.right-rect.left+4,rect.bottom-rect.top,SWP_NOZORDER | SWP_NOMOVE);
	
}

void CLogWnd::CreateProgressBar()
{
	RECT rect;
	GetWindowRect(hFindText,&rect);
	hProgressBar = CreateWindowW(PROGRESS_CLASS,L"",WS_CHILD,
		0,0,
		rect.right-rect.left,rect.bottom-rect.top,hToolBar,(HMENU)12210,App.hIns,0);
	SendMessage(hProgressBar,PBM_SETSTATE,PBST_NORMAL,0);
	SendMessage(hProgressBar,PBM_SETSTEP,3,0);
	SendMessage(hProgressBar,PBM_SETPOS,0,0);
	//SendMessage(hProgressBar,PBM_SETRANGE,0,MAKELPARAM(0,100));
	SetWindowPos(hProgressBar,HWND_TOP,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE);
}

void CLogWnd::Find(wchar_t* findText)
{
	ShowWindow(hProgressBar,SW_SHOW);
	std::vector <std::wstring>::iterator iter;
	int from=ListView_GetSelectionMark(hListView)+1;
	int size = vList.size(),pos=0;
	for (iter=vList.begin()+from;iter!=vList.end();iter++)
	{
		int res=std::distance(vList.begin(),iter);
		if (wcsstr((*iter).c_str(),findText)!=NULL)
		{
			SetFocus(hListView);
			ListView_SetSelectionMark(hListView,res);
			ListView_SetItemState(hListView,res,LVIS_SELECTED|LVIS_FOCUSED, LVIS_SELECTED|LVIS_FOCUSED);
			ListView_EnsureVisible(hListView,res,TRUE);
			ShowWindow(hProgressBar,SW_HIDE);
			break;
		}
		pos=res*100/size;
		if (pos%5==0)
		{ 
			SendMessage(hProgressBar,PBM_SETPOS,pos,0);  
		}
	}
	ShowWindow(hProgressBar,SW_HIDE);
}