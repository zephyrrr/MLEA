//+------------------------------------------------------------------+
//|                                                   ArrayShort.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Array.mqh"
//+------------------------------------------------------------------+
//| Class CArrayShort.                                               |
//| Pupose: Class of dynamic array of variables                      |
//|         of short or ushort type.                                 |
//|         Derives from class CArray.                               |
//+------------------------------------------------------------------+
class CArrayShort : public CArray
  {
protected:
   short             m_data[];           // data array

public:
                     CArrayShort(void);
                    ~CArrayShort(void);
   //--- method of identifying the object
   virtual int       Type(void)                              const { return(TYPE_SHORT); }
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- methods of managing dynamic memory
   bool              Reserve(const int size);
   bool              Resize(const int size);
   bool              Shutdown(void);
   //--- methods of filling the array
   bool              Add(const short element);
   bool              AddArray(const short &src[]);
   bool              AddArray(const CArrayShort *src);
   bool              Insert(const short element,const int pos);
   bool              InsertArray(const short &src[],const int pos);
   bool              InsertArray(const CArrayShort *src,const int pos);
   bool              AssignArray(const short &src[]);
   bool              AssignArray(const CArrayShort *src);
   //--- method of access to the array
   short             At(const int index)                     const;
   //--- methods of changing
   bool              Update(const int index,const short element);
   bool              Shift(const int index,const int shift);
   //--- methods of deleting
   bool              Delete(const int index);
   bool              DeleteRange(int from,int to);
   //--- methods for comparing arrays
   bool              CompareArray(const short &Array[])      const;
   bool              CompareArray(const CArrayShort *Array)  const;
   //--- methods for working with the sorted array
   bool              InsertSort(const short element);
   int               Search(const short element)             const;
   int               SearchGreat(const short element)        const;
   int               SearchLess(const short element)         const;
   int               SearchGreatOrEqual(const short element) const;
   int               SearchLessOrEqual(const short element)  const;
   int               SearchFirst(const short element)        const;
   int               SearchLast(const short element)         const;
   int               SearchLinear(const short element)       const;

protected:
   virtual void      QuickSort(int beg,int end,const int mode=0);
   int               QuickSearch(const short element)        const;
   int               MemMove(const int dest,const int src,const int count);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CArrayShort::CArrayShort(void)
  {
//--- initialize protected data
   m_data_max=ArraySize(m_data);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CArrayShort::~CArrayShort(void)
  {
   if(m_data_max!=0) Shutdown();
  }
//+------------------------------------------------------------------+
//| Moving the memory within a single array.                         |
//+------------------------------------------------------------------+
int CArrayShort::MemMove(const int dest,const int src,const int count)
  {
   int i;
//--- checking
   if(dest<0 || src<0 || count<0) return(-1);
   if(dest+count>m_data_total)
     {
      if(Available()<dest+count) return(-1);
      else                       m_data_total=dest+count;
     }
//--- no need to copy
   if(dest==src || count==0) return(dest);
//--- copy
   if(dest<src)
     {
      //--- copy from left to right
      for(i=0;i<count;i++) m_data[dest+i]=m_data[src+i];
     }
   else
     {
      //--- copy from right to left
      for(i=count-1;i>=0;i--) m_data[dest+i]=m_data[src+i];
     }
//--- succeed
   return(dest);
  }
//+------------------------------------------------------------------+
//| Request for more memory in an array. Checks if the requested     |
//| number of free elements already exists; allocates additional     |
//| memory with a given step.                                        |
//+------------------------------------------------------------------+
bool CArrayShort::Reserve(const int size)
  {
   int new_size;
//--- checking
   if(size<=0) return(false);
//--- resizing array
   if(Available()<size)
     {
      new_size=m_data_max+m_step_resize*(1+(size-Available())/m_step_resize);
      if(new_size<0)
        {
         //--- overflow occurred when calculating new_size
         return(false);
        }
      m_data_max=ArrayResize(m_data,new_size);
     }
//--- result
   return(Available()>=size);
  }
//+------------------------------------------------------------------+
//| Resizing (with removal of elements on the right).                |
//+------------------------------------------------------------------+
bool CArrayShort::Resize(const int size)
  {
   int new_size;
//--- checking
   if(size<0) return(false);
//--- resizing array
   new_size=m_step_resize*(1+size/m_step_resize);
   if(m_data_max!=new_size) m_data_max=ArrayResize(m_data,new_size);
   if(m_data_total>size) m_data_total=size;
//--- result
   return(m_data_max==new_size);
  }
//+------------------------------------------------------------------+
//| Complete cleaning of the array with the release of memory.       |
//+------------------------------------------------------------------+
bool CArrayShort::Shutdown(void)
  {
//--- checking
   if(m_data_max==0) return(true);
//--- cleaning
   if(ArrayResize(m_data,0)==-1) return(false);
   m_data_total=0;
   m_data_max=0;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array.                       |
//+------------------------------------------------------------------+
bool CArrayShort::Add(const short element)
  {
//--- checking/reserving elements of array
   if(!Reserve(1)) return(false);
//--- adding
   m_data[m_data_total++]=element;
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array from another array.    |
//+------------------------------------------------------------------+
bool CArrayShort::AddArray(const short &src[])
  {
   int num=ArraySize(src);
//--- checking/reserving elements of array
   if(!Reserve(num)) return(false);
//--- adding
   for(int i=0;i<num;i++) m_data[m_data_total++]=src[i];
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array from another array.    |
//+------------------------------------------------------------------+
bool CArrayShort::AddArray(const CArrayShort *src)
  {
   int num;
//--- checking
   if(!CheckPointer(src)) return(false);
//--- checking/reserving elements of array
   num=src.Total();
   if(!Reserve(num)) return(false);
//--- adding
   for(int i=0;i<num;i++) m_data[m_data_total++]=src.m_data[i];
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting an element in the specified position.                  |
//+------------------------------------------------------------------+
bool CArrayShort::Insert(const short element,const int pos)
  {
//--- checking/reserving elements of array
   if(pos<0 || !Reserve(1)) return(false);
//--- inserting
   m_data_total++;
   if(pos<m_data_total-1)
     {
      MemMove(pos+1,pos,m_data_total-pos-1);
      m_data[pos]=element;
     }
   else
      m_data[m_data_total-1]=element;
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting elements in the specified position.                    |
//+------------------------------------------------------------------+
bool CArrayShort::InsertArray(const short &src[],const int pos)
  {
   int num=ArraySize(src);
//--- checking/reserve elements of array
   if(!Reserve(num)) return(false);
//--- inserting
   MemMove(num+pos,pos,m_data_total-pos);
   for(int i=0;i<num;i++) m_data[i+pos]=src[i];
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting elements in the specified position.                    |
//+------------------------------------------------------------------+
bool CArrayShort::InsertArray(const CArrayShort *src,const int pos)
  {
   int num;
//--- checking
   if(!CheckPointer(src)) return(false);
//--- checking/reserving elements of array
   num=src.Total();
   if(!Reserve(num)) return(false);
//--- inserting
   MemMove(num+pos,pos,m_data_total-pos);
   for(int i=0;i<num;i++) m_data[i+pos]=src.m_data[i];
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Assignment (copying) of another array.                           |
//+------------------------------------------------------------------+
bool CArrayShort::AssignArray(const short &src[])
  {
   int num=ArraySize(src);
//--- checking/reserving elements of array
   Clear();
   if(m_data_max<num)
     {
      if(!Reserve(num)) return(false);
     }
   else   Resize(num);
//--- copying array
   for(int i=0;i<num;i++)
     {
      m_data[i]=src[i];
      m_data_total++;
     }
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Assignment (copying) of another array.                           |
//+------------------------------------------------------------------+
bool CArrayShort::AssignArray(const CArrayShort *src)
  {
   int num;
//--- checking
   if(!CheckPointer(src)) return(false);
//--- checking/reserving elements of array
   num=src.m_data_total;
   Clear();
   if(m_data_max<num)
     {
      if(!Reserve(num)) return(false);
     }
   else   Resize(num);
//--- copying array
   for(int i=0;i<num;i++)
     {
      m_data[i]=src.m_data[i];
      m_data_total++;
     }
   m_sort_mode=src.SortMode();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Access to data in the specified position.                        |
//+------------------------------------------------------------------+
short CArrayShort::At(const int index) const
  {
//--- checking
   if(index<0 || index>=m_data_total) return(SHORT_MAX);
//--- result
   return(m_data[index]);
  }
//+------------------------------------------------------------------+
//| Updating element in the specified position.                      |
//+------------------------------------------------------------------+
bool CArrayShort::Update(const int index,const short element)
  {
//--- checking
   if(index<0 || index>=m_data_total) return(false);
//--- update
   m_data[index]=element;
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving element from the specified position                       |
//| on the specified shift.                                          |
//+------------------------------------------------------------------+
bool CArrayShort::Shift(const int index,const int shift)
  {
   short tmp_short;
//--- checking
   if(index<0 || index+shift<0 || index+shift>=m_data_total) return(false);
   if(shift==0) return(true);
//--- moving
   tmp_short=m_data[index];
   if(shift>0) MemMove(index,index+1,shift);
   else        MemMove(index+shift+1,index+shift,-shift);
   m_data[index+shift]=tmp_short;
   m_sort_mode=-1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Deleting element from the specified position.                    |
//+------------------------------------------------------------------+
bool CArrayShort::Delete(const int index)
  {
//--- checking
   if(index<0 || index>=m_data_total) return(false);
//--- deleting
   if(index<m_data_total-1) MemMove(index,index+1,m_data_total-index-1);
   m_data_total--;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Deleting range of elements.                                      |
//+------------------------------------------------------------------+
bool CArrayShort::DeleteRange(int from,int to)
  {
//--- checking
   if(from<0 || to<0)                return(false);
   if(from>to || from>=m_data_total) return(false);
//--- deleting
   if(to>=m_data_total-1) to=m_data_total-1;
   MemMove(from,to+1,m_data_total-to);
   m_data_total-=to-from+1;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Equality comparison of two arrays.                               |
//+------------------------------------------------------------------+
bool CArrayShort::CompareArray(const short &Array[]) const
  {
//--- comparison
   if(m_data_total!=ArraySize(Array)) return(false);
   for(int i=0;i<m_data_total;i++)
      if(m_data[i]!=Array[i]) return(false);
//--- equal
   return(true);
  }
//+------------------------------------------------------------------+
//| Equality comparison of two arrays.                               |
//+------------------------------------------------------------------+
bool CArrayShort::CompareArray(const CArrayShort *Array) const
  {
//--- checking
   if(!CheckPointer(Array)) return(false);
//--- comparison
   if(m_data_total!=Array.m_data_total) return(false);
   for(int i=0;i<m_data_total;i++)
      if(m_data[i]!=Array.m_data[i]) return(false);
//--- equal
   return(true);
  }
//+------------------------------------------------------------------+
//| Method QuickSort.                                                |
//+------------------------------------------------------------------+
void CArrayShort::QuickSort(int beg,int end,const int mode)
  {
   int   i,j;
   short p_short,t_short;
//--- checking
   if(beg<0 || end<0) return;
//--- sorting
   i=beg;
   j=end;
   while(i<end)
     {
      //--- ">>1" is quick division by 2
      p_short=m_data[(beg+end)>>1];
      while(i<j)
        {
         while(m_data[i]<p_short)
           {
            //--- control the output of the array bounds
            if(i==m_data_total-1) break;
            i++;
           }
         while(m_data[j]>p_short)
           {
            //--- control the output of the array bounds
            if(j==0) break;
            j--;
           }
         if(i<=j)
           {
            t_short  =m_data[i];
            m_data[i++]=m_data[j];
            m_data[j]=t_short;
            //--- control the output of the array bounds
            if(j==0) break;
            else     j--;
           }
        }
      if(beg<j) QuickSort(beg,j);
      beg=i;
      j=end;
     }
  }
//+------------------------------------------------------------------+
//| Inserting element in a sorted array.                             |
//+------------------------------------------------------------------+
bool CArrayShort::InsertSort(const short element)
  {
   int pos;
//--- checking
   if(!IsSorted()) return(false);
//--- checking/reserving elements of array
   if(!Reserve(1)) return(false);
//--- if the array is empty, add an element
   if(m_data_total==0)
     {
      m_data[m_data_total++]=element;
      return(true);
     }
//--- find position and insert
   pos=QuickSearch(element);
   if(m_data[pos]>element) Insert(element,pos);
   else                    Insert(element,pos+1);
//--- restore the sorting flag after Insert(...)
   m_sort_mode=0;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Search of position of element in a array.                        |
//+------------------------------------------------------------------+
int CArrayShort::SearchLinear(const short element) const
  {
//--- checking
   if(m_data_total==0) return(-1);
//---
   for(int i=0;i<m_data_total;i++)
      if(m_data[i]==element) return(i);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Quick search of position of element in a sorted array.           |
//+------------------------------------------------------------------+
int CArrayShort::QuickSearch(const short element) const
  {
   int   i,j,m=-1;
   short t_short;
//--- search
   i=0;
   j=m_data_total-1;
   while(j>=i)
     {
      //--- ">>1" is quick division by 2
      m=(j+i)>>1;
      if(m<0 || m>=m_data_total) break;
      t_short=m_data[m];
      if(t_short==element) break;
      if(t_short>element) j=m-1;
      else                i=m+1;
     }
//--- position
   return(m);
  }
//+------------------------------------------------------------------+
//| Search of position of element in a sorted array.                 |
//+------------------------------------------------------------------+
int CArrayShort::Search(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos]==element) return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is greater than       |
//| specified in a sorted array.                                     |
//+------------------------------------------------------------------+
int CArrayShort::SearchGreat(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- searching
   pos=QuickSearch(element);
   while(m_data[pos]<=element)
      if(++pos==m_data_total) return(-1);
//--- position
   return(pos);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is less than          |
//| specified in the sorted array.                                   |
//+------------------------------------------------------------------+
int CArrayShort::SearchLess(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- search
   pos=QuickSearch(element);
   while(m_data[pos]>=element)
      if(pos--==0) return(-1);
//--- position
   return(pos);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is greater than or    |
//| equal to the specified in a sorted array.                        |
//+------------------------------------------------------------------+
int CArrayShort::SearchGreatOrEqual(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- searching
   if((pos=SearchGreat(element))!=-1)
     {
      if(pos!=0 && m_data[pos-1]==element) return(pos-1);
      else                                 return(pos);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is less than or equal |
//| to the specified in a sorted array.                              |
//+------------------------------------------------------------------+
int CArrayShort::SearchLessOrEqual(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- searching
   if((pos=SearchLess(element))!=-1)
     {
      if(pos!=m_data_total-1 && m_data[pos+1]==element) return(pos+1);
      else                                              return(pos);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Find position of first appearance of element in a sorted array.  |
//+------------------------------------------------------------------+
int CArrayShort::SearchFirst(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- searching
   pos=QuickSearch(element);
   if(m_data[pos]==element)
     {
      while(m_data[pos]==element)
         if(pos--==0) break;
      return(pos+1);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Find position of last appearance of element in a sorted array.   |
//+------------------------------------------------------------------+
int CArrayShort::SearchLast(const short element) const
  {
   int pos;
//--- checking
   if(m_data_total==0 || !IsSorted()) return(-1);
//--- searching
   pos=QuickSearch(element);
   if(m_data[pos]==element)
     {
      while(m_data[pos]==element)
         if(++pos==m_data_total) break;
      return(pos-1);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Writing array to file.                                           |
//+------------------------------------------------------------------+
bool CArrayShort::Save(const int file_handle)
  {
   int i=0;
//--- checking
   if(!CArray::Save(file_handle)) return(false);
//--- writing array length
   if(FileWriteInteger(file_handle,m_data_total,INT_VALUE)!=INT_VALUE) return(false);
//--- writing array
   for(i=0;i<m_data_total;i++)
      if(FileWriteInteger(file_handle,m_data[i],SHORT_VALUE)!=SHORT_VALUE) break;
//--- result
   return(i==m_data_total);
  }
//+------------------------------------------------------------------+
//| Reading array from file.                                         |
//+------------------------------------------------------------------+
bool CArrayShort::Load(const int file_handle)
  {
   int i=0,num;
//--- checking
   if(!CArray::Load(file_handle)) return(false);
//--- reading array length
   num=FileReadInteger(file_handle,INT_VALUE);
//--- reading array
   Clear();
   if(num!=0)
     {
      if(!Reserve(num))           return(false);
      for(i=0;i<num;i++)
        {
         m_data[i]=(short)FileReadInteger(file_handle,SHORT_VALUE);
         m_data_total++;
         if(FileIsEnding(file_handle)) break;
        }
     }
   m_sort_mode=-1;
//--- result
   return(m_data_total==num);
  }
//+------------------------------------------------------------------+