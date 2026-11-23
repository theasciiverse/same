#include "same.h"

int read_script(char fn[]) {
 FILE *f = fopen(fn,"r");
 if (f == NULL) {
  char msg[1100];
  snprintf(msg,sizeof msg,"Unable to load script %s",fn);
  draw_error(msg);
  return 1;
 }
 char line[1024];

 // Plain C (fgets, strchr) so this builds everywhere, Windows included
 while (fgets(line,sizeof line,f) != NULL) {
  line[strcspn(line,"\r\n")] = '\0';

  // Ignore everything on a line after a comment
  char *comment = strstr(line,"//");
  if (comment != NULL) *comment = '\0';

  // Process each command separated by a semicolon
  char *token = line;
  while (token != NULL) {
   char *next = strchr(token,';');
   if (next != NULL) *next++ = '\0';

   // Process statement
   if (*token != '\0') evaluate(token,true);

   // Read next statement
   token = next;
  }
 }

 fclose(f);
 return 0;
}

int evaluate(char *cmd,bool script_mode) {
 // Evaluate expression enclosed by `cmd` and prepend its result to the
 // proceeding command. Example: `undonum`u will undo the board to its
 // original state.
 char str[32];
 char next[1100];
 int i;
 if (cmd[0] == '`') {
  int j = 0;
  for (i = 1; cmd[i] != '\0' && cmd[i] != '`'; i++) {
   if (j < (int)sizeof str - 1) str[j++] = cmd[i];
  }
  str[j] = '\0';
  cmd = cmd[i] == '`' ? &cmd[i+1] : &cmd[i];
  snprintf(next,sizeof next,"%d%s",evaluate(str,script_mode),cmd);
  return evaluate(next,script_mode);
 }


 // Remove white space from command & argument
 char argument[32];
 char command[32];
 strcpy(command,"");
 if (sscanf(cmd,"%31s %31s",command,argument) > 1) {
  char both[64];
  snprintf(both,sizeof both,"%s %s",command,argument);
  return read_command(both,script_mode);
 }

 // Return command
 return read_command(command,script_mode);
} 

