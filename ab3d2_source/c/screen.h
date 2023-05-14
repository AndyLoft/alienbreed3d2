#ifndef SCREEN_C
#define SCREEN_C

#include <graphics/gfx.h>

extern const int SCREEN_WIDTH;
extern const int SCREEN_HEIGHT;

extern struct MsgPort *Vid_DisplayMsgPort_l;
extern struct ScreenBuffer *Vid_ScreenBuffers_vl[2];
extern struct Screen *Vid_MainScreen_l;
extern struct Window *Vid_MainWindow_l;
extern BYTE Vid_DoubleHeight_b;
extern PLANEPTR Vid_Screen1Ptr_l;
extern PLANEPTR Vid_Screen2Ptr_l;

extern void LoadMainPalette(void);
extern BOOL Vid_OpenMainScreen(void);
extern void vid_SetupDoubleheightCopperlist(void);
extern void Vid_CloseMainScreen(void);

#endif  // SCREEN_C