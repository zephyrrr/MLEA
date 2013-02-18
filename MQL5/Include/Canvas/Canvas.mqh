//+------------------------------------------------------------------+
//|                                                       Canvas.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Macro to generate color                                          |
//+------------------------------------------------------------------+
#define XRGB(r,g,b)    (0xFF000000|(uchar(r)<<16)|(uchar(g)<<8)|uchar(b))
#define ARGB(a,r,g,b)  ((uchar(a)<<24)|(uchar(r)<<16)|(uchar(g)<<8)|uchar(b))
#define TRGB(a,rgb)    ((uchar(a)<<24)|(rgb))
#define GETRGB(clr)    ((clr)&0xFFFFFF)
#define GETRGBR(clr)   uchar((clr)>>16)
#define GETRGBG(clr)   uchar((clr)>>8)
#define GETRGBB(clr)   uchar(clr)
//+------------------------------------------------------------------+
//| Class CCanvas                                                    |
//| Usage: class for working with a dynamic resource                 |
//+------------------------------------------------------------------+
class CCanvas
  {
protected:
   string            m_objname;                // object name
   string            m_rcname;                 // resource name
   int               m_width;                  // canvas width
   int               m_height;                 // canvas height
   ENUM_COLOR_FORMAT m_format;                 // method of color processing
   //--- data
   uint              m_pixels[];               // array of pixels

public:
                     CCanvas(void);
                    ~CCanvas(void);
   //--- create/destroy
   virtual bool      Create(const string name,const int width,const int height,ENUM_COLOR_FORMAT clrfmt=COLOR_FORMAT_ARGB_NORMALIZE);
   bool              CreateBitmap(const string name,const datetime time,const double price,
                                  const int width,const int height,ENUM_COLOR_FORMAT clrfmt=COLOR_FORMAT_ARGB_NORMALIZE);
   bool              CreateBitmapLabel(const string name,const int x,const int y,
                                       const int width,const int height,ENUM_COLOR_FORMAT clrfmt=COLOR_FORMAT_ARGB_NORMALIZE);
   void              Destroy(void);
   //--- properties
   string            ChartObjectName(void)          const { return(m_objname); }
   string            ResourceName(void)             const { return(m_rcname);  }
   int               Width(void)                    const { return(m_width);   }
   int               Height(void)                   const { return(m_height);  }
   //--- update object on screen
   void              Update(void);
   bool              Resize(const int width,const int height);
   //--- clear/fill color
   void              Erase(const uint clr=0);
   //--- data access
   uint              PixelGet(const int x,const int y) const;
   uint              PixelGetFast(const int x,const int y) const;
   void              PixelSet(const int x,const int y,const uint clr);
   void              PixelSetFast(const int x,const int y,const uint clr);
   //--- draw primitives
   void              LineVertical(int x,int y1,int y2,const uint clr);
   void              LineHorizontal(int x1,int x2,int y,const uint clr);
   void              Line(int x1,int y1,int x2,int y2,const uint clr);
   void              Polyline(int &x[],int &y[],const uint clr);
   void              Polygon(int &x[],int &y[],const uint clr);
   void              Rectangle(int x1,int y1,int x2,int y2,const uint clr);
   void              Arc(int x,int y,int r,const double fi1,const double fi2,const uint clr);
   void              Circle(int x,int y,int r,const uint clr);
   void              Triangle(int x1,int y1,int x2,int y2,int x3,int y3,const uint clr);
   //--- draw filled primitives
   void              FillRectangle(int x1,int y1,int x2,int y2,const uint clr);
   void              FillCircle(int x,int y,int r,const uint clr);
   void              FillTriangle(int x1,int y1,int x2,int y2,int x3,int y3,const uint clr);
   void              Fill(int x,int y,const uint clr);
   //--- draw primitives with antialiasing
   void              LineAA(int x1,int y1,int x2,int y2,const uint clr);
   void              TriangleAA(int x1,int y1,int x2,int y2,int x3,int y3,const uint clr);
   //--- services
   void              SetTransparentLevel(const uchar value);

protected:
   uint              CalcColor(const uint clr_bBase,const uint clr,const int trans) const;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCanvas::CCanvas(void) : m_objname(NULL),
                         m_rcname(NULL),
                         m_width(0),
                         m_height(0),
                         m_format(COLOR_FORMAT_XRGB_NOALPHA)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCanvas::~CCanvas(void)
  {
  }
//+------------------------------------------------------------------+
//| Create dynamic resource                                          |
//+------------------------------------------------------------------+
bool CCanvas::Create(const string name,const int width,const int height,ENUM_COLOR_FORMAT clrfmt)
  {
   Destroy();
//--- prepare data array
   if(width>0 && height>0 && ArrayResize(m_pixels,width*height)>0)
     {
      //--- generate resource name
      m_rcname="::"+name+(string)(GetTickCount()+MathRand());
      //--- initialize data with zeros
      ArrayInitialize(m_pixels,0);
      //--- create dynamic resource
      if(ResourceCreate(m_rcname,m_pixels,width,height,0,0,0,clrfmt))
        {
         //--- successfully created
         //--- complete initialization
         m_width =width;
         m_height=height;
         m_format=clrfmt;
         //--- succeed
         return(true);
        }
     }
//--- error - destroy object
   Destroy();
   return(false);
  }
//+------------------------------------------------------------------+
//| Create object on chart with attached dynamic resource            |
//+------------------------------------------------------------------+
bool CCanvas::CreateBitmap(const string name,const datetime time,const double price,
                           const int width,const int height,ENUM_COLOR_FORMAT clrfmt)
  {
//--- create canvas
   if(Create(name,width,height,clrfmt))
     {
      //--- create attached object
      if(ObjectCreate(0,name,OBJ_BITMAP,0,time,price))
        {
         //--- bind object with resource
         if(ObjectSetString(0,name,OBJPROP_BMPFILE,m_rcname))
           {
            //--- successfully created
            //--- complete initialization
            m_objname=name;
            //--- succeed
            return(true);
           }
        }
     }
//--- error - destroy object
   Destroy();
   return(false);
  }
//+------------------------------------------------------------------+
//| Create object on chart with attached dynamic resource            |
//+------------------------------------------------------------------+
bool CCanvas::CreateBitmapLabel(const string name,const int x,const int y,
                                const int width,const int height,ENUM_COLOR_FORMAT clrfmt)
  {
//--- create canvas
   if(Create(name,width,height,clrfmt))
     {
      //--- create attached object
      if(ObjectCreate(0,name,OBJ_BITMAP_LABEL,0,0,0))
        {
         //--- set x,y and bind object with resource
         if(ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x) && 
            ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y) && 
            ObjectSetString(0,name,OBJPROP_BMPFILE,m_rcname))
           {
            //--- successfully created
            //--- complete initialization
            m_objname=name;
            //--- succeed
            return(true);
           }
        }
     }
//--- error - destroy object
   Destroy();
   return(false);
  }
//+------------------------------------------------------------------+
//| Remove object from chart and deallocate data array               |
//+------------------------------------------------------------------+
void CCanvas::Destroy(void)
  {
//--- delete object
   if(m_objname!=NULL)
     {
      ObjectDelete(0,m_objname);
      m_objname=NULL;
     }
//--- deallocate array
   ArrayFree(m_pixels);
//--- zeroize data
   m_width =0;
   m_height=0;
   m_rcname=NULL;
  }
//+------------------------------------------------------------------+
//| Update object on screen (redraw)                                 |
//+------------------------------------------------------------------+
void CCanvas::Update(void)
  {
//--- update resource and redraw
   if(ResourceCreate(m_rcname,m_pixels,m_width,m_height,0,0,0,m_format))
      ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Resize                                                           |
//+------------------------------------------------------------------+
bool CCanvas::Resize(const int width,const int height)
  {
//--- check
   if(m_objname!="" && m_rcname!="" && width>0 && height>0)
      if(ArrayResize(m_pixels,width*height)>0)
        {
         m_width =width;
         m_height=height;
         //--- initialize data with zeros
         ArrayInitialize(m_pixels,0);
         //--- create dynamic resource
         if(ResourceCreate(m_rcname,m_pixels,m_width,m_height,0,0,0,m_format))
           {
            //--- bind object with resource
            if(ObjectSetString(0,m_objname,OBJPROP_BMPFILE,m_rcname))
               return(true);
           }
        }
//--- error - destroy object
   Destroy();
   return(false);
  }
//+------------------------------------------------------------------+
//| Clear/Fill color                                                 |
//+------------------------------------------------------------------+
void CCanvas::Erase(const uint clr)
  {
   ArrayInitialize(m_pixels,clr);
  }
//+------------------------------------------------------------------+
//| Get pixel color                                                  |
//+------------------------------------------------------------------+
uint CCanvas::PixelGet(const int x,const int y) const
  {
//--- check coordinates
   if(x>=0 && x<m_width && y>=0 && y<m_height)
      return(m_pixels[y*m_width+x]);
//--- error
   return(0);
  }
//+------------------------------------------------------------------+
//| Get pixel color without coordinates check                        |                                                 |
//+------------------------------------------------------------------+
uint CCanvas::PixelGetFast(const int x,const int y) const
  {
   return(m_pixels[y*m_width+x]);
  }
//+------------------------------------------------------------------+
//| Set pixel                                                        |
//+------------------------------------------------------------------+
void CCanvas::PixelSet(const int x,const int y,const uint clr)
  {
//--- check coordinates
   if(x>=0 && x<m_width && y>=0 && y<m_height)
      m_pixels[y*m_width+x]=clr;
  }
//+------------------------------------------------------------------+
//| Set pixel without coordinates check                              |
//+------------------------------------------------------------------+
void CCanvas::PixelSetFast(const int x,const int y,const uint clr)
  {
   m_pixels[y*m_width+x]=clr;
  }
//+------------------------------------------------------------------+
//| Fill closed region with color                                    |
//+------------------------------------------------------------------+
void CCanvas::Fill(int x,int y,const uint clr)
  {
//--- check
   if(x<0 || x>=m_width || y<0 || y>=m_height) return;
//---
   int  index=y*m_width+x;
   uint old_clr=m_pixels[index];
//--- check if replacement is necessary
   if(old_clr==clr) return;
//--- use pseudo stack to emulate deeply-nested recursive calls
   int  stack[];
   uint count=1;
   int  idx;
   int  total=ArraySize(m_pixels);
//--- allocate memory for stack
   if(ArrayResize(stack,total)==-1) return;
   stack[0]=index;
   m_pixels[index]=clr;
   for(uint i=0;i<count;i++)
     {
      index=stack[i];
      x=index%m_width;
      //--- left adjacent point
      idx=index-1;
      if(x>0 && m_pixels[idx]==old_clr)
        {
         m_pixels[idx]=clr;
         stack[count++]=idx;
        }
      //--- top adjacent point
      idx=index-m_width;
      if(idx>=0 && m_pixels[idx]==old_clr)
        {
         m_pixels[idx]=clr;
         stack[count++]=idx;
        }
      //--- right adjacent point
      idx=index+1;
      if(x<m_width-1 && m_pixels[idx]==old_clr)
        {
         m_pixels[idx]=clr;
         stack[count++]=idx;
        }
      //--- bottom adjacent point
      idx=index+m_width;
      if(idx<total && m_pixels[idx]==old_clr)
        {
         m_pixels[idx]=clr;
         stack[count++]=idx;
        }
     }
//--- deallocate memory
   ArrayFree(stack);
  }
//+------------------------------------------------------------------+
//| Calculate result color with coordinates check                    |
//+------------------------------------------------------------------+
uint CCanvas::CalcColor(const uint clr_bBase,const uint clr,const int trans) const
  {
   int n_trans=256-trans;
   return(XRGB((GETRGBR(clr_bBase)*n_trans+GETRGBR(clr)*trans)>>8,
          (GETRGBG(clr_bBase)*n_trans+GETRGBG(clr)*trans)>>8,
          (GETRGBB(clr_bBase)*n_trans+GETRGBB(clr)*trans)>>8));
  }
//+------------------------------------------------------------------+
//| Draw vertical line                                               |
//+------------------------------------------------------------------+
void CCanvas::LineVertical(int x,int y1,int y2,const uint clr)
  {
   int tmp;
//--- sort by Y
   if(y1>y2)
     {
      tmp=y1;
      y1 =y2;
      y2 =tmp;
     }
//--- line is out of image boundaries
   if(y2<0 || y1>=m_height || x<0 || x>=m_width) return;
//--- stay withing image boundaries
   if(y1<0) y1=0;
   if(y2>=m_height-1) y2=m_height-1;
//--- draw line
   int index=y1*m_width+x;
   for(int i=y1;i<=y2;i++,index+=m_width)
      m_pixels[index]=clr;
  }
//+------------------------------------------------------------------+
//| Draw horizontal line                                             |
//+------------------------------------------------------------------+
void CCanvas::LineHorizontal(int x1,int x2,int y,const uint clr)
  {
   int tmp;
//--- sort by X
   if(x1>x2)
     {
      tmp=x1;
      x1 =x2;
      x2 =tmp;
     }
//--- line is out of image boundaries
   if(x2<0 || x1>=m_width || y<0 || y>=m_height) return;
//--- stay withing image boundaries
   if(x1<0) x1=0;
   if(x2>=m_width) x2=m_width-1;
//--- draw line
   ArrayFill(m_pixels,y*m_width+x1,x2-x1,clr);
  }
//+------------------------------------------------------------------+
//| Draw line according to Bresenham's algorithm                     |
//+------------------------------------------------------------------+
void CCanvas::Line(int x1,int y1,int x2,int y2,const uint clr)
  {
//--- line is out of image boundaries
   if((x1<0 && x2<0) || (y1<0 && y2<0)) return;
   if(x1>=m_width  && x2>=m_width)      return;
   if(y1>=m_height && y2>=m_height)     return;
//--- get length by X and Y
   int dx=(x2>x1)? x2-x1 : x1-x2;
   int dy=(y2>y1)? y2-y1 : y1-y2;
//--- vertical line
   if(dx==0)
     {
      LineVertical(x1,y1,y2,clr);
      return;
     }
//--- horizontal line
   if(dy==0)
     {
      LineHorizontal(x1,x2,y1,clr);
      return;
     }
//--- get direction by X and Y
   int sx=(x1<x2)? 1 : -1;
   int sy=(y1<y2)? 1 : -1;
   int er=dx-dy;
   int index;
   int size=ArraySize(m_pixels);
//--- continue to draw line
   while(x1!=x2 || y1!=y2)
     {
      index=y1*m_width+x1;
      if(index>=0 && index<size)
         m_pixels[index]=clr;
      //--- get coordinates of next pixel
      int er2=er<<1;
      if(er2>-dy)
        {
         er-=dy;
         x1+=sx;
        }
      if(er2<dx)
        {
         er+=dx;
         y1+=sy;
        }
     }
//--- set pixel at the end
   index=y2*m_width+x2;
   if(index>=0 && index<size)
      m_pixels[index]=clr;
  }
//+------------------------------------------------------------------+
//| Draw polyline                                                    |
//+------------------------------------------------------------------+
void CCanvas::Polyline(int &x[],int &y[],const uint clr)
  {
   int total=ArraySize(x);
   if(total>ArraySize(y))
      total=ArraySize(y);
//--- check
   if(total<2) return;
   total--;
//--- draw
   for(int i=0;i<total;i++)
      Line(x[i],y[i],x[i+1],y[i+1],clr);
  }
//+------------------------------------------------------------------+
//| Draw polygon                                                     |
//+------------------------------------------------------------------+
void CCanvas::Polygon(int &x[],int &y[],const uint clr)
  {
   int total=ArraySize(x);
   if(total>ArraySize(y))
      total=ArraySize(y);
//--- check
   if(total<2) return;
   total--;
//--- draw
   for(int i=0;i<total;i++)
      Line(x[i],y[i],x[i+1],y[i+1],clr);
//--- close the outline
   Line(x[total],y[total],x[0],y[0],clr);
  }
//+------------------------------------------------------------------+
//| Draw rectangle                                                   |
//+------------------------------------------------------------------+
void CCanvas::Rectangle(int x1,int y1,int x2,int y2,const uint clr)
  {
   LineHorizontal(x1,x2,y1,clr);
   LineVertical(x2,y1,y2,clr);
   LineHorizontal(x2,x1,y2,clr);
   LineVertical(x1,y2,y1,clr);
  }
//+------------------------------------------------------------------+
//| Draw arc according to Bresenham's algorithm                      |
//+------------------------------------------------------------------+
void CCanvas::Arc(int x,int y,int r,const double fi1,const double fi2,const uint clr)
  {
  }
//+------------------------------------------------------------------+
//| Draw circle according to Bresenham's algorithm                   |
//+------------------------------------------------------------------+
void CCanvas::Circle(int x,int y,int r,const uint clr)
  {
   int f   =1-r;
   int dd_x=1;
   int dd_y=-2*r;
   int dx  =0;
   int dy  =r;
   int xx,yy;
//---
   while(dy>=dx)
     {
      xx=x+dx;
      if(xx>=0 && xx<m_width)
        {
         yy=y+dy;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
         yy=y-dy;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
        }
      xx=x-dx;
      if(xx>=0 && xx<m_width)
        {
         yy=y+dy;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
         yy=y-dy;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
        }
      xx=x+dy;
      if(xx>=0 && xx<m_width)
        {
         yy=y+dx;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
         yy=y-dx;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
        }
      xx=x-dy;
      if(xx>=0 && xx<m_width)
        {
         yy=y+dx;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
         yy=y-dx;
         if(yy>=0 && yy<m_height) m_pixels[yy*m_width+xx]=clr;
        }
      //---
      if(f>=0)
        {
         dy--;
         dd_y+=2;
         f+=dd_y;
        }
      dx++;
      dd_x+=2;
      f+=dd_x;
     }
  }
//+------------------------------------------------------------------+
//| Draw triangle                                                    |
//+------------------------------------------------------------------+
void CCanvas::Triangle(int x1,int y1,int x2,int y2,int x3,int y3,const uint clr)
  {
   Line(x1,y1,x2,y2,clr);
   Line(x2,y2,x3,y3,clr);
   Line(x3,y3,x1,y1,clr);
  }
//+------------------------------------------------------------------+
//| Draw filled circle                                               |
//+------------------------------------------------------------------+
void CCanvas::FillCircle(int x,int y,int r,const uint clr)
  {
   int f   =1-r;
   int dd_x=1;
   int dd_y=-2*r;
   int dx  =0;
   int dy  =r;
//---
   while(dy>=dx)
     {
      LineHorizontal(x-dx,x+dx,y-dy,clr);
      LineHorizontal(x-dx,x+dx,y+dy,clr);
      LineHorizontal(x-dy,x+dy,y-dx,clr);
      LineHorizontal(x-dy,x+dy,y+dx,clr);
      //---
      if(f>=0)
        {
         dy--;
         dd_y+=2;
         f+=dd_y;
        }
      dx++;
      dd_x+=2;
      f+=dd_x;
     }
  }
//+------------------------------------------------------------------+
//| Draw filled rectangle                                            |
//+------------------------------------------------------------------+
void CCanvas::FillRectangle(int x1,int y1,int x2,int y2,const uint clr)
  {
   int tmp;
//--- sort vertexes
   if(x2<x1)
     {
      tmp=x1;
      x1 =x2;
      x2 =tmp;
     }
   if(y2<y1)
     {
      tmp=y1;
      y1 =y2;
      y2 =tmp;
     }
//--- stay withing screen boundaries
   if(x1<0)         x1=0;
   if(y1<0)         y1=0;
   if(x2>=m_width ) x2=m_width -1;
   if(y2>=m_height) y2=m_height-1;
//--- set pixels
   for(;y1<=y2;y1++)
      ArrayFill(m_pixels,y1*m_width+x1,x2-x1,clr);
  }
//+------------------------------------------------------------------+
//| Draw filled triangle                                             |
//+------------------------------------------------------------------+
void CCanvas::FillTriangle(int x1,int y1,int x2,int y2,int x3,int y3,const uint clr)
  {
   int    xx1,xx2,tmp;
   double k1=0,k2=0,xd1,xd2;
//--- sort vertexes from lesser to greater
   if(y1>y2)
     {
      tmp=y2;
      y2 =y1;
      y1 =tmp;
      tmp=x2;
      x2 =x1;
      x1=tmp;
     }
   if(y1>y3)
     {
      tmp=y1;
      y1 =y3;
      y3 =tmp;
      tmp=x1;
      x1 =x3;
      x3 =tmp;
     }
   if(y2>y3)
     {
      tmp=y2;
      y2 =y3;
      y3 =tmp;
      tmp=x2;
      x2 =x3;
      x3 =tmp;
     }
//--- all vertexes are out of image boundaries
   if(y3<0 || y1>m_height)  return;
   if(x1<0 && x2<0 && x3<0) return;
   if(x1>m_width && x2>m_width && x3>m_width) return;
//--- find coefficients of lines
   if((tmp=y1-y2)!=0) k1=(x1-x2)/(double)tmp;
   if((tmp=y1-y3)!=0) k2=(x1-x3)/(double)tmp;
//---
   xd1=x1;
   xd2=x1;
//---
   for(int i=y1;i<=y3;i++)
     {
      if(i==y2)
        {
         if((tmp=y2-y3)!=0) k1=(x2-x3)/(double)tmp;
         xd1=x2;
        }
      //--- calculate new boundaries of triangle line
      xx1 =(int)xd1;
      xd1+=k1;
      xx2 =(int)xd2;
      xd2+=k2;
      //--- triangle line is out of screen boundaries
      if(i<0 || i>=m_height) continue;
      //--- sort
      if(xx1>xx2)
        {
         tmp=xx1;
         xx1=xx2;
         xx2=tmp;
        }
      //--- line is out of screen boundaries
      if(xx2<0 || xx1>=m_width) continue;
      //--- draw only what is within screen boundaries
      if(xx1<0) xx1=0;
      if(xx2>=m_width) xx2=m_width-1;
      //--- draw horizontal line of triangle
      ArrayFill(m_pixels,i*m_width+xx1,xx2-xx1,clr);
     }
  }
//+------------------------------------------------------------------+
//| Draw line with antialiasing                                      |
//+------------------------------------------------------------------+
void CCanvas::LineAA(int x1,int y1,int x2,int y2,const uint clr)
  {
//--- check for input
   if(x1<0 || x1>=m_width ||
      x2<0 || x2>=m_width ||
      y1<0 || y1>=m_height ||
      y2<0 || y2>=m_height)
      return;
//--- vertical line
   if(x1==x2)
     {
      LineVertical(x1,y1,y2,clr);
      return;
     }
//--- horizontal line
   if(y1==y2)
     {
      LineHorizontal(x1,x2,y1,clr);
      return;
     }
//--- calculate dx,dy
   int    dx=x2-x1;
   int    dy=y2-y1;
//--- get absolute values
   dx=(dx<0)? -dx : dx;
   dy=(dy<0)? -dy : dy;
//--- line at angle of 45 degrees
   if(dx==dy)
     {
      Line(x1,y1,x2,y2,clr);
      return;
     }
//--- set first pixel
   m_pixels[y1*m_width+x1]=clr;
//--- new declarations
   uint   c;
   double gd,in;
   int    ad;
   int    tmp,i,m,index;
//--- line is greater by X
   if(dy<dx)
     {
      //--- sort by X
      if(x1>x2)
        {
         tmp=x1;
         x1 =x2;
         x2 =tmp;
         tmp=y1;
         y1 =y2;
         y2 =tmp;
        }
      //---
      dx=x2-x1;
      dy=y2-y1;
      gd=dy/(double)dx;
      m =x2;
      in=y1+gd;
      //--- draw line
      for(i=x1+1;i<m;i++,in+=gd)
        {
         //---
         y1=tmp=(int)floor(in);
         //--- pixel withing image boundaries
         if(y1>=0 && y1<m_height)
           {
            index=y1*m_width+i;
            ad=(int)((in-tmp)*256);
            c =m_pixels[index];
            m_pixels[index]=CalcColor(c,clr,ad);
           }
         //---
         y1=tmp+1;
         //--- pixel withing image boundaries
         if(y1>=0 && y1<m_height)
           {
            index=y1*m_width+i;
            c=m_pixels[index];
            m_pixels[index]=CalcColor(c,clr,256-ad);
           }
        }
     }
   else
     {
      //--- sort by Y
      if(y1>y2)
        {
         tmp=x1;
         x1 =x2;
         x2 =tmp;
         tmp=y1;
         y1 =y2;
         y2 =tmp;
        }
      //---
      dx=x2-x1;
      dy=y2-y1;
      gd=dx/(double)dy;
      m =y2;
      in=x1+gd;
      //--- draw line
      for(i=y1+1;i<m;i++,in+=gd)
        {
         x1=tmp=(int)floor(in);
         //--- pixel withing image boundaries
         if(x1>=0 && x1<m_width)
           {
            index=i*m_width+x1;
            ad=(int)((in-tmp)*256);
            c=m_pixels[index];
            m_pixels[index]=CalcColor(c,clr,ad);
           }
         //---
         x1=tmp+1;
         //--- pixel withing image boundaries
         if(x1>=0 && x1<m_width)
           {
            index=i*m_width+x1;
            c=m_pixels[index];
            m_pixels[index]=CalcColor(c,clr,256-ad);
           }
        }
     }
//--- set last pixel
   m_pixels[y2*m_width+x2]=clr;
  }
//+------------------------------------------------------------------+
//| Draw triangle with antialiasing                                  |
//+------------------------------------------------------------------+
void CCanvas::TriangleAA(int x1,int y1,int x2,int y2,int x3,int y3,const uint clr)
  {
   LineAA(x1,y1,x2,y2,clr);
   LineAA(x2,y2,x3,y3,clr);
   LineAA(x3,y3,x1,y1,clr);
  }
//+------------------------------------------------------------------+
//| Set level of transparency                                        |
//+------------------------------------------------------------------+
void CCanvas::SetTransparentLevel(const uchar value)
  {
   uint clr;
   int total=ArraySize(m_pixels);
   for(int i=0;i<total;i++)
     {
//      m_pixels[i]=TRGB(value,GETRGB(m_pixels[i]));
      clr=m_pixels[i]&0xFFFFFF;
//      if(clr!=0)
//      if(value==0)
//         clr|=value<<24;
      m_pixels[i]=((uint)value<<24)|(m_pixels[i]&0xFFFFFF);
     }
  }
//+------------------------------------------------------------------+
