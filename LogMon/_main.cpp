//#if defined _M_IX86
#pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='x86' publicKeyToken='6595b64144ccf1df' language='*'\"")
/*#elif defined _M_IA64
#pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='ia64' publicKeyToken='6595b64144ccf1df' language='*'\"")
#elif defined _M_X64
#pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='amd64' publicKeyToken='6595b64144ccf1df' language='*'\"")
#else
#pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")
#endif*/

#define WM_TRAYMSG (WM_APP+1)
#include "windows.h"
#include <iostream>
#include <stdlib.h>
#include "process.h"
//#include "shellapi.h"
//#include <fstream>
#include <vector>
#include <map>
#include "resource.h"
//#include <commctrl.h>
//#include "Richedit.h"
#include "CApp.h"
#include "thread.h"
#include "CLogWnd.h"
//#include <malloc.h>
//#include <memory.h>
//#include <tchar.h>
#define lStr(str)	(wmemset(buff_str,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str,sizeof(buff_str)),buff_str)
#define lStr2(str)	(wmemset(buff_str2,'\0',1024),LoadString(App.hIns,IDS_STRING_##str,buff_str2,sizeof(buff_str2)),buff_str2)
#define INITLSTR()	wchar_t buff_str[1024];wmemset(buff_str,'\0',1024);wchar_t buff_str2[1024];wmemset(buff_str2,'\0',1024)

LRESULT CALLBACK WndProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam );
LRESULT CALLBACK DlgResetProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam );
LRESULT CALLBACK DlgMsgProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam );
LRESULT CALLBACK DlgAboutProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam );
void TreeViewFindCheck(int lvl=0,HTREEITEM parent=NULL);

CApp App;
extern std::map <HWND,CLogWnd> mLogWnd;
std::map <HWND,CLogWnd> mLogWnd;
extern int semafor;
extern int countThread;
extern CRITICAL_SECTION cs_CountThread;
CRITICAL_SECTION cs_CountThread;
int countThread=0;


int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nShowCmd)
{
	InitializeCriticalSection(&cs_CountThread);
	/*LANGID lid = LOBYTE (GetUserDefaultUILanguage());
	if (lid != LANG_RUSSIAN)
	{return (0);}*/
	App.CreateWnd(hInstance,lpCmdLine,nShowCmd,WndProc);
	App.CreateTreeView();
	App.ParseMainFolder();
	MSG msg;
	App.CreateToolBar();
	//_beginthreadex(NULL,0,LogWindow,(void *)123,0,NULL);
	//_beginthreadex(NULL,0,LogWindow,(void *)123,0,NULL);
	//_beginthreadex(NULL,0,LogWindow,(void *)123,0,NULL);
	while(GetMessage(&msg,0,0,0)==TRUE)
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	App.DeleteTrayIcon();

	return 0;
}

LRESULT CALLBACK WndProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam )
{
	LPNMHDR hdr;
	TVITEM tvit;
	INITLSTR();
	TBBUTTON tbButton={LOWORD(lParam)-160, 0,  TBSTATE_ENABLED, BTNS_SEP, 0L, 0};
	switch(Msg)
	{
		case WM_DESTROY:
			App.TreeViewDelFile(0);
			PostQuitMessage(0);
			break;
		case WM_SIZE:
			MoveWindow(App.hTreeView,0,44,LOWORD(lParam),HIWORD(lParam)-44,TRUE);
			SendMessage(App.hToolBar,TB_AUTOSIZE,0,0);
			SendMessage(App.hToolBar,TB_DELETEBUTTON,0,0);
			SendMessage(App.hToolBar,TB_INSERTBUTTON,0,(LPARAM)&tbButton);
			SendMessage(App.hToolBar,TB_AUTOSIZE,0,0);
			break;
		case WM_COMMAND:
			if ((HWND)lParam==App.hToolBar)
			{
				switch (wParam)
				{
				case 123: //destroy button
					switch (DialogBoxW(App.hIns,MAKEINTRESOURCE(IDD_RESETDEL),hWnd,(DLGPROC)DlgResetProc))
					{
					case IDRESET:
					App.TreeViewDelFile(0);
						break;
					case IDRESETDEL:
						tvit.hItem = TreeView_GetSelection(App.hTreeView);
						if (tvit.hItem!=0)
						{
							App.TreeViewDelFile(tvit.hItem);
						}
						else
						{
							MessageBox(hWnd,lStr(UNSELECT),lStr2(UERROR),MB_OK);
						}
						break;
					}
					
					break;
				case 124: //activate monitoring button
					if (!App.readyMon)
					{
						ShowWindow(App.hWnd,SW_MINIMIZE);
						ShowWindow(App.hWnd,SW_HIDE);
						App.readyMon=false;
						_beginthreadex(NULL,0,ThreadPrepareMon,(void *)123,0,NULL);
					}
					break;
				case 125:
					if (SendMessage(App.hToolBar,TB_ISBUTTONCHECKED,125,0))
					{	SetWindowPos(hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE);	}
					else
					{	SetWindowPos(hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE);	}
					break;
				case 126:
					DialogBoxW(App.hIns,MAKEINTRESOURCE(IDD_DIALOGABOUT),hWnd,(DLGPROC)DlgAboutProc);
					break;
				}
			}
			break;
		case WM_NOTIFY:
			hdr = (LPNMHDR) lParam;
			if (hdr->code==NM_DBLCLK)
			{
				tvit.mask = TVIF_PARAM;
				tvit.hItem = TreeView_GetSelection(App.hTreeView);
				TreeView_GetItem(App.hTreeView,&tvit);
				switch (tvit.lParam)
				{
					case 10://Project
					_beginthreadex(NULL,0,ThreadScanFolder,(void *)TreeView_GetSelection(App.hTreeView),0,NULL);
					break;
					case 20://Category of log message
						_beginthreadex(NULL,0,ThreadScanFile,(void *)TreeView_GetSelection(App.hTreeView),0,NULL);
					break;
					case 30:
						_beginthreadex(NULL,0,LogWindow,(void *)TreeView_GetSelection(App.hTreeView),0,NULL);
					break;
				}
			}
			if (hdr->code==NM_CLICK)
			{
				App.alert=false;
			}
			
			if (hdr->code==TTN_GETDISPINFO) 
			{ 
				LPTOOLTIPTEXT lpttt; 
				lpttt = (LPTOOLTIPTEXT) lParam; 
				lpttt->hinst = App.hIns; 
				// Specify the resource identifier of the descriptive 
				// text for the given button. 
				UINT idButton = lpttt->hdr.idFrom; 
				switch (idButton) 
				{ 
				    case 123: 
				        lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UDESTOY); 
				        break; 
				    case 124: 
						lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UMON); 
				        break; 
				    case 125: 
				        lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UTOP); 
				        break;
					case 126: 
				        lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UABOUTBUTTON); 
				        break;
				} 
			} 
			break;
		case WM_TRAYMSG:
			switch ((UINT)lParam)
			{
			case WM_LBUTTONUP:
				if (App.readyMon)
				{
					App.readyMon=false;
					ShowWindow(App.hWnd,SW_SHOW);
					ShowWindow(App.hWnd,SW_RESTORE);
					SetForegroundWindow(App.hTreeView);
					App.DeleteTrayIcon();
				}
				
				break;
			}
			break;

		default:
			return DefWindowProc(hWnd,Msg,wParam,lParam);
	}
	return (0);
}


LRESULT CALLBACK WndProcViewLog(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam )
{
	//LPNMHDR hdr;
	//TVITEM tvit;
	NMLVDISPINFO *lvdi;
	wchar_t buff[2048];
	int buff_r;
	int buff_g;
	int buff_b;
	wchar_t* pos=0;
	DWORD dwStyle;
	UINT idButton;
	SCROLLBARINFO sbi;
	TBBUTTON tbButton={LOWORD(lParam)-70, 0,  TBSTATE_ENABLED, BTNS_SEP, 0L, 0};
	sbi.cbSize=sizeof(SCROLLBARINFO);
	switch(Msg)
	{
		case WM_DESTROY:
			mLogWnd[hWnd].exit = true;
			PostQuitMessage(0);
		break;
			break;
		case WM_COMMAND:
			if ((HWND)lParam==mLogWnd[hWnd].hToolBar)
			{
				switch (wParam)
				{
				case 123: //find button
					SendMessage(mLogWnd[hWnd].hFindText,WM_GETTEXT,2048,(LPARAM)buff);
					mLogWnd[hWnd].Find(buff);
					break;
				case 125:
					if (SendMessage(mLogWnd[hWnd].hToolBar,TB_ISBUTTONCHECKED,125,0))
					{	SetWindowPos(hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE);	}
					else
					{	SetWindowPos(hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE);	}
					break;
				}

			}
			break;
		case WM_SIZE:
			MoveWindow(mLogWnd[hWnd].hListView,0,28,LOWORD(lParam),HIWORD(lParam)-28,TRUE);
			SetWindowPos(mLogWnd[hWnd].hFindText,0,LOWORD(lParam)-225,2,0,0,SWP_NOZORDER | SWP_NOSIZE);
			SetWindowPos(mLogWnd[hWnd].hProgressBar,0,LOWORD(lParam)-225,2,0,0,SWP_NOZORDER | SWP_NOSIZE);
			SendMessage(mLogWnd[hWnd].hToolBar,TB_DELETEBUTTON,0,0);
			SendMessage(mLogWnd[hWnd].hToolBar,TB_INSERTBUTTON,0,(LPARAM)&tbButton);
			SendMessage(mLogWnd[hWnd].hToolBar,TB_AUTOSIZE,0,0);
			
			LVCOLUMN lcol;
			lcol.mask = LVCF_WIDTH;
			dwStyle = (DWORD)GetWindowLong(mLogWnd[hWnd].hListView, GWL_STYLE);
			if (dwStyle & WS_VSCROLL)
			{ GetScrollBarInfo(mLogWnd[hWnd].hListView,OBJID_VSCROLL,&sbi);
			lcol.cx = LOWORD(lParam)-sbi.dxyLineButton;	}
			else
			{lcol.cx = LOWORD(lParam);}
			ListView_SetColumn(mLogWnd[hWnd].hListView,0,&lcol);
		break;
		case WM_NOTIFY:
			LPNMLISTVIEW pnm;
            pnm = (LPNMLISTVIEW)lParam;
			switch (pnm->hdr.code)
			{
			case NM_CUSTOMDRAW:
				NMLVCUSTOMDRAW *nmlvcd;
				nmlvcd = (NMLVCUSTOMDRAW *)lParam;
				switch (nmlvcd -> nmcd.dwDrawStage)
				{
				case CDDS_PREPAINT:
					return CDRF_NOTIFYITEMDRAW;
				break;
				case CDDS_ITEMPREPAINT:
					// Determine colors
					
					if (mLogWnd[hWnd].vList.size()==0 ||
						nmlvcd -> nmcd.dwItemSpec>mLogWnd[hWnd].vList.size())
					{  
						return CDRF_NEWFONT;	
					}
					if (swscanf_s (mLogWnd[hWnd].vList[nmlvcd -> nmcd.dwItemSpec].c_str(),
						L"%[a-zA-Z?ÿ??_.]%*[:|]%d,%d,%d",buff,1024,&buff_r,&buff_g,&buff_b
						)==4)
					{
						nmlvcd -> clrTextBk = RGB(buff_r,buff_g,buff_b);
					}
					
					/*if ( nmlvcd -> nmcd.dwItemSpec & 1 )
					{
						nmlvcd -> clrTextBk = RGB(200,200,200);
						//nmlvcd -> 
						//nmlvcd -> clrText = 0xF0F0F0;
						SelectObject ( nmlvcd -> nmcd.hdc, GetStockObject (SYSTEM_FONT) );
						//return CDRF_NEWFONT;
					}
					else
					{
						nmlvcd -> clrTextBk = RGB(230,230,230);
					}*/
					return CDRF_NEWFONT;
				break;
				}
			break;
			
			case TTN_GETDISPINFO:
					LPTOOLTIPTEXT lpttt; 
					lpttt = (LPTOOLTIPTEXT) lParam; 
					lpttt->hinst = App.hIns; 
					// Specify the resource identifier of the descriptive 
					// text for the given button. 
					idButton = lpttt->hdr.idFrom; 
					switch (idButton) 
					{ 
					    case 123: 
							lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UFINDBUTTON); 
					        break; 
					    case 124: 
							lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UASCROLL); 
					        break; 
					    case 125: 
					        lpttt->lpszText = MAKEINTRESOURCE(IDS_STRING_UTOP); 
					        break; 
					} 
					break; 
				
			case NM_DBLCLK:
				DialogBox(App.hIns,MAKEINTRESOURCE(IDD_DIALOGVIEWMSG),mLogWnd[hWnd].hWnd,(DLGPROC)DlgMsgProc);
				break;
			
			case LVN_GETDISPINFO:
				lvdi = (NMLVDISPINFO*) lParam;
				if (lvdi->item.mask & LVIF_TEXT)
				{	
					//while (lvdi->item.pszText=wcscspn(mLogWnd[hWnd].vList[lvdi->item.iItem].c_str(),L":|:"))
					//wcscpy( buff,const_cast<LPWSTR>(mLogWnd[hWnd].vList[lvdi->item.iItem].c_str()));
					lvdi->item.pszText = const_cast<LPWSTR>(mLogWnd[hWnd].vList[lvdi->item.iItem].c_str());

					// remove "Debug"...
					//while ((pos=wcsstr(lvdi->item.pszText,L":|:"))!=NULL)
					//{
					//	lvdi->item.pszText=pos+3;
					//}
					lvdi->item.cchTextMax = 1024;
				}	
			break;
         }// switch
         
         break; // WM_NOTIFY

		default:
		return DefWindowProc(hWnd,Msg,wParam,lParam);
	}
	return(0);
}


LRESULT CALLBACK WndProcSubClass(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam )
{
	INITLSTR();
	HWND parentWnd=(HWND)GetWindowLong((HWND)GetWindowLong(hWnd,GWL_HWNDPARENT),GWL_HWNDPARENT);
	wchar_t buff[2048];
	switch (Msg)
	{
	case WM_KEYDOWN:
		if (wParam==VK_RETURN)
		{
			SendMessage(mLogWnd[parentWnd].hFindText,WM_GETTEXT,2048,(LPARAM)buff);
			mLogWnd[parentWnd].Find(buff);
		}
	case WM_SETFOCUS:
		SendMessage(mLogWnd[parentWnd].hFindText,WM_GETTEXT,2048,(LPARAM)buff);
		if (!wcscmp(buff,lStr(UFIND)))
		{	SendMessage(mLogWnd[parentWnd].hFindText,WM_SETTEXT,0,(LPARAM)L"");	}
		break;
	case WM_KILLFOCUS:
		SendMessage(mLogWnd[parentWnd].hFindText,WM_GETTEXT,2048,(LPARAM)buff);
		if (!wcscmp(buff,L""))
		{	SendMessage(mLogWnd[parentWnd].hFindText,WM_SETTEXT,0,(LPARAM)lStr(UFIND));	}
		break;
	break;
	}
	return(CallWindowProc((WNDPROC)mLogWnd[parentWnd].wndProc,mLogWnd[parentWnd].hFindText,Msg,wParam,lParam));
	
}

LRESULT CALLBACK DlgResetProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam )
{
	switch (Msg)
	{
	case WM_DESTROY:
		EndDialog(hWnd,0);
		break;
	case WM_COMMAND:
		EndDialog(hWnd,wParam);
		break;
	case WM_SYSCOMMAND:
		if (wParam ==SC_CLOSE)
		{
			EndDialog(hWnd,0);
		}
	default:
		return (0);
	}
	return (0);
}

LRESULT CALLBACK DlgMsgProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam )
{
	HWND parentHWnd = (HWND)GetWindowLong(hWnd,GWL_HWNDPARENT); 
	wchar_t buff[2048]; wmemset(buff,'\0',2048);
	wchar_t* pos=NULL;
	switch (Msg)
	{
	case WM_DESTROY:
		EndDialog(hWnd,0);
		break;
	case WM_INITDIALOG:		
		wcscpy_s (buff,2048,mLogWnd[parentHWnd].vList[ListView_GetSelectionMark(mLogWnd[parentHWnd].hListView)].c_str());
		while ((pos=wcsstr(buff,L":|:"))!=NULL)
		{wcscpy_s(buff,2048,pos+3);}
		SetDlgItemText(hWnd,IDC_EDIT1,buff);
		break;
	case WM_COMMAND:
		if (wParam == IDOK)
		{EndDialog(hWnd,0);}
		break;
	case WM_SYSCOMMAND:
		if (wParam ==SC_CLOSE)
		{
			EndDialog(hWnd,0);
		}
	default:
		return (0);
	}
	return (0);
}

LRESULT CALLBACK DlgAboutProc(
	HWND hWnd,
	UINT Msg,
	WPARAM wParam,
	LPARAM lParam )
{
	INITLSTR();
	switch (Msg)
	{
	case WM_DESTROY:
		EndDialog(hWnd,0);
		break;
	case WM_INITDIALOG:		
		SetDlgItemText(hWnd,IDC_EDIT2,lStr(UABOUT));
		break;
	case WM_COMMAND:
		if (wParam == IDOK)//wParam ==0x0000F012)
		{EndDialog(hWnd,0);}
		break;
	case WM_SYSCOMMAND:
		if (wParam ==SC_CLOSE)
		{
			EndDialog(hWnd,0);
		}
		break;
	default:
		return (0);
	}
	return (0);
}

void TreeViewFindCheck(HTREEITEM parent,bool force)
{
	TVITEM tvItem;
	bool lforce;
	ZeroMemory(&tvItem,sizeof(TVITEM));
	HTREEITEM locHti,tmpHti;
	wchar_t buff[2048]; wmemset(buff,'\0',2048);
	if (parent==NULL)
	{
		locHti=TreeView_GetRoot(App.hTreeView);
	}
	else
	{
		locHti=TreeView_GetChild(App.hTreeView,parent);
	}
	do
	{
		lforce=false;
		tvItem.mask = TVIF_HANDLE | TVIF_TEXT;
		tvItem.hItem = locHti;
		tvItem.pszText = buff;
		tvItem.cchTextMax = 2048;
		TreeView_GetItem(App.hTreeView,&tvItem);
		if (TreeView_GetCheckState(App.hTreeView,locHti)==1 || force)
		{
			switch (tvItem.lParam)
			{
				case 10:
					semafor=1;
					//TreeView_Select(App.hTreeView,locHti,TVGN_CARET);
					//TreeView_Expand(App.hTreeView,locHti,TVE_EXPAND);
					_beginthreadex(NULL,0,ThreadScanFolder,(void *)locHti,0,NULL);
					lforce=TRUE;
					while (semafor==1)
					{Sleep(100);}
				break;
				case 20:
					semafor=1;
					//TreeView_Select(App.hTreeView,locHti,TVGN_CARET);
					//TreeView_Expand(App.hTreeView,locHti,TVE_EXPAND);
					_beginthreadex(NULL,0,ThreadScanFile,(void *)locHti,0,NULL);
					lforce=TRUE;
					while (semafor==1)
					{Sleep(100);}
				break;
			}
		}
		if (tmpHti=TreeView_GetChild(App.hTreeView,locHti))
		{
			TreeViewFindCheck(locHti,lforce);
		}
	}
	while(locHti=TreeView_GetNextSibling(App.hTreeView,locHti));
}
