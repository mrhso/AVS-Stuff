# 2020.04.06 edit with HBD in mind
function GrainFactory3(clip src,int "g1str",int "g2str",int "g3str",int "g1shrp",int "g2shrp",int "g3shrp",
 \                        float "g1size", float "g2size", float "g3size",
 \                        int "g1tex", int "g2tex", int "g3tex", int "temp_avg", int "ontop_grain",
 \                        int "th1", int "th2", int "th3", int "th4", bool  "use_sAverageLumaMask")
{

sisavs26	= !(VersionNumber() < 2.60)
sisphbd		= AvsPlusVersionNumber > 2294

sislumaonly = sisphbd ? src.isy() : sisavs26 ? src.isy8() : true
clp = sislumaonly ? src : sisphbd ? src.converttoy() : src.converttoy8()

g1str       = default( g1str,        13 )  # [ 0 - ???] strength of grain / for dark areas
g2str       = default( g2str,        15 )  # [ 0 - ???] strength of grain / for midtone areas
g3str       = default( g3str,        25 )  # [ 0 - ???] strength of grain / for bright areas
g1shrp      = default( g1shrp,       60 )  # [ 0 - 100] sharpness of grain / for dark areas (NO EFFECT when g1size=1.0 !!)
g2shrp      = default( g2shrp,       66 )  # [ 0 - 100] sharpness of grain / for midtone areas (NO EFFECT when g2size=1.0 !!)
g3shrp      = default( g3shrp,       80 )  # [ 0 - 100] sharpness of grain / for bright areas (NO EFFECT when g3size=1.0 !!)
g1size      = default( g1size,     1.50 )  # [0.5 - 4.0] size of grain / for dark areas
g2size      = default( g2size,     1.20 )  # [0.5 - 4.0] size of grain / for mid-tone areas
g3size      = default( g3size,     0.90 )  # [0.5 - 4.0] size of grain / for bright areas
g1tex       = default( g1tex,         0 )  # [ 0 - 100] strength of "material texture" appearance
g2tex       = default( g2tex,         0 )  # [ 0 - 100] (in fact: 'bump' effect)
g3tex       = default( g3tex,         0 )  # [ 0 - 100] for dark / midtone / bright grain
temp_avg    = default( temp_avg,      0 )  # [ 0 - 100] percentage of noise's temporal averaging
th1         = default( th1,          24 )  # start of dark->midtone  mixing zone
th2         = default( th2,          56 )  # end  of  dark->midtone  mixing zone
th3         = default( th3,         128 )  # start of midtone->bright  mixing zone
th4         = default( th4,         160 )  # end  of  midtone->bright  mixing zone
ontop_grain = default( ontop_grain,   0 )  # [ 0 - ???] additional grain to put on top of prev. generated grain
use_ALMask  = default( use_sAverageLumaMask, false)


#-----------------------------------------------------------------------------------

o    = clp
ox   = o.width
oy   = o.height
sx1  = m4_sh(ox/float(g1size))
sy1  = m4_sh(oy/float(g1size))
sx1a = m4_sh((ox+sx1)/2.0)
sy1a = m4_sh((oy+sy1)/2.0)
sx2  = m4_sh(ox/float(g2size))
sy2  = m4_sh(oy/float(g2size))
sx2a = m4_sh((ox+sx2)/2.0)
sy2a = m4_sh((oy+sy2)/2.0)
sx3  = m4_sh(ox/float(g3size))
sy3  = m4_sh(oy/float(g3size))
sx3a = m4_sh((ox+sx3)/2.0)
sy3a = m4_sh((oy+sy3)/2.0)

b1   = g1shrp/(-50.0) + 1.0
b2   = g2shrp/(-50.0) + 1.0
b3   = g3shrp/(-50.0) + 1.0
b1a  = b1/2.0
b2a  = b2/2.0
b3a  = b3/2.0
c1   = (1.0-b1)/2.0
c2   = (1.0-b2)/2.0
c3   = (1.0-b3)/2.0
c1a  = (1.0-b1a)/2.0
c2a  = (1.0-b2a)/2.0
c3a  = (1.0-b3a)/2.0
T1a  = string(int(g1tex*1.28))
T1b  = string(128-int(g1tex*1.28))
T2a  = string(int(g2tex*1.28))
T2b  = string(128-int(g2tex*1.28))
T3a  = string(int(g3tex*1.28))
T3b  = string(128-int(g3tex*1.28))
th1str = string(th1)
th2str = string(th2)
th3str = string(th3)
th4str = string(th4)
tmpavg = temp_avg/100.0

#-----------------------------------------------------------------------------------

BUMPKERNEL1 = T1a + " 0 0 0 " + T1b + " 0 0 0 0 128"
BUMPKERNEL2 = T2a + " 0 0 0 " + T2b + " 0 0 0 0 128"
BUMPKERNEL3 = T3a + " 0 0 0 " + T3b + " 0 0 0 0 128"

#-----------------------------------------------------------------------------------

grainlayer1 = blankclip(o, width=sx1, height=sy1, color_yuv=$808080) .AddGrainC(g1str, 0,0,0)

grainlayer1 = (g1tex==0)
\           ? grainlayer1
\           : mt_makediff(grainlayer1,grainlayer1.mt_edge(BUMPKERNEL1, 0,255,0,0, U=1,V=1 ), U=1,V=1)

grainlayer1 = (g1size == 1.0 || sx1==ox && sy1==oy) ? grainlayer1
\           : (g1size > 1.5) ? grainlayer1.bicubicresize(sx1a,sy1a, b1a,c1a).bicubicresize(ox,oy, b1a,c1a)
\                            : grainlayer1.bicubicresize(ox,oy, b1,c1)

#-----------------------------------------------------------------------------------

grainlayer2 = blankclip(o, width=sx2, height=sy2, color_yuv=$808080) .AddGrainC(g2str, 0,0,0)

grainlayer2 = (g2tex==0)
\           ? grainlayer2
\           : mt_makediff(grainlayer2,grainlayer2.mt_edge(BUMPKERNEL2, 0,255,0,0, U=1,V=1 ), U=1,V=1)

grainlayer2 = (g2size==1.0 || sx2==ox && sy2==oy) ? grainlayer2
\           : (g2size > 1.5) ? grainlayer2.bicubicresize(sx2a,sy2a, b2a,c2a).bicubicresize(ox,oy, b2a,c2a)
\                            : grainlayer2.bicubicresize(ox,oy, b2,c2)

#-----------------------------------------------------------------------------------

grainlayer3 = blankclip(o, width=sx3, height=sy3, color_yuv=$808080) .AddGrainC(g3str, 0,0,0)

grainlayer3 = (g3tex==0)
\           ? grainlayer3
\           : mt_makediff(grainlayer3,grainlayer3.mt_edge(BUMPKERNEL2, 0,255,0,0, U=1,V=1 ), U=1,V=1)

grainlayer3 = (g3size==1.0 || sx3==ox && sy3==oy) ? grainlayer3
\           : (g3size > 1.5) ? grainlayer3.bicubicresize(sx3a,sy3a, b3a,c3a).bicubicresize(ox,oy, b3a,c3a)
\                            : grainlayer3.bicubicresize(ox,oy, b3,c3)

#-----------------------------------------------------------------------------------

grainlayer = grainlayer1.mt_merge(grainlayer2, sisavs26 ? o.mt_lut("x "+th1str+" scalef < 0 x "+th2str+" scalef > range_max range_max "+th2str+" scalef "+th1str+" scalef - / x "+th1str+" scalef - * ? ?", use_expr=2) : o.mt_lut("x "+th1str+" < 0 x "+th2str+" > 255 255 "+th2str+" "+th1str+" - / x "+th1str+" - * ? ?"), U=1,V=1)
 \                      .mt_merge(grainlayer3, sisavs26 ? o.mt_lut("x "+th3str+" scalef < 0 x "+th4str+" scalef > range_max range_max "+th4str+" scalef "+th3str+" scalef - / x "+th3str+" scalef - * ? ?", use_expr=2) : o.mt_lut("x "+th3str+" < 0 x "+th4str+" > 255 255 "+th4str+" "+th3str+" - / x "+th3str+" - * ? ?"), U=1,V=1)

grainlayer = (temp_avg==0) ? grainlayer
\                          : grainlayer.mergeluma(grainlayer.temporalsoften(1,255,0,255,2), tmpavg)
grainlayer = (ontop_grain==0) ? grainlayer
\                             : grainlayer.AddGrainC(ontop_grain,0,0,0)

#-----------------------------------------------------------------------------------

result = o.mt_makediff(grainlayer, U=2,V=2)
result = use_ALMask ? mt_merge(result,o,o.sAverageLumaMask) : result
result = sislumaonly ? result : sisphbd ? CombinePlanes(result,src,planes="YUV",sample_clip=src) : ytouv(src.utoy8(),src.vtoy8(),result) 

return( result ) }
