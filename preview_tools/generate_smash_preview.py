"""Create a standalone badminton smash animation preview (not an app asset)."""

from pathlib import Path
import math
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

W, H, FPS, DURATION = 1280, 720, 30, 12
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "preview" / "badminton_smash_animation_preview.mp4"
FONT = r"C:\Windows\Fonts\msjh.ttc"
FONT_BOLD = r"C:\Windows\Fonts\msjhbd.ttc"


def f(size, bold=False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT, size)


def mix(a, b, t):
    return a + (b - a) * t


def pt(a, b, t):
    return mix(a[0], b[0], t), mix(a[1], b[1], t)


def ease(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


POSES = [
    dict(head=(325,245), neck=(325,290), hip=(325,420), le=(280,340), lw=(260,400), re=(395,345), rw=(430,305), racket=(465,260), lk=(275,510), lf=(235,600), rk=(390,510), rf=(435,600)),
    dict(head=(330,235), neck=(325,285), hip=(310,420), le=(270,325), lw=(245,290), re=(390,275), rw=(350,225), racket=(300,155), lk=(270,510), lf=(245,600), rk=(390,500), rf=(425,590)),
    dict(head=(360,200), neck=(350,250), hip=(335,385), le=(300,300), lw=(275,335), re=(420,205), rw=(495,135), racket=(565,105), lk=(290,470), lf=(255,555), rk=(400,465), rf=(445,550)),
    dict(head=(380,240), neck=(370,290), hip=(360,425), le=(315,350), lw=(290,405), re=(430,360), rw=(400,435), racket=(375,505), lk=(315,515), lf=(280,600), rk=(420,510), rf=(460,600)),
    dict(head=(350,245), neck=(350,295), hip=(350,425), le=(305,350), lw=(290,410), re=(405,350), rw=(435,395), racket=(465,440), lk=(305,515), lf=(275,605), rk=(405,515), rf=(440,605)),
]

PHASES = [
    (0,2.2,"1  準備","側身放鬆，重心落在前腳掌",0,0),
    (2.2,5.2,"2  架拍／引拍","手肘抬高，肩髖蓄力，不要只拉手腕",0,1),
    (5.2,7.5,"3  加速擊球","蹬地轉髖，擊球點保持在身體前上方",1,2),
    (7.5,10,"4  隨揮","球拍自然跨過身體，避免突然煞停",2,3),
    (10,12,"5  回位","落地保持平衡，立刻回到準備姿勢",3,4),
]


def phase(sec):
    for start,end,title,cue,a,b in PHASES:
        if sec < end:
            return title,cue,a,b,ease((sec-start)/(end-start))
    return "5  回位",PHASES[-1][3],4,4,1


def pose(a,b,t):
    return {k: pt(POSES[a][k],POSES[b][k],t) for k in POSES[a]}


def court(d):
    d.rounded_rectangle((35,75,895,675),28,fill="#0E5A35")
    for line in [(60,620,860,620),(60,100,860,100),(60,100,60,620),(860,100,860,620)]:
        d.line(line,fill="white",width=4)
    d.line((650,100,650,620),fill="#D7F1E3",width=6)
    for y in range(120,620,15): d.line((648,y,658,y),fill="#A8D4B8",width=1)
    d.text((670,112),"球網",font=f(20),fill="#D8EDDF")


def player(d,p):
    neck,hip=p["neck"],p["hip"]
    ls,rs=(neck[0]-20,neck[1]+22),(neck[0]+25,neck[1]+22)
    skin,shorts="#E6B88A","#173F70"
    d.line((ls,p["le"],p["lw"]),fill=skin,width=20,joint="curve")
    d.line((rs,p["re"],p["rw"]),fill=skin,width=21,joint="curve")
    d.line((hip,p["lk"],p["lf"]),fill=shorts,width=27,joint="curve")
    d.line((hip,p["rk"],p["rf"]),fill=shorts,width=27,joint="curve")
    for foot in (p["lf"],p["rf"]): d.line((foot[0]-15,foot[1],foot[0]+28,foot[1]),fill="white",width=14)
    d.polygon([(ls[0]-8,ls[1]-5),(rs[0]+8,rs[1]-5),(hip[0]+34,hip[1]),(hip[0]-34,hip[1])],fill="#F4C14C")
    h=p["head"]; d.ellipse((h[0]-28,h[1]-31,h[0]+28,h[1]+31),fill=skin)
    d.arc((h[0]-28,h[1]-33,h[0]+28,h[1]+8),180,360,fill="#202A27",width=12)
    wrist,racket=p["rw"],p["racket"]; d.line((wrist,racket),fill="#292F2D",width=7)
    ang=math.atan2(racket[1]-wrist[1],racket[0]-wrist[0]); c=(racket[0]+math.cos(ang)*28,racket[1]+math.sin(ang)*28)
    d.ellipse((c[0]-24,c[1]-35,c[0]+24,c[1]+35),outline="white",width=5)
    for key in ("le","re","lk","rk"):
        x,y=p[key]; d.ellipse((x-6,y-6,x+6,y+6),fill="#FF6B6B")


def shuttle(d,sec):
    if sec<5.8: x,y=pt((820,170),(575,110),ease(sec/5.8))
    else:
        t=ease(min(1,(sec-5.8)/1.4)); x,y=pt((575,110),(815,500),t)
        d.line((575,110,x,y),fill="#FFE7A4",width=7)
    d.ellipse((x-8,y-8,x+8,y+8),fill="white")
    d.polygon([(x-7,y-5),(x-20,y-25),(x+7,y-9)],fill="#E7ECE9")


def panel(d,sec,title,cue):
    d.rounded_rectangle((925,75,1245,675),28,fill="#F6F8F4")
    d.text((960,108),"殺球動作動畫",font=f(31,True),fill="#0A3F27")
    d.text((960,154),"SMASH MOTION",font=f(17,True),fill="#64736C")
    d.rounded_rectangle((955,205,1215,295),18,fill="#EAF4E7")
    d.text((978,228),title,font=f(28,True),fill="#0A3F27")
    d.text((960,334),"本階段重點",font=f(21,True),fill="#20302A")
    lines=[]; line=""
    for ch in cue:
        if d.textlength(line+ch,font=f(20))>235: lines.append(line); line=ch
        else: line+=ch
    lines.append(line)
    for i,text in enumerate(lines): d.text((960,373+i*34),text,font=f(20),fill="#64736C")
    d.text((960,515),"動作進度",font=f(18,True),fill="#20302A")
    d.rounded_rectangle((960,552,1210,570),9,fill="#DCE4DC")
    d.rounded_rectangle((960,552,960+250*min(1,sec/DURATION),570),9,fill="#0E5A35")
    d.text((960,590),"準備 → 引拍 → 擊球 → 回位",font=f(16),fill="#64736C")


def frame(i):
    sec=i/FPS; title,cue,a,b,t=phase(sec); p=pose(a,b,t)
    im=Image.new("RGB",(W,H),"#DDE9DE"); d=ImageDraw.Draw(im)
    court(d); shuttle(d,sec); player(d,p); panel(d,sec,title,cue)
    d.rounded_rectangle((55,25,350,62),16,fill="white")
    d.text((73,33),"動畫預覽｜尚未加入 App",font=f(18,True),fill="#0A3F27")
    return cv2.cvtColor(np.asarray(im),cv2.COLOR_RGB2BGR)


def main():
    OUT.parent.mkdir(parents=True,exist_ok=True)
    writer=cv2.VideoWriter(str(OUT),cv2.VideoWriter_fourcc(*"mp4v"),FPS,(W,H))
    if not writer.isOpened(): raise RuntimeError("無法建立 MP4")
    try:
        for i in range(FPS*DURATION): writer.write(frame(i))
    finally: writer.release()
    print(OUT)


if __name__=="__main__": main()
