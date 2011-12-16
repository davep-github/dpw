#ifndef  gp_tty_included
#define  gp_tty_included

#define  gp_tty_Button1Bit  (0x20)   /* in protocol byte 0 */
#define  gp_tty_Button2Bit  (0x10)   /* in protocol byte 0 */
#define  gp_tty_Button3Bit  (0x20)   /* in protocol byte 3 */
#define  gp_tty_Button4Bit  (0x10)   /* in protocol byte 3 */

#define  gp_tty_ProtocolHeaderBit (0x40)

#define  gp_tty_Button1Down(b) ((b) & gp_tty_Button1Bit)
#define  gp_tty_Button2Down(b) ((b) & gp_tty_Button2Bit)
#define  gp_tty_Button3Down(b) ((b) & gp_tty_Button3Bit)
#define  gp_tty_Button4Down(b) ((b) & gp_tty_Button4Bit)

#define  gp_tty_IsProtocolHeader(b)  ((b) & gp_tty_ProtocolHeaderBit)

#define  gp_tty_CountByte(p) ((p)->byteIndex = ((p)->byteIndex >= 2) ? 0 : \
                                              (p)->byteIndex + 1)

typedef struct gp_tty_GPXlatData
{
   struct tty_struct*	tty;
   int            byteIndex;
   int            b4mode;
   int            send4;
   int            numProtocolHeadersSeen;
   unsigned char  lastb0;
   unsigned char  buf[4];
}
   gp_tty_GPXlatData;

extern int
gp_tty_open(
struct tty_struct*   tty);

extern void
gp_tty_close(
struct tty_struct*   tty);

#define  TCSETGPXLAT       (TIOCSERSETMULTI + 1)
#define  TCCLRGPXLAT       (TCSETGPXLAT + 1)
#define  N_TTY_F_GPXLATE   (0x02)

#define  gp_tty_IsTrueGPXlatMode(tty)  ((tty)->ldisc.flags & N_TTY_F_GPXLATE)

#endif
