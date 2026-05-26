/* system include */
#include <stdio.h>
#include <interrupt.h>

#ifdef DEV_GCC
/* Develop 版 GCC 拡張 */
DOSCALL INTVCG (short);
DOSCALL INTVCS (short, void *);
DOSCALL PRINT (char *);
#else
#include <doslib.h>
#endif

/*
stdin,stdout が XC Ver 依存のため
sprintf でマクロにしておく
*/
#define Fprint(buf,fmt,mes)    \
do {                           \
  sprintf ((buf),(fmt),(mes)); \
  PRINT ((buf));               \
} while (0)


static struct {
 int flag;                  /* エラー種別フラグ */
 unsigned short sr_reg;     /* エラー時の SR    */
 int pc_reg;                /* エラー時の PC    */
 char *mes;                 /* メッセージ       */
} trapbuf;

static void (*trap_14)();   /* 元の trap 14 ベクタを保存 */

void (*usr_abort)(void);    /* ユーザーのアボート処理関数 */

extern int _main;           /* スタートアップのダミー */

static void
trap14(void)
{
  PRAMREG (code, d7);       /* パラメータレジスタ d7 */
  PRAMREG (add,  a6);       /* パラメータレジスタ a6 */
  SET_FRAME (a5);           /* フレームポインタを a5 に指定 */
  char *p =(char *)add;

  /* code からエラーを分析 */
  switch (code&0xffff)
    {
    case 2:
      /* バスエラー */
      trapbuf.flag = code;
      trapbuf.mes = "バスエラーが発生しました";
      break;
    case 3:
      /* アドレスエラー */
      trapbuf.flag = code;
      trapbuf.mes = "アドレスエラーが発生しました";
      break;
    case 4:
      /* おかしな命令 */
      trapbuf.flag = code;
      trapbuf.mes = "おかしな命令を実行しました";
      break;
    }
 if ((code &0xff00))
   {
     if ((code &0xff) == 2)
       {
         trapbuf.flag = -1;
         trapbuf.mes  = "ドライブの準備ができていません";
       }
    }
 if (trapbuf.flag || (code&0xffff) == 0x1f || (code&0xffff) == 0x301f)
    {
      trapbuf.sr_reg = *(short *)p;
      p+=2;
      trapbuf.pc_reg = *(int *)p;
      asm ("\tmove.w #$ff,d0\n\ttrap #15\n");
      IJUMP_RTE();
    }
  else
    IJUMP(trap_14);
}

static void
my_abort(void)
{
  char buf[64];
  INTVCS(0x2e,trap_14);
  if (usr_abort)
    usr_abort ();
  if (trapbuf.flag > 0)
    {
      extern int _SSTA;
      extern int _PSTA;
      trapbuf.flag = 0;
      Fprint (buf,"%s\r\n",trapbuf.mes);
      Fprint (buf," pc=%X",trapbuf.pc_reg);
      Fprint (buf," offset=%X\r\n",trapbuf.pc_reg - (int) &_main);
      exit(512);
    }
  else
    {
      Fprint (buf,"%s\r\n",trapbuf.mes);
      exit (256);
    }
}

void
init_trap14 (void)
{
  trap_14 = (void *)INTVCG (0x2e);
  INTVCS (0x2e,trap14);
  INTVCS (0xfff2,my_abort);
  INTVCS (0xfff1,my_abort);
}
