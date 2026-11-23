#include "same.h"
#if defined(__APPLE__) || defined(__linux__)
 #define NANOSLEEP_AVAILABLE
#else
 #include <limits.h>
#endif

// Find a directory to place settings and saved games in: the per-user
// state folder, $XDG_STATE_HOME/same (else ~/.local/state/same; on Windows
// %LOCALAPPDATA%\same). A ~/.same left by an earlier version is moved
// there the first time, so no saved game or highscore is lost.
static int make_dir(const char *path) {
 #if defined(_WIN32)
  return mkdir(path);
 #else
  return mkdir(path,S_IRWXU);
 #endif
}

int set_dir() {
 static bool done = false;
 if (done) return 0;
 char base[1024] = "";
 const char *state = getenv("XDG_STATE_HOME");
 const char *home = getenv("HOME");
 #if defined(_WIN32)
  const char *local = getenv("LOCALAPPDATA");
  if (local != NULL && local[0] != '\0') {
   snprintf(dir,sizeof dir,"%s\\same",local);
   make_dir(dir);
   done = true;
   return 0;
  }
  if (home == NULL || home[0] == '\0') home = getenv("USERPROFILE");
 #endif
 if (state != NULL && state[0] == '/') {
  snprintf(base,sizeof base,"%s",state);
 } else if (home != NULL && home[0] != '\0') {
  snprintf(base,sizeof base,"%s/.local",home);
  make_dir(base);
  snprintf(base,sizeof base,"%s/.local/state",home);
 } else {
  snprintf(dir,sizeof dir,".");
  done = true;
  return -1;
 }
 make_dir(base);
 snprintf(dir,sizeof dir,"%s/same",base);

 struct stat st;
 if (stat(dir,&st) != 0 && home != NULL && home[0] != '\0') {
  char old[1024];
  snprintf(old,sizeof old,"%s/.same",home);
  if (stat(old,&st) == 0 && S_ISDIR(st.st_mode)) rename(old,dir);
 }
 make_dir(dir);
 done = true;
 return 0;
}


// Since there's no standard method for obtaining a char without hitting the
// return key, we're going to use system dependent funcitons for this.
int ask_char() {
 #if defined(__NCURSES__)
  return getch();
 #endif
 return -1;
}

int rest() {
 //#if defined(__APPLE__) || defined(__linux__)
 #if defined(NANOSLEEP_AVAILABLE)
  struct timespec time1, time2;
  time1.tv_sec = 0;
  time1.tv_nsec = 25000000;
  nanosleep(&time1,&time2);
  return 0;
 #else
  // If we can't find a suitable function to sleep less than a second, we'll
  // fall back on a busy wait. It's an ugly hack, so we'll avoid this on
  // every system we officially support.
  for (int c = 0; c < INT_MAX/100; c++);
 #endif
 return -1;
}

