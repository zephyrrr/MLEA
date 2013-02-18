//+------------------------------------------------------------------+
//|                                                        Array.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Class CArray.                                                    |
//| Purpose: Base class of dynamic arrays.                           |
//|          Derives from class CObject.                             |
//+------------------------------------------------------------------+
class CArray : public CObject
  {
protected:
   int               m_step_resize;      // increment size of the array
   int               m_data_total;       // number of elements
   int               m_data_max;         // maximmum size of the array without memory reallocation
   int               m_sort_mode;        // mode of array sorting

public:
                     CArray(void);
                    ~CArray(void);
   //--- methods of access to protected data
   int               Step(void)                 const { return(m_step_resize);           }
   bool              Step(const int step);
   int               Total(void)                const { return(m_data_total);            }
   int               Available(void)            const { return(m_data_max-m_data_total); }
   int               Max(void)                  const { return(m_data_max);              }
   bool              IsSorted(const int mode=0) const { return(m_sort_mode==mode);       }
   int               SortMode(void)             const { return(m_sort_mode);             }
   //--- cleaning method
   void              Clear(void)                      { m_data_total=0;                  }
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- sorting method
   void              Sort(const int mode=0);

protected:
   virtual void      QuickSort(int beg,int end,const int mode=0)   { return; }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CArray::CArray(void) : m_step_resize(16),
                       m_data_total(0),
                       m_data_max(0),
                       m_sort_mode(-1)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CArray::~CArray(void)
  {
  }
//+------------------------------------------------------------------+
//| Method Set for variable m_step_resize.                           |
//+------------------------------------------------------------------+
bool CArray::Step(const int step)
  {
//--- checking
   if(step<=0) return(false);
//--- save
   m_step_resize=step;
//--- succed
   return(true);
  }
//+------------------------------------------------------------------+
//| Sorting an array in ascending order.                             |
//+------------------------------------------------------------------+
void CArray::Sort(const int mode)
  {
//--- checking
   if(IsSorted(mode))  return;
   m_sort_mode=mode;
   if(m_data_total<=1) return;
//--- sorting
   QuickSort(0,m_data_total-1,mode);
  }
//+------------------------------------------------------------------+
//| Writing header of array to file.                                 |
//+------------------------------------------------------------------+
bool CArray::Save(const int file_handle)
  {
//--- checking
   if(file_handle<0) return(false);
//--- writing
//--- writing start marker - 0xFFFFFFFFFFFFFFFF
   if(FileWriteLong(file_handle,-1)!=sizeof(long)) return(false);
//--- writing array type
   if(FileWriteInteger(file_handle,Type(),INT_VALUE)!=INT_VALUE) return(false);
//--- succed
   return(true);
  }
//+------------------------------------------------------------------+
//| Reading header of array from file.                               |
//+------------------------------------------------------------------+
bool CArray::Load(const int file_handle)
  {
//--- checking
   if(file_handle<0) return(false);
//--- reading
//--- reading and checking start marker - 0xFFFFFFFFFFFFFFFF
   if(FileReadLong(file_handle)!=-1) return(false);
//--- reading and checking array type
   if(FileReadInteger(file_handle,INT_VALUE)!=Type()) return(false);
//--- succed
   return(true);
  }
//+------------------------------------------------------------------+

