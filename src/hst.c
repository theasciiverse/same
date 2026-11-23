#include "same.h"

int set_hst_fn() {
 set_dir();
 snprintf(hst_fn,sizeof hst_fn,"%s/.hst-%d-%d-%d",dir,(int)difficulty,width,height);

 return 0;
}

int get_hsn() {
 clear_command();
 prompt_str("New highscore! Name:",hsn,sizeof hsn);
 while (strcmp(hsn,"") == 0) {
  draw_error("Name is required");
  ask_char();
  clear_command();
  prompt_str("New highscore! Name:",hsn,sizeof hsn);
 }
 write_hst();
 return 0;
}

int read_hst() {
 highscore = 0;
 set_hst_fn();
 FILE *hstf = fopen(hst_fn,"r");
 if (hstf == NULL) {
  if (access(hst_fn,F_OK) != -1) {
   draw_error("Highscore file exists, but cannot be opened to read");
  } else {
   draw_command("Highscore file does not exist");
  }
  return 1;
 }
 if (fgets(hsn,sizeof hsn,hstf) == NULL) hsn[0] = '\0';
 hsn[strcspn(hsn,"\r\n")] = '\0';
 if (fscanf(hstf,"%i",&highscore) != 1) highscore = 0;
 fclose(hstf);
 return 0;
}

int write_hst() {
 FILE *hstf = fopen(hst_fn,"w");
 if (hstf == NULL) {
   draw_error("Could not open highscore file to write");
   return 1;
 }
 if (score > highscore) highscore = score;
 fprintf(hstf,"%s\n",hsn);
 fprintf(hstf,"%i\n",highscore);
 fclose(hstf);
 return 0;
}

