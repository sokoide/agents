/* バスエラートラップする */
main()
{
  char *p = 0;
  char c;
  init_trap14 ();
  c = *p;
  return c;
}
