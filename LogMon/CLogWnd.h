#include "windows.h"
#include "CommCtrl.h"
#include <vector>
#include <string>
#include <map>

class CLogWnd
{
public:
	CLogWnd(void);
	~CLogWnd(void);
	HWND hWnd,hListView,hToolBar,hFindText,hProgressBar;
	HTREEITEM hti;
	bool exit;
	LONG wndProc;
	std::vector <std::wstring> vList;
	static HWND CreateWnd(HTREEITEM hti);
	void CreateLogToolBar(void);
	void CreateProgressBar(void);
	void Find(wchar_t* findText);
};