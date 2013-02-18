//+------------------------------------------------------------------+
//|                                                   OpenCLTest.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| OpenCL function code                                             |
//+------------------------------------------------------------------+
const string cl_src=
                    "__kernel void MFractal(                                    \r\n"
                    "                       float x0,                           \r\n"
                    "                       float y0,                           \r\n"
                    "                       float x1,                           \r\n"
                    "                       float y1,                           \r\n"
                    "                       uint  max,                          \r\n"
                    "              __global uint *out)                          \r\n"
                    "  {                                                        \r\n"
                    "   size_t  w = get_global_size(0);                         \r\n"
                    "   size_t  h = get_global_size(1);                         \r\n"
                    "   size_t gx = get_global_id(0);                           \r\n"
                    "   size_t gy = get_global_id(1);                           \r\n"
                    "   float dx = x0 + gx * (x1-x0) / (float) w;               \r\n"
                    "   float dy = y0 + gy * (y1-y0) / (float)h;                \r\n"
                    "   float x  = 0;                                           \r\n"
                    "   float y  = 0;                                           \r\n"
                    "   float xx = 0;                                           \r\n"
                    "   float yy = 0;                                           \r\n"
                    "   float xy = 0;                                           \r\n"
                    "   uint i = 0;                                             \r\n"
                    "   while ((xx+yy)<4 && i<max)                              \r\n"
                    "     {                                                     \r\n"
                    "      xx = x*x;                                            \r\n"
                    "      yy = y*y;                                            \r\n"
                    "      xy = x*y;                                            \r\n"
                    "      y = xy+xy+dy;                                        \r\n"
                    "      x = xx-yy+dx;                                        \r\n"
                    "      i++;                                                 \r\n"
                    "     }                                                     \r\n"
                    "   if(i==max)                                              \r\n"
                    "      out[w*gy+gx] = 0;                                    \r\n"
                    "   else                                                    \r\n"
                    "      out[w*gy+gx] = (uint)((float)0xFFFFFF/(float)max)*i; \r\n"
                    "  }                                                        \r\n";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define SIZE_X 512
#define SIZE_Y 512
//+------------------------------------------------------------------+
//| BMP file header                                                  |
//+------------------------------------------------------------------+
struct BitmapHeader
  {
   ushort            type;
   uint              size;
   uint              reserv;
   uint              offbits;
   uint              imgSSize;
   uint              imgWidth;
   uint              imgHeight;
   ushort            imgPlanes;
   ushort            imgBitCount;
   uint              imgCompression;
   uint              imgSizeImage;
   uint              imgXPelsPerMeter;
   uint              imgYPelsPerMeter;
   uint              imgClrUsed;
   uint              imgClrImportant;
  };
//+------------------------------------------------------------------+
//| Save bitmap to file                                              |
//+------------------------------------------------------------------+
bool SaveBitmapToFile(const string filename,uint &bitmap[],const BitmapHeader &info)
  {
//--- opening the file
   int file=FileOpen(filename,FILE_WRITE|FILE_BIN);
   if(file==INVALID_HANDLE)
     {
      Print(__FUNCTION__," error opening '",filename,"'");
      return(false);
     }
//--- setting the header and the body
   if(FileWriteStruct(file,info)==sizeof(info))
     {
      if(FileWriteArray(file,bitmap)==ArraySize(bitmap))
        {
         FileClose(file);
         return(true);
        }
     }
//--- failed; it is better to delete the file
   FileClose(file);
   FileDelete(filename);
   Print(__FUNCTION__," error writting '",filename,"'");
//--- get the error back
   return(false);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int cl_ctx;
   int cl_prg;
   int cl_krn;
   int cl_mem;
//--- initializing OpenCL objects
   if((cl_ctx=CLContextCreate())==INVALID_HANDLE)
     {
      Print("OpenCL not found");
      return;
     }
   if((cl_prg=CLProgramCreate(cl_ctx,cl_src))==INVALID_HANDLE)
     {
      CLContextFree(cl_ctx);
      Print("OpenCL program create failed");
      return;
     }
   if((cl_krn=CLKernelCreate(cl_prg,"MFractal"))==INVALID_HANDLE)
     {
      CLProgramFree(cl_prg);
      CLContextFree(cl_ctx);
      Print("OpenCL kernel create failed");
      return;
     }
   if((cl_mem=CLBufferCreate(cl_ctx,SIZE_X*SIZE_Y*sizeof(uint),CL_MEM_READ_WRITE))==INVALID_HANDLE)
     {
      CLKernelFree(cl_krn);
      CLProgramFree(cl_prg);
      CLContextFree(cl_ctx);
      Print("OpenCL buffer create failed");
      return;
     }
//--- getting ready for execution
   float x0       =-2;
   float y0       =-0.5;
   float x1       =-1;
   float y1       = 0.5;
   uint  max      = 20000;
   uint  offset[2]={0,0};
   uint  work  [2]={SIZE_X,SIZE_Y};
//--- setting unchangeable OpenCL function parameters
   CLSetKernelArg(cl_krn,4,max);
   CLSetKernelArgMem(cl_krn,5,cl_mem);
//--- preparing the buffer for the pixels display
   uint buf[];
   ArrayResize(buf,SIZE_X*SIZE_Y);
//--- preparing the header
   BitmapHeader info;
   ZeroMemory(info);
   info.type          =0x4d42;
   info.size          =sizeof(info)+SIZE_X*SIZE_Y*4;
   info.offbits       =sizeof(info);
   info.imgSSize      =40;
   info.imgWidth      =SIZE_X;
   info.imgHeight     =SIZE_Y;
   info.imgPlanes     =1;
   info.imgBitCount   =32;
   info.imgCompression=0;                // BI_RGB
   info.imgSizeImage  =SIZE_X*SIZE_Y*4;
//--- creating the object for graphics display
   ObjectCreate(0,"x",OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetInteger(0,"x",OBJPROP_XDISTANCE,4);
   ObjectSetInteger(0,"x",OBJPROP_YDISTANCE,26);
//--- rendering, till we are not stopped from the outside
   while(!IsStopped())
     {
      uint x=GetTickCount();
      //--- setting floating parameters
      CLSetKernelArg(cl_krn,0,x0);
      CLSetKernelArg(cl_krn,1,y0);
      CLSetKernelArg(cl_krn,2,x1);
      CLSetKernelArg(cl_krn,3,y1);
      //--- rendering the frame
      CLExecute(cl_krn,2,offset,work);
      //--- taking the frame data
      CLBufferRead(cl_mem,buf);
      //--- outputting the rendering time
      Comment(IntegerToString(GetTickCount()-x)+" msec per frame");
      //--- saving the frame in memory and drawing it
      SaveBitmapToFile("Mandelbrot.bmp",buf,info);
      ObjectSetString(0,"x",OBJPROP_BMPFILE,NULL);
      ObjectSetString(0,"x",OBJPROP_BMPFILE,"\\Files\\Mandelbrot.bmp");
      ChartRedraw();
      //--- a small pause and parameters update for the next frame
      Sleep(10);
      x0+=0.001f;
      x1-=0.001f;
      y0+=0.001f;
      y1-=0.001f;
     }
//--- removing OpenCL objects
   CLBufferFree(cl_mem);
   CLKernelFree(cl_krn);
   CLProgramFree(cl_prg);
   CLContextFree(cl_ctx);
  }
//+------------------------------------------------------------------+
