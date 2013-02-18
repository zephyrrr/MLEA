#include "windows.h"
#include "Richedit.h"
#include <commctrl.h>
#include "shellapi.h"
#include <string>
#include <vector>
#include <algorithm>

class CApp
{
	public:
		HWND hWnd,hRichEdit,hTreeView,hToolBar,hFindText;	// Window and editor handles
		HANDLE file;			  							// Opened file handle
		//wchar_t buff[5000000];    						// Buffer to read from file
		wchar_t path[10024];      							// Buffer for path
		HTREEITEM dubleClickHti,dubleClickHtiFile;  		// Temp variable for selected element
		RECT rect;				  							// Size of client window
		HBRUSH hBrush;
		HINSTANCE hIns;										// Application instance
		CRITICAL_SECTION CS_ScanProject,CS_ScanFile,CS_LogWindow,CS_TreeView;
		int semafor;
		bool readyMon,alert,stop;
		std::vector <std::wstring> vRunSP,vRunSF; 			// Control of running threads
		std::vector <TVITEM> vTVCheckItem;
		NOTIFYICONDATA NotifyIconData;
		
		CApp(void);
		~CApp(void);

		void CreateWnd(HINSTANCE hInstance,LPSTR lpCmdLine,int nShowCmd,WNDPROC WndProc);

		void CreateRichEdit(HWND hwndOwner,int x, int y,int width, int height,DWORD dwStyle,HINSTANCE hinst);

		void CreateTreeView();

		void CreateToolBar();
		
		void TreeViewAddProject(const wchar_t *name,HTREEITEM parent=TVI_ROOT,int parentIcon=NULL,int childIcon=NULL);

		void TreeViewAddEmpty(const wchar_t *name,HTREEITEM parent=TVI_ROOT);

		void TreeViewAddLog(const wchar_t *name,HTREEITEM parent);

		void TreeViewDelFile(HTREEITEM hti);
		
		void ParseMainFolder();

		void ParseLogFolder(const wchar_t *projectName,HTREEITEM hti,std::vector<std::wstring> &vNames);

		void ShowTrayIcon(void);

		void DeleteTrayIcon(void);

};
extern CApp App;