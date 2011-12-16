
#define  NR_GPXLAT_BLOCKS  1
static gp_tty_GPXlatData gp_tty_GPXlatDataBlocks[NR_GPXLAT_BLOCKS];

static void
gp_tty_ClearGPXlatData(
gp_tty_GPXlatData*   p)
{
   struct tty_struct*   tty = p->tty;
   memset(p, 0, sizeof (*p));
   p->tty = tty;
}

static inline gp_tty_GPXlatData*
gp_tty_FindGPXlatData(
struct tty_struct*   tty)
{
   int   i;
   gp_tty_GPXlatData *gpx;
   for (i = 0, gpx = gp_tty_GPXlatDataBlocks; i < NR_GPXLAT_BLOCKS; i++)
   {
      if (gpx->tty == tty)
      {
         gp_tty_log("gp_tty_FindXlatData(0x%x), found: 0x%x\n", tty, gpx);
         return (gpx);
      }
   }

   gp_tty_log("gp_tty_FindXlatData(0x%x), found: NOTHING\n", tty);
   return (NULL);
}

gp_tty_GPXlatData *
gp_tty_NewGPXlatData(
struct tty_struct*   tty)
{
   int   i;
   gp_tty_GPXlatData *gpx;
   for (i = 0, gpx = gp_tty_GPXlatDataBlocks; i < NR_GPXLAT_BLOCKS; i++)
      if (gpx->tty == NULL)
      {
         gp_tty_ClearGPXlatData(gpx);
         gpx->tty = tty;
         return (gpx);
      }

   return (NULL);
}

int
gp_tty_open(
struct tty_struct*   tty)
{
   gp_tty_log("gp_tty_open(0x%x)\n", tty);
   gp_tty_GPXlatData* gpx;
   if ((gpx = gp_tty_FindGPXlatData(tty)) == NULL)
   {
      gpx = gp_tty_NewGPXlatData(tty);
      gp_tty_log("gp_tty_open: new ret: 0x%x\n", gpx);
   }
   else
   {
      gp_tty_log("gp_tty_open, find ret: 0x%x\n", gpx);
   }

   if (gpx)
   {
     tty->ldisc.flags |= N_TTY_F_GPXLATE;
     gp_tty_ClearGPXlatData(gpx);
   }

   return (gpx ? 0 : -ENOMEM);
}

void
gp_tty_close(
struct tty_struct*   tty)
{
  gp_tty_log("gp_tty_close(0x%x)\n", tty);
  gp_tty_GPXlatData* gpx;
  if ((gpx = gp_tty_FindGPXlatData(tty)) != NULL)
  {
     gp_tty_log("gp_tty_close: find ret: 0x%x\n", gpx);
     gpx->tty = NULL;
  }
  else
  {
     gp_tty_log("gp_tty_close: find ret NULL\n");
  }

  tty->ldisc.flags &= ~N_TTY_F_GPXLATE;
}

static inline void
gp_tty_send1(
struct tty_struct*   tty, 
unsigned char        b)
{
   put_tty_queue(b, tty);
}

static inline void
gp_tty_send3(
struct tty_struct*   tty, 
unsigned char        b1,
unsigned char        b2,
unsigned char        b3)
{
   gp_tty_send1(tty, b1);
   gp_tty_send1(tty, b2);
   gp_tty_send1(tty, b3);
}

static inline void
gp_tty_GlidePointXlat(
struct tty_struct*   tty, 
gp_tty_GPXlatData*   gpx,
unsigned char        byt,
char                 errors)
{
   int   b4set, b3set;

   /* skip the 0x4d 0x33 that the pad emits when the device is opened. */
   if (gpx->numProtocolHeadersSeen < 2)
   {
      if (gp_tty_IsProtocolHeader(byt))
      {
         if (++gpx->numProtocolHeadersSeen < 2)
            return;
      }
      else
         return;
   }

   if (gpx->byteIndex == 0)
   {
      if (!gp_tty_IsProtocolHeader(byt))
      {
         gpx->b4mode = 1;
         b4set = gp_tty_Button4Down(byt);
         byt &= ~gp_tty_Button4Bit;
         b3set = gpx->send4 = gp_tty_Button3Down(byt);
         if (gpx->send4)
            gp_tty_send1(tty, byt);
         if (b4set && !gp_tty_Button1Down(gpx->lastb0))
         {
            gp_tty_send3(tty, gpx->lastb0 | gp_tty_Button1Bit, 0, 0);
            if (gpx->send4)
               gp_tty_send1(tty, byt);
         }
         return;
      }
      else
         gpx->lastb0 = byt;
   }

   if (!gpx->b4mode)
   {
      gp_tty_send1(tty, byt);
      gp_tty_CountByte(gpx);
      return;
   }

   /* else we are in 4 byte mode */
   if (gpx->byteIndex == 3)
   {
      gpx->b4mode = byt;
      if (gp_tty_Button4Down(byt))
      {
         gpx->buf[0] |= gp_tty_Button1Bit;
         byt &= ~ gp_tty_Button4Bit;
      }
      if (gp_tty_Button3Down(byt))
          gpx->send4 = 1;

      gp_tty_send3(tty, gpx->buf[0], gpx->buf[1], gpx->buf[2]);
      if (gpx->send4)
         gp_tty_send1(tty, byt);
      if (!gpx->b4mode || !gp_tty_Button3Down(byt))
         gpx->send4 = 0;

      gpx->byteIndex = 0;
      return;
   }
   
   gpx->buf[gpx->byteIndex++] = byt;
}
