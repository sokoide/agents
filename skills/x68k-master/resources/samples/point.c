#include <stdio.h>
#include <stdlib.h>

typedef struct friend_loop {
  char *name;                /* –¼‘O */
  char *address;             /* ZŠ */
  char *tel_no;              /* “d˜b”Ô† */
  int  sex;                  /* «•Ê */
  struct friend_loop *next;  /* —F’B‚Ö‚Ìƒ|ƒCƒ“ƒ^ */
} FRIEND;

FRIEND *root;

void
make_root ()
{
  /* ‚Ü‚¸ƒƒ‚ƒŠ‚ðŠm•Û‚µ‚Ü‚·B */
  root = malloc (sizeof (FRIEND));

  /* –¼‘O‚ð“o˜^ */
  root -> name = "‚æ‚µ‚­‚ñ";
  /* ZŠ‚ð“o˜^ */
  root -> address = "‹´‚Ì‰º";
  /* “d˜b‚ð“o˜^ */
  root -> tel_no  = "0123-45-6789";

  /* —F’B‚ÍŒ»Ý‚¢‚È‚¢ */
  root -> next = 0;
}


void
add_friend(char *name, char *address, char *tel_no)
{
  FRIEND *new_p;
  FRIEND *p;
  /* —F’B‚ª‚¢‚È‚¢l‚Ü‚Å‚½‚Ç‚é */
  for (p = root; p -> next; p = p -> next)
    ;
  
  /* ƒƒ‚ƒŠ‚ðŠm•Û‚µ‚Ä */
  new_p = malloc (sizeof (FRIEND));
  /* —F’B‚Ì—Ö‚É‚¢‚ê‚Ä‚ ‚°‚é */
  p -> next = new_p;

  new_p -> name = name;
  new_p -> address = address;
  new_p -> tel_no = tel_no;

  /* ŽŸ‚Í‚¢‚È‚¢ */
  new_p -> next = 0;
}

void
main()
{
  FRIEND *x;
  make_root ();
  add_friend ("‚­‚ñ‚¿‚á‚ñ", "‰_‚Ìã", "123-4565");
  add_friend ("‚¨‚Á‚«‚ñ", "ŠC‚Ì’†", "456-4579");
  add_friend ("‚Ü‚±‚¿‚á‚ñ", "ŽR‚Ì’¸", "456-4579");
  for (x = root; x -> next; x = x -> next)
    printf ("%s‚Ì—F’B‚Í%s‚Å‚·\n",x -> name, x -> next -> name);
}
